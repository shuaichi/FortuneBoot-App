#!/bin/bash

# 错误处理：任何命令失败时退出
set -e

# 打印帮助信息
print_help() {
    echo "使用方法: ./build.sh <platform> [options]"
    echo "支持的构建平台:"
    echo "  android  - 构建 Android APK"
    echo "  ios      - 构建 iOS 上传包（flutter build ipa）"
    echo "  harmony  - 构建鸿蒙应用"
    echo ""
    echo "可选参数:"
    echo "  --skip-gen      跳过代码生成步骤"
    echo "  --yes           跳过版本确认，沿用 pubspec.yaml 当前值"
    echo "  --version x.y.z 指定版本号"
    echo "  --build N       指定构建号（整数）"
    echo ""
    echo "说明:"
    echo "  默认会交互确认版本号与构建号，再写入 pubspec.yaml 等文件。"
    echo "  若用 DevEco Studio 打包鸿蒙，请双击运行: scripts/set_ohos_version.bat"
    echo ""
    echo "示例:"
    echo "  ./build.sh android"
    echo "  ./build.sh ios --version 1.5.1 --build 2026100811"
    echo "  ./build.sh harmony --yes --skip-gen"
}

# 检查平台参数
if [ $# -eq 0 ]; then
    echo "❌ 错误: 未指定构建平台"
    print_help
    exit 1
fi

buildPlatform="$1"
shift

skipGen=false
assumeYes=false
cliVersion=""
cliBuild=""

# 解析可选参数
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-gen)
            skipGen=true
            ;;
        --yes|-y)
            assumeYes=true
            ;;
        --version)
            shift
            cliVersion="${1:-}"
            if [ -z "$cliVersion" ]; then
                echo "❌ 错误: --version 需要参数"
                exit 1
            fi
            ;;
        --build)
            shift
            cliBuild="${1:-}"
            if [ -z "$cliBuild" ]; then
                echo "❌ 错误: --build 需要参数"
                exit 1
            fi
            ;;
        --update-version)
            # 兼容旧参数：现在版本号通过 --version 或交互确认。
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "❌ 错误: 未知参数 '$1'"
            print_help
            exit 1
            ;;
    esac
    shift
done

case "$buildPlatform" in
    android|ios|harmony) ;;
    *)
        echo "❌ 错误: 未知平台 '$buildPlatform'，仅支持 android/ios/harmony"
        print_help
        exit 1
        ;;
esac

echo "🚀 开始构建 $buildPlatform 平台..."

# Android Gradle/Kotlin DSL 当前不兼容 JDK 25，优先切到本机稳定 JDK。
configure_android_java() {
    if [ "$buildPlatform" != "android" ]; then
        return
    fi

    compatibleJavaHome=""
    if command -v /usr/libexec/java_home >/dev/null 2>&1; then
        compatibleJavaHome=$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home -v 17 2>/dev/null || true)
    fi

    if [ -z "$compatibleJavaHome" ]; then
        echo "⚠️  警告: 未找到 JDK 17/21，如遇 Gradle JavaVersion.parse 报错，请安装 JDK 21 后重试"
        return
    fi

    export JAVA_HOME="$compatibleJavaHome"
    export PATH="$JAVA_HOME/bin:$PATH"
    export ANDROID_JAVA_CONFIGURED=true

    echo "☕ Android 构建使用 JAVA_HOME: $JAVA_HOME"
}

configure_harmony_flutter() {
    if [ "$buildPlatform" != "harmony" ]; then
        return
    fi

    harmonyFlutterSdk=$(grep -E '^flutter\.sdk=' ohos/local.properties 2>/dev/null | cut -d= -f2- || true)
    if [ -z "$harmonyFlutterSdk" ]; then
        return
    fi

    if [ ! -x "$harmonyFlutterSdk/bin/flutter" ]; then
        echo "❌ 错误: ohos/local.properties 中的 flutter.sdk 不可用: $harmonyFlutterSdk"
        exit 1
    fi

    HARMONY_FLUTTER_BIN="$harmonyFlutterSdk/bin/flutter"
    export HARMONY_FLUTTER_BIN
    echo "🔶 鸿蒙构建使用 Flutter SDK: $harmonyFlutterSdk"
}

