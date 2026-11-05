# FortuneBoot-App

好记：Flutter 跨平台记账客户端，面向 iOS、Android 和鸿蒙。

## 功能与目录

包含账单录入与筛选、账户、债权/债务/报销单、收支统计与日历、账本与分组协作、分类/标签/交易对象/成员、归物、周期记账、数据导入导出和应用锁。界面支持中文与英文、亮色与暗色主题。

```text
lib/
├── core/       # 应用装配、导航、会话、偏好、安全和金额工具
├── features/   # 各业务模块，按 data / presentation 等职责组织
├── fx/         # 主题、颜色、字体、间距与通用组件
├── login/      # 服务器配置与认证流程
├── l10n/       # 中英文 ARB 源文件
├── generated/  # 本地生成的国际化代码
├── request/    # Retrofit 请求定义
├── util/       # 平台与通用辅助功能
└── main.dart   # 应用入口
packages/       # 鸿蒙适配插件与必要的上游兼容修复
scripts/        # Android / 鸿蒙构建和版本辅助脚本
test/           # 单元与 Widget 回归测试
tool/           # 图标、节假日及设计预览工具
```

项目依赖约束以 [pubspec.yaml](pubspec.yaml) 为准：Dart `>=3.8.0 <4.0.0`，Flutter `>=3.32.0`。业务状态使用 Bloc，本地偏好使用 SharedPreferences，网络层使用 Dio / Retrofit。

## 本地开发

先使用目标平台对应的 Flutter SDK。Google Flutter 与鸿蒙 Flutter 是两套工具链，详细环境说明见 [docs/environment.md](docs/environment.md)。

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run intl_utils:generate
flutter run
```

`intl_utils` 已声明在项目依赖中，无需另外安装全局版本。首次检出或模型、请求接口、ARB 文件变化后生成对应代码；仅执行 `flutter clean` 不会删除源码目录中的所有生成文件。

`lib/generated/` 和多数 `*.g.dart` 为本地生成产物；少量已跟踪的生成文件仍受版本管理，以 `git ls-files` 为准。平台 SDK 路径、签名与证书按本机配置，不写入源码。

## 验证

```sh
flutter test --no-pub
flutter analyze --no-pub
git diff --check
```

依赖已安装时使用 `--no-pub`，避免验证顺带更新锁文件。分析器的既有 warning/info 应与改动前逐项比较，不以总数相同代替无新增问题；测试结果不代表真机或发布验收。

## 构建

仓库 [build.sh](build.sh) 支持以下目标：

```sh
./build.sh android
./build.sh ios
./build.sh harmony
```

脚本默认确认并写入版本号、构建号，再生成和构建；运行前检查目标 SDK 与签名。现有 Windows 辅助脚本见 [scripts/build_android.ps1](scripts/build_android.ps1) 和 [scripts/set_ohos_version.bat](scripts/set_ohos_version.bat)。

## 文档

- [文档索引](docs/README.md)：有效入口、接口参考与本地审计资料的维护边界。
- [环境与平台构建](docs/environment.md)：Android / 鸿蒙工具链与本机配置。
- `docs/design-system/`：本机正在使用的设计审计、预览、验证和 S 系列执行提示词；目录整体忽略，不属于运行时或构建依赖。
- `docs/reference/`：本地保留的历史接口快照，不能替代目标服务版本的正式契约。

## 许可证

[MIT License](LICENSE)。
