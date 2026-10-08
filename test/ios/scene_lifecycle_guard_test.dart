import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// iOS 27 requires the UIScene lifecycle. An app that only implements the
/// legacy UIApplication lifecycle is killed by UIKit at startup
/// (EXC_BREAKPOINT in ___UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption).
///
/// These guards fail fast when the scene migration is accidentally reverted.
void main() {
  group('iOS UIScene lifecycle guard', () {
    final infoPlist = File('ios/Runner/Info.plist');
    final sceneDelegate = File('ios/Runner/SceneDelegate.swift');
    final appDelegate = File('ios/Runner/AppDelegate.swift');
    final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');

    XmlElement? childAfter(XmlElement parent, String key) {
      final children = parent.childElements.toList();
      for (var i = 0; i + 1 < children.length; i++) {
        final child = children[i];
        if (child.name.local == 'key' && child.innerText == key) {
          return children[i + 1];
        }
      }
      return null;
    }

    test('Info.plist declares the single-scene Flutter UIScene manifest', () {
      final document = XmlDocument.parse(infoPlist.readAsStringSync());
      final root = document.rootElement.childElements.first;

      final manifest = childAfter(root, 'UIApplicationSceneManifest');
      expect(
        manifest,
        isNotNull,
        reason:
            'iOS 27 terminates apps without UIApplicationSceneManifest at startup.',
      );
      expect(manifest!.name.local, 'dict');

      final supportsMultipleScenes = childAfter(
        manifest,
        'UIApplicationSupportsMultipleScenes',
      );
      expect(supportsMultipleScenes, isNotNull);
      expect(
        supportsMultipleScenes!.name.local,
        'false',
        reason: 'This app is single-window; multiple scenes are unsupported.',
      );

      final configurations = childAfter(manifest, 'UISceneConfigurations');
      expect(configurations, isNotNull);
      final applicationRole = childAfter(
        configurations!,
        'UIWindowSceneSessionRoleApplication',
      );
      expect(
        applicationRole,
        isNotNull,
        reason: 'Missing UIApplication window-scene role configuration.',
      );
      expect(applicationRole!.name.local, 'array');
      final sceneConfigs = applicationRole.childElements.where(
        (element) => element.name.local == 'dict',
      );
      expect(sceneConfigs, hasLength(1));
      final sceneConfig = sceneConfigs.single;

      expect(childAfter(sceneConfig, 'UISceneClassName')?.innerText,
          'UIWindowScene');
      expect(childAfter(sceneConfig, 'UISceneConfigurationName')?.innerText,
          'flutter');
      expect(
        childAfter(sceneConfig, 'UISceneDelegateClassName')?.innerText,
        '\$(PRODUCT_MODULE_NAME).SceneDelegate',
        reason:
            'SceneDelegate must be the window-scene delegate declared in Info.plist.',
      );
      expect(
        childAfter(sceneConfig, 'UISceneStoryboardFile')?.innerText,
        'Main',
        reason: 'Main.storyboard hosts the FlutterViewController for the scene.',
      );
    });

    test('SceneDelegate subclasses FlutterSceneDelegate and keeps Flutter callbacks', () {
      expect(
        sceneDelegate.existsSync(),
        isTrue,
        reason: 'ios/Runner/SceneDelegate.swift is required by the scene manifest.',
      );
      if (!sceneDelegate.existsSync()) return;
      final source = sceneDelegate.readAsStringSync();

      expect(
        source,
        contains('class SceneDelegate: FlutterSceneDelegate'),
        reason: 'Must reuse the engine-provided scene delegate implementation.',
      );
      expect(
        source,
        contains('super.scene('),
        reason: 'The super call makes Flutter create the scene window/engine.',
      );
      expect(source, contains('super.sceneDidBecomeActive'));
      expect(source, contains('super.sceneWillResignActive'));
    });

    test('Screen-capture protection moves with the window into the scene', () {
      expect(
        sceneDelegate.existsSync(),
        isTrue,
        reason: 'The protection channel needs the scene window.',
      );
      if (!sceneDelegate.existsSync()) return;
      final source = sceneDelegate.readAsStringSync();

      expect(
        source,
        contains("fortuneboot/screen_capture_protection"),
        reason: 'The app-lock screen-capture channel must keep its name.',
      );
      expect(source, contains('setScreenCaptureAllowed'));
      expect(
        source,
        contains('window?.rootViewController as? FlutterViewController'),
        reason: 'Channel setup must happen after the scene window exists.',
      );
      expect(
        source,
        contains('FlutterMethodChannel'),
        reason: 'The native method channel must keep serving Dart requests.',
      );
    });

    test('SceneDelegate.swift is compiled into the Runner target', () {
      final project = pbxproj.readAsStringSync();
      expect(
        project,
        contains('/* SceneDelegate.swift */'),
        reason: 'SceneDelegate.swift must have a project file reference.',
      );
      expect(
        project,
        contains('/* SceneDelegate.swift in Sources */'),
        reason: 'Without a Sources entry the scene delegate is not compiled.',
      );
    });

    test('AppDelegate registers plugins through the implicit engine bridge', () {
      final source = appDelegate.readAsStringSync();

      expect(
        source,
        contains('FlutterImplicitEngineDelegate'),
        reason:
            'Under the scene lifecycle the engine is created lazily from Main.storyboard.',
      );
      expect(source, contains('didInitializeImplicitFlutterEngine'));
      expect(
        source,
        contains('GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)'),
        reason: 'Plugin registration must target the implicit engine registry.',
      );
      expect(
        source,
        isNot(contains('configureScreenCaptureChannel')),
        reason:
            'AppDelegate.window is nil before the scene connects; the channel moved to SceneDelegate.',
      );
    });
  });
}