run_flutter() {
    if [ "$buildPlatform" = "harmony" ] && [ -n "${HARMONY_FLUTTER_BIN:-}" ]; then
        "$HARMONY_FLUTTER_BIN" "$@"
        return
    fi

    if [ "$buildPlatform" != "android" ]; then
        flutter "$@"
        return
    fi

    if [ "${ANDROID_JAVA_CONFIGURED:-}" = true ] && [ -z "${FLUTTER_JDK_DIR_OVERRIDDEN:-}" ]; then
        ORIGINAL_FLUTTER_JDK_DIR=$(flutter config --list | awk -F': ' '/jdk-dir:/ { print $2 }')
        export ORIGINAL_FLUTTER_JDK_DIR
        export FLUTTER_JDK_DIR_OVERRIDDEN=true
        trap 'restore_flutter_jdk_dir' EXIT
    fi

    if [ "${ANDROID_JAVA_CONFIGURED:-}" = true ]; then
        flutter config --jdk-dir="$JAVA_HOME" >/dev/null
    fi

    flutter "$@"
}

restore_flutter_jdk_dir() {
    if [ -z "${ORIGINAL_FLUTTER_JDK_DIR:-}" ] || [ "$ORIGINAL_FLUTTER_JDK_DIR" = "(Not set)" ]; then
        flutter config --jdk-dir= >/dev/null
    else
        flutter config --jdk-dir="$ORIGINAL_FLUTTER_JDK_DIR" >/dev/null
    fi
}

configure_android_java
configure_harmony_flutter

read_current_version() {
    line=$(grep -E '^version: ' pubspec.yaml | head -n 1 || true)
    if [ -z "$line" ]; then
        echo "❌ 错误: 无法从 pubspec.yaml 读取 version"
        exit 1
    fi
    CURRENT_VERSION_NAME=$(echo "$line" | sed -E 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+.*/\1/')
    CURRENT_BUILD_NUMBER=$(echo "$line" | sed -E 's/^version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+).*/\1/')
}

# 手动确认后写入 pubspec.yaml / app.json5 / local.properties。
confirm_and_write_version() {
    read_current_version
    SUGGESTED_BUILD=$(date +%Y%m%d%H)

    echo ""
    echo "当前版本（上架显示为：版本号（构建号））"
    echo "  版本号: ${CURRENT_VERSION_NAME}"
    echo "  构建号: ${CURRENT_BUILD_NUMBER}"
    echo ""

    VERSION_NAME="${cliVersion:-$CURRENT_VERSION_NAME}"
    BUILD_NUMBER="${cliBuild:-$CURRENT_BUILD_NUMBER}"

    if [ "$assumeYes" = false ] && [ -z "$cliVersion" ]; then
        printf "请输入版本号（直接回车保留 %s）: " "$CURRENT_VERSION_NAME"
        read -r inputName || true
        if [ -n "${inputName:-}" ]; then
            VERSION_NAME="$inputName"
        fi
    fi

    if [ "$assumeYes" = false ] && [ -z "$cliBuild" ]; then
        printf "请输入构建号（建议 %s，直接回车保留当前 %s）: " "$SUGGESTED_BUILD" "$CURRENT_BUILD_NUMBER"
        read -r inputBuild || true
        if [ -n "${inputBuild:-}" ]; then
            BUILD_NUMBER="$inputBuild"
        fi
    fi

    if ! echo "$VERSION_NAME" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "❌ 错误: 版本号格式无效: $VERSION_NAME（应为 x.y.z）"
        exit 1
    fi
    if ! echo "$BUILD_NUMBER" | grep -Eq '^[0-9]+$'; then
        echo "❌ 错误: 构建号格式无效: $BUILD_NUMBER（应为纯数字）"
        exit 1
    fi

    echo ""
    echo "即将写入: ${VERSION_NAME}+${BUILD_NUMBER}  → 显示 ${VERSION_NAME}（${BUILD_NUMBER}）"
    if [ "$assumeYes" = false ]; then
        printf "确认写入？(Y/N): "
        read -r confirm || true
        case "${confirm:-}" in
            Y|y) ;;
            *)
                echo "已取消，未修改版本。"
                exit 0
                ;;
        esac
    fi

    # 保留 version 行的尾部注释标记（如 #🍏🥝），仅替换版本号与构建号。
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' -E "s|^version: [0-9]+\\.[0-9]+\\.[0-9]+\\+[0-9]+(.*)$|version: ${VERSION_NAME}+${BUILD_NUMBER}\\1|" pubspec.yaml
    else
        sed -i -E "s|^version: [0-9]+\\.[0-9]+\\.[0-9]+\\+[0-9]+(.*)$|version: ${VERSION_NAME}+${BUILD_NUMBER}\\1|" pubspec.yaml
    fi

    if [ -f ohos/AppScope/app.json5 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -E "s/\"versionCode\":[[:space:]]*[0-9]+/\"versionCode\": ${BUILD_NUMBER}/" ohos/AppScope/app.json5
            sed -i '' -E "s/\"versionName\":[[:space:]]*\"[^\"]+\"/\"versionName\": \"${VERSION_NAME}\"/" ohos/AppScope/app.json5
        else
            sed -i -E "s/\"versionCode\":[[:space:]]*[0-9]+/\"versionCode\": ${BUILD_NUMBER}/" ohos/AppScope/app.json5
            sed -i -E "s/\"versionName\":[[:space:]]*\"[^\"]+\"/\"versionName\": \"${VERSION_NAME}\"/" ohos/AppScope/app.json5
        fi
    fi

    if [ -f ohos/local.properties ]; then
        if grep -q '^flutter.versionName=' ohos/local.properties; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' -E "s/^flutter\\.versionName=.*/flutter.versionName=${VERSION_NAME}/" ohos/local.properties
            else
                sed -i -E "s/^flutter\\.versionName=.*/flutter.versionName=${VERSION_NAME}/" ohos/local.properties
            fi
        else
            echo "flutter.versionName=${VERSION_NAME}" >> ohos/local.properties
        fi
        if grep -q '^flutter.versionCode=' ohos/local.properties; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' -E "s/^flutter\\.versionCode=.*/flutter.versionCode=${BUILD_NUMBER}/" ohos/local.properties
            else
                sed -i -E "s/^flutter\\.versionCode=.*/flutter.versionCode=${BUILD_NUMBER}/" ohos/local.properties
            fi
        else
            echo "flutter.versionCode=${BUILD_NUMBER}" >> ohos/local.properties
        fi
    fi

    # 关于好记页展示常量（鸿蒙无 package_info 时回退）
    cat > lib/core/app/app_release_version.dart <<EOF
/// 应用发布版本（与 pubspec.yaml / 上架版本对齐）。
///
/// DevEco 打包前运行 \`scripts/set_ohos_version.ps1\` 会同步更新本文件。
/// 鸿蒙端 \`package_info_plus\` 无实现时，关于页以此为准。
class AppReleaseVersion {
  const AppReleaseVersion._();

  /// 版本号（versionName），例如 1.4.3。
  static const String name = '${VERSION_NAME}';

  /// 构建号（versionCode），例如 2026082115。
  static const String build = '${BUILD_NUMBER}';

  /// 关于页 / 列表展示用：1.4.3（2026082115）
  static String get display {
    if (name.isEmpty) return '';
    if (build.isEmpty) return name;
    return '\$name（\$build）';
  }
}
EOF

    echo "✅ 版本号已确认为: ${VERSION_NAME}+${BUILD_NUMBER}"
}

confirm_and_write_version

# 安装依赖
echo "📦 安装依赖..."
run_flutter pub get

# 代码生成（可跳过）
if [ "$skipGen" = false ]; then
    echo "📝 执行代码生成..."

    # 生成 JSON 序列化代码和 Retrofit API 代码
    dart run build_runner build

    # 使用 pubspec.lock 锁定的生成器版本生成国际化文件。
    dart run tool/generate_l10n.dart

    echo "✅ 代码生成完成"
else
    echo "⏭️  跳过代码生成"
fi

# 构建应用
case "$buildPlatform" in
    android)
        echo "🤖 构建 Android 版本..."
        run_flutter build apk --release --target-platform android-arm64 -v
        echo "✅ Android 构建完成: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    ios)
        echo "🍎 构建 iOS 版本..."
        run_flutter build ipa --release
        echo "✅ iOS 构建完成，IPA 输出目录: build/ios/ipa"
        ;;
    harmony)
        echo "🔶 构建鸿蒙版本..."
        run_flutter build app --release
        echo "✅ 鸿蒙构建完成"
        ;;
esac

echo "🎉 构建成功完成！"
