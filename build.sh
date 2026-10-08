#!/bin/bash

# 错误处理：任何命令失败时退出
set -e

VERSION_MARKER="#😁😈"

# 打印帮助信息
print_help() {
    echo "使用方法: ./build.sh [harmony] [options]"
    echo "支持的构建平台:"
    echo "  harmony  - 构建鸿蒙应用（默认）"
    echo ""
    echo "可选参数:"
    echo "  --skip-gen      跳过代码生成步骤"
    echo "  --yes           跳过版本确认，沿用 pubspec.yaml 当前值"
    echo "  --version x.y.z 指定版本号"
    echo "  --build N       指定构建号（整数）"
    echo ""
    echo "说明:"
    echo "  默认会交互确认版本号与构建号，再写入 pubspec.yaml。"
    echo "  若用 DevEco Studio 打包，请双击运行: scripts/set_ohos_version.bat"
    echo ""
    echo "示例:"
    echo "  ./build.sh"
    echo "  ./build.sh harmony --version 1.4.4 --build 2026091616"
    echo "  ./build.sh harmony --yes --skip-gen"
}

buildPlatform="harmony"
skipGen=false
assumeYes=false
cliVersion=""
cliBuild=""

# 解析参数
while [ $# -gt 0 ]; do
    case "$1" in
        harmony)
            buildPlatform="harmony"
            ;;
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
            # 兼容旧参数：现已改为每次手动确认，忽略。
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

configure_harmony_flutter() {
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
    if [ -n "${HARMONY_FLUTTER_BIN:-}" ]; then
        "$HARMONY_FLUTTER_BIN" "$@"
        return
    fi

    flutter "$@"
}

configure_harmony_flutter

read_current_version() {
    line=$(grep -E "^version: .*${VERSION_MARKER}" pubspec.yaml || true)
    if [ -z "$line" ]; then
        line=$(grep -E '^version: ' pubspec.yaml | head -n 1 || true)
    fi
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

    nextVersion="version: ${VERSION_NAME}+${BUILD_NUMBER} ${VERSION_MARKER}"
    line=$(grep -Eo "version: .*${VERSION_MARKER}" pubspec.yaml || true)
    if [ -n "$line" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/$line/$nextVersion/g" pubspec.yaml
        else
            sed -i "s/$line/$nextVersion/g" pubspec.yaml
        fi
    else
        echo "❌ 错误: 未找到版本号标记 ${VERSION_MARKER}"
        exit 1
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
                sed -i '' -E "s/^flutter\.versionName=.*/flutter.versionName=${VERSION_NAME}/" ohos/local.properties
            else
                sed -i -E "s/^flutter\.versionName=.*/flutter.versionName=${VERSION_NAME}/" ohos/local.properties
            fi
        else
            echo "flutter.versionName=${VERSION_NAME}" >> ohos/local.properties
        fi
        if grep -q '^flutter.versionCode=' ohos/local.properties; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' -E "s/^flutter\.versionCode=.*/flutter.versionCode=${BUILD_NUMBER}/" ohos/local.properties
            else
                sed -i -E "s/^flutter\.versionCode=.*/flutter.versionCode=${BUILD_NUMBER}/" ohos/local.properties
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
echo "🔶 构建鸿蒙版本..."
run_flutter build app --release
echo "✅ 鸿蒙构建完成"

echo "🎉 构建成功完成！"
