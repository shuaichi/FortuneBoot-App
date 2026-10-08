# 安卓 / 鸿蒙环境清单

同一份仓库可打 **Android APK** 和 **纯血鸿蒙 HAP**，不必改 `pubspec.yaml`。  
两套构建用的是 **两套 Flutter，不能混用**。

仓库忽略了 `*.g.dart`、`android/local.properties`。clone 后必须自己生成代码、写本地路径。

建议国内镜像：

```
PUB_HOSTED_URL=https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

---

## 公共（clone 后都要做）

| 项 | 说明 |
|----|------|
| Git | 拉取代码 |
| 对应平台的 Flutter | 安卓用 Google Flutter；鸿蒙用鸿蒙 Flutter |

在项目根目录（使用**当前要打包的那套** Flutter）：

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

## 只打安卓 APK

| 组件 | 要求 |
|------|------|
| Flutter（Google） | `>= 3.32`（Dart `>= 3.8`，随 SDK 安装）。本仓库曾用 3.47 打通过 |
| JDK | **17**（Gradle）。源码 `jvmTarget` 为 11 |
| Android SDK | Android Studio 一并安装即可。Flutter 3.47 一般需要 API 35/36、build-tools |
| Android Studio | 可选，便于第一次 Gradle 同步 |

clone 后新建 `android/local.properties`（不要提交）：

```
flutter.sdk=你的 Google Flutter 路径
sdk.dir=你的 Android SDK 路径
```

Gradle **8.14.3**、AGP **8.11.1**、Kotlin **2.2.20** 由工程下载，不用单独装。

未配置正式签名时，release 会用 debug 签名，可本机安装。上架再在 `local.properties` 配 `sign.*`，keyStore 不要进 Git。

```powershell
flutter build apk --release
```

也可用 `scripts/build_android.ps1`。

---

## 只打纯血鸿蒙 HAP

官方 Google Flutter **不能**打 HAP。

| 组件 | 要求 |
|------|------|
| 鸿蒙 Flutter SDK | 带 `@ohos/flutter_ohos` 与 ohos 引擎 HAR（常见目录名 `flutter_flutter`） |
| DevEco Studio | 打开 `ohos/` |
| HarmonyOS SDK | 随 DevEco。工程为 `runtimeOS: HarmonyOS`，API **6.0.0(20)** |
| Git | DevEco 的 Flutter 任务会调用 git |

`scripts/ohos_env.bat` 里是原作者机器路径，改成自己的：

- `FLUTTER_ROOT`：鸿蒙 Flutter
- `JAVA_HOME`：DevEco 自带 JBR 即可
- `DEVECO_SDK_HOME`：DevEco 的 SDK

然后用**鸿蒙 Flutter**再执行一次 `flutter pub get`（会把 `ohos/oh-package.json5` 里的 `flutter.har` 改到当前 SDK），再在 DevEco 里 Build Hap。

上架版本可先跑 `scripts/set_ohos_version.bat`，再打包。

鸿蒙证书、`.p7b`、密码在 `ohos/build-profile.json5` 里是本机绝对路径。每人使用自己的调试/发布证书，不要把别人的签名材料提交进 Git。

插件：`packages/*_ohos` 已在仓库内。引擎 HAR 仍来自鸿蒙 Flutter SDK，见 `scripts/ohos_deps_notes.txt`。

---

## 两边都打

同一台电脑装两套，PATH 不要长期只留一个 `flutter`：

| | 安卓 | 鸿蒙 |
|--|------|------|
| Flutter | Google Flutter | 鸿蒙 Flutter |
| IDE | Android Studio（可选） | DevEco Studio |
| SDK | Android SDK | HarmonyOS SDK |
| Java | JDK 17 | DevEco JBR |

打哪一端，就把哪一端的 `flutter\bin` 放到 PATH 前面，或写全路径。

---

## Git 里不会有、必须本地配

- `android/local.properties`
- Android / 鸿蒙签名文件与密码
- 鸿蒙引擎 HAR 的本机 `file:` 路径（`flutter pub get` 会写）
- 生成代码 `*.g.dart`（`build_runner`）
