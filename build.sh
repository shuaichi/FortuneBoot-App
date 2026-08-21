#!/bin/bash

# 错误处理：任何命令失败时退出
set -e

# 每次打包需要变动的字段放在这里，便于发布前统一修改。
MAJOR_VERSION="1.4.3"
VERSION_MARKER="#😁😈"

# 打印帮助信息
print_help() {
    echo "使用方法: ./build.sh <platform>"
    echo "支持的构建平台:"
    echo "  android  - 构建 Android APK"
    echo "  ios      - 构建 iOS 应用"
    echo "  harmony  - 构建鸿蒙应用"
    echo ""
    echo "可选参数:"
    echo "  --skip-gen      跳过代码生成步骤"
    echo "  --update-version 兼容旧参数，版本号现在每次打包都会自动更新"
    echo ""
    echo "示例:"
    echo "  ./build.sh android"
    echo "  ./build.sh android --skip-gen"
    echo "  ./build.sh ios --update-version"
}

# 检查参数
if [ $# -eq 0 ]; then
    echo "❌ 错误: 未指定构建平台"
    print_help
    exit 1
fi

buildPlatform=$1
skipGen=false
updateVersion=false

# 解析参数
shift
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-gen)
            skipGen=true
            ;;
        --update-version)
            updateVersion=true
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

# 同步更新 pubspec.yaml 版本号。
update_pubspec_version() {
    BUILD_NUMBER=$(date +%Y%m%d%H)
    nextVersion="version: ${MAJOR_VERSION}+${BUILD_NUMBER} ${VERSION_MARKER}"

    line=$(grep -Eo "version: .*${VERSION_MARKER}" pubspec.yaml || true)

    if [ -n "$line" ]; then
        # macOS 和 Linux 兼容的 sed 命令
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/$line/$nextVersion/g" pubspec.yaml
        else
            sed -i "s/$line/$nextVersion/g" pubspec.yaml
        fi
        echo "✅ 版本号已更新为: ${MAJOR_VERSION}+${BUILD_NUMBER}"
    else
        echo "⚠️  警告: 未找到版本号标记，跳过版本号更新"
    fi
}

update_pubspec_version

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
        run_flutter build ios --release --no-codesign
        echo "✅ iOS 构建完成"
        ;;
    harmony)
        echo "🔶 构建鸿蒙版本..."
        run_flutter build app --release
        echo "✅ 鸿蒙构建完成"
        ;;
    *)
        echo "❌ 错误: 未知平台 '$buildPlatform'，仅支持 android/ios/harmony"
        exit 1
        ;;
esac

echo "🎉 构建成功完成！"
