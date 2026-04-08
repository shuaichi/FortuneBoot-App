# FortuneBoot-App

好记 - 智能记账应用

## 项目简介

FortuneBoot-App 是一款跨平台智能记账应用，支持 iOS、Android 和鸿蒙平台。

## 功能特性

- 📊 账单管理与统计
- 💰 账户管理
- 🏷️ 分类与标签管理
- 👥 收款人管理
- 📈 数据统计与图表
- 🌐 多语言支持（中文/英文）

## 技术栈

- **框架**: Flutter 3.32.0+
- **状态管理**: Bloc
- **本地存储**: SharedPreferences
- **网络请求**: Retrofit
- **支持平台**: iOS、Android、鸿蒙（HarmonyOS）

## 项目结构

```
lib/
├── generated/          # 国际化生成文件
├── home/               # 主页功能模块
│   ├── account_manage/ # 账户管理
│   ├── bill_overview/  # 账单概览
│   ├── category_manage/# 分类管理
│   ├── edit_bill/      # 账单编辑
│   ├── payee_manage/   # 收款人管理
│   ├── setting_page/   # 设置页面
│   ├── stats/          # 统计分析
│   └── tag_manage/     # 标签管理
├── login/              # 登录模块
├── repository/         # 数据仓库
├── request/            # 网络请求
├── theme/              # 主题配置
├── util/               # 工具类
└── main.dart           # 应用入口
```

## 开发环境配置

### 前置要求

- Flutter SDK 3.32.0 或更高版本
- Dart SDK 3.8.0 或更高版本
- Android Studio / VS Code
- Xcode (iOS 开发)
- DevEco Studio (鸿蒙开发)

### 新电脑首次启动流程

> ⚠️ **重要**: 本项目使用代码生成器，生成的文件（`.g.dart`、国际化文件等）已加入 `.gitignore`，不会提交到版本控制。因此在新电脑上克隆项目后，需要运行代码生成命令。

#### 方式一：完整流程（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/yourusername/FortuneBoot-App.git
cd FortuneBoot-App

# 2. 安装依赖
flutter pub get

# 3. 安装代码生成工具（首次运行需要）
flutter pub global activate intl_utils

# 4. 生成代码
# 生成 JSON 序列化代码和 Retrofit API 代码
flutter pub run build_runner build --delete-conflicting-outputs

# 生成国际化文件
flutter pub global run intl_utils:generate

# 5. 运行项目
flutter run
```

#### 方式二：使用别名（快捷方式）

在 `~/.zshrc` 或 `~/.bashrc` 中添加别名：

```bash
# Flutter 代码生成别名
alias fgen='flutter pub run build_runner build --delete-conflicting-outputs && flutter pub global run intl_utils:generate'
```

然后每次只需运行：

```bash
fgen
```

### 何时需要重新生成代码？

以下情况需要运行代码生成命令：

- ✅ `flutter clean` 之后
- ✅ 切换分支或拉取新代码后（如果模型或 API 有变化）
- ✅ 修改了带有 `@JsonSerializable` 注解的模型类
- ✅ 修改了 Retrofit API 定义
- ✅ 修改了国际化文件（`lib/l10n/intl_*.arb`）

### 快速开始

```bash
# 安装依赖
flutter pub get

# 生成代码（首次或 clean 后）
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub global run intl_utils:generate

# 运行项目
flutter run
```

## 构建发布

使用 `build.sh` 脚本构建：

```bash
# 构建 Android
./build.sh android

# 构建 iOS
./build.sh ios

# 构建鸿蒙
./build.sh harmony
```

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件