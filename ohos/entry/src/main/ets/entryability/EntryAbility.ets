
import window from '@ohos.window';
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import {
  bindScreenCaptureWindow,
  reapplyScreenCaptureProtection,
} from 'fortuneboot_ohos_security';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';

export default class EntryAbility extends FlutterAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage);
    windowStage.getMainWindow().then((mainWindow: window.Window) => {
      bindScreenCaptureWindow(mainWindow);
    }).catch((): void => {
      console.error('Unable to bind screen capture window');
    });
    // 获取 Flutter 渲染视图并把 viewId 写入全局存储，供 ETS 页面读取
    // getFlutterView 由 FlutterAbility 提供
    // 防止异常导致白屏，这里加上兜底日志
    try {
      const flutterView = this.getFlutterView();
      if (flutterView) {
        // 将 viewId 写入 AppStorage，页面端从 AppStorage 获取
        // AppStorage 是全局级别，可在任意页面读取
        AppStorage.SetOrCreate('viewId', flutterView.getId());
      }
    } catch (e) {
      console.error('Failed to get FlutterView:', e);
    }
  }
  onForeground(): void {
    super.onForeground();
    reapplyScreenCaptureProtection();
  }

  onBackground(): void {
    reapplyScreenCaptureProtection();
    super.onBackground();
  }

  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
