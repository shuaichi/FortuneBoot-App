#!/bin/bash

# 错误处理：任何命令失败时退出
set -e

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
    echo "  --update-version 更新版本号"
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

# 更新版本号（仅在指定时）
if [ "$updateVersion" = true ]; then
    MAJOR_VERSION="1.3.14"
    BUILD_NUMBER=$(date +%Y%m%d%H)

    line=$(grep -Eo "version: .*#😁😈" pubspec.yaml || true)

    if [ -n "$line" ]; then
        # macOS 和 Linux 兼容的 sed 命令
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/$line/version: ${MAJOR_VERSION}+${BUILD_NUMBER} #😁😈/g" pubspec.yaml
        else
            sed -i "s/$line/version: ${MAJOR_VERSION}+${BUILD_NUMBER} #😁😈/g" pubspec.yaml
        fi
        echo "✅ 版本号已更新为: ${MAJOR_VERSION}+${BUILD_NUMBER}"
    else
        echo "⚠️  警告: 未找到版本号标记，跳过版本号更新"
    fi
fi

# 安装依赖
echo "📦 安装依赖..."
flutter pub get

# 代码生成（可跳过）
if [ "$skipGen" = false ]; then
    echo "📝 执行代码生成..."

    # 检查 intl_utils 是否已安装
    if ! flutter pub global list | grep -q "intl_utils"; then
        echo "📦 安装 intl_utils..."
        flutter pub global activate intl_utils
    fi

    # 生成 JSON 序列化代码和 Retrofit API 代码
    flutter pub run build_runner build --delete-conflicting-outputs

    # 生成国际化文件
    flutter pub global run intl_utils:generate

    echo "✅ 代码生成完成"
else
    echo "⏭️  跳过代码生成"
fi

# 构建应用
case "$buildPlatform" in
    android)
        echo "🤖 构建 Android 版本..."
        flutter build apk --release --target-platform android-arm64 -v
        echo "✅ Android 构建完成: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    ios)
        echo "🍎 构建 iOS 版本..."
        flutter build ios --release --no-codesign
        echo "✅ iOS 构建完成"
        ;;
    harmony)
        echo "🔶 构建鸿蒙版本..."
        # 检查是否使用 fvm
        if command -v fvm &> /dev/null; then
            fvm flutter build app --release
        else
            flutter build app --release
        fi
        echo "✅ 鸿蒙构建完成"
        ;;
    *)
        echo "❌ 错误: 未知平台 '$buildPlatform'，仅支持 android/ios/harmony"
        exit 1
        ;;
esac

echo "🎉 构建成功完成！"
