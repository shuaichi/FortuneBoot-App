import 'package:flutter/material.dart';

/// 字体大小层级
class FontSizes {
  FontSizes._();
  
  static const double display = 32.0;     // 展示标题
  static const double headline = 24.0;    // 主标题
  static const double title = 20.0;       // 副标题
  static const double body = 16.0;        // 正文
  static const double label = 14.0;       // 标签
  static const double caption = 12.0;     // 辅助文字
  static const double overline = 10.0;    // 过线文字
}

/// 字重系统
class FontWeights {
  FontWeights._();
  
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// 行高系统
class LineHeights {
  LineHeights._();
  
  static const double tight = 1.1;
  static const double normal = 1.2;
  static const double relaxed = 1.4;
  static const double loose = 1.6;
}

/// 字体样式预设
class TextStyles {
  TextStyles._();
  
  // 账户名称样式
  static const TextStyle accountName = TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.semiBold,
    height: LineHeights.normal,
  );

  // 余额数字样式
  static const TextStyle balanceAmount = TextStyle(
    fontSize: FontSizes.headline,
    fontWeight: FontWeights.bold,
    height: LineHeights.tight,
  );

  // 币种代码样式
  static const TextStyle currencyCode = TextStyle(
    fontSize: FontSizes.caption,
    fontWeight: FontWeights.medium,
    height: LineHeights.normal,
  );

  // 备注文字样式
  static const TextStyle remark = TextStyle(
    fontSize: FontSizes.label,
    fontWeight: FontWeights.regular,
    height: LineHeights.relaxed,
  );

  // 状态标签样式
  static const TextStyle statusChip = TextStyle(
    fontSize: FontSizes.caption,
    fontWeight: FontWeights.medium,
    height: LineHeights.normal,
  );

  // 页面标题样式
  static const TextStyle pageTitle = TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.semiBold,
    height: LineHeights.normal,
  );

  // 空状态标题样式
  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.medium,
    height: LineHeights.normal,
  );

  // 空状态描述样式
  static const TextStyle emptyStateDescription = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeights.regular,
    height: LineHeights.relaxed,
  );

  // 输入框标签样式
  static const TextStyle inputLabel = TextStyle(
    fontSize: FontSizes.label,
    fontWeight: FontWeights.medium,
    height: LineHeights.normal,
  );

  // 输入框提示样式
  static const TextStyle inputHint = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeights.regular,
    height: LineHeights.normal,
  );

  // 节标题样式
  static const TextStyle sectionTitle = TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.semiBold,
    height: LineHeights.normal,
  );

  // 正文样式
  static const TextStyle bodyMedium = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeights.regular,
    height: LineHeights.normal,
  );

  // 按钮文字样式
  static const TextStyle buttonText = TextStyle(
    fontSize: FontSizes.body,
    fontWeight: FontWeights.medium,
    height: LineHeights.normal,
  );

  // 说明文字样式
  static const TextStyle caption = TextStyle(
    fontSize: FontSizes.caption,
    fontWeight: FontWeights.regular,
    height: LineHeights.normal,
  );
}

/// 记账专用色彩语义
class FinanceColors {
  FinanceColors._();
  
  // 收入色彩（绿色系）
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color incomeDark = Color(0xFF059669);

  // 支出色彩（红色系）
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFFEE2E2);
  static const Color expenseDark = Color(0xFFDC2626);

  // 转账色彩（蓝色系）
  static const Color transfer = Color(0xFF3B82F6);
  static const Color transferLight = Color(0xFFDBEAFE);
  static const Color transferDark = Color(0xFF2563EB);

  // 资产色彩（紫色系）
  static const Color asset = Color(0xFF8B5CF6);
  static const Color assetLight = Color(0xFFEDE9FE);
  static const Color assetDark = Color(0xFF7C3AED);

  // 中性色彩
  static const Color neutral = Color(0xFF6B7280);
  static const Color neutralLight = Color(0xFFF3F4F6);
  static const Color neutralDark = Color(0xFF374151);
}

/// 8dp网格系统间距
class Spacing {
  Spacing._();
  
  static const double xs = 4.0;    // 0.5x
  static const double sm = 8.0;    // 1x
  static const double md = 16.0;   // 2x
  static const double lg = 24.0;   // 3x
  static const double xl = 32.0;   // 4x
  static const double xxl = 48.0;  // 6x
  static const double xxxl = 64.0; // 8x
}

/// 边距预设
class Paddings {
  Paddings._();
  
  // 页面水平边距
  static EdgeInsets pageHorizontal(double screenWidth) {
    if (screenWidth < 600) return const EdgeInsets.symmetric(horizontal: Spacing.md);
    if (screenWidth < 1024) return const EdgeInsets.symmetric(horizontal: Spacing.lg);
    return const EdgeInsets.symmetric(horizontal: Spacing.xl);
  }

  // 卡片内边距
  static const EdgeInsets card = EdgeInsets.all(Spacing.md);
  
  // 卡片间距
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    vertical: Spacing.xs,
    horizontal: Spacing.md,
  );

  // 组件间距
  static const EdgeInsets component = EdgeInsets.symmetric(vertical: Spacing.sm);
}

/// 圆角半径
class BorderRadiusValues {
  BorderRadiusValues._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0; // 胶囊形状
}

/// 圆角预设
class BorderRadii {
  BorderRadii._();
  
  static final BorderRadius card = BorderRadius.circular(BorderRadiusValues.lg);
  static final BorderRadius button = BorderRadius.circular(BorderRadiusValues.md);
  static final BorderRadius chip = BorderRadius.circular(BorderRadiusValues.pill);
  static final BorderRadius sheet = const BorderRadius.vertical(
    top: Radius.circular(BorderRadiusValues.xl),
  );
}

/// Material 3 阴影层级
class Shadows {
  Shadows._();
  
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}

/// 动画时长
class Durations {
  Durations._();
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// 动画时长（别名类，用于兼容性）
class AnimationDurations {
  AnimationDurations._();
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// 圆角半径（别名类，用于兼容性）
class AppBorderRadius {
  AppBorderRadius._();
  
  static final BorderRadius card = BorderRadii.card;
  static final BorderRadius button = BorderRadii.button;
  static final BorderRadius chip = BorderRadii.chip;
  static final BorderRadius sheet = BorderRadii.sheet;
}

/// 动画曲线
class AnimationCurves {
  AnimationCurves._();
  
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}

/// 屏幕断点
class Breakpoints {
  Breakpoints._();
  
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;
}

/// 状态图标
class StatusIcons {
  StatusIcons._();
  
  static const IconData income = Icons.arrow_upward;
  static const IconData expense = Icons.arrow_downward;
  static const IconData transferIn = Icons.call_received;
  static const IconData transferOut = Icons.call_made;
  static const IconData enabled = Icons.check_circle_outline;
  static const IconData disabled = Icons.cancel_outlined;
  static const IconData include = Icons.visibility_outlined;
  static const IconData exclude = Icons.visibility_off_outlined;
}

/// 账户管理模块设计系统常量
/// 包含字体、色彩、间距、动画等视觉规范
class AccountDesignSystem {
  AccountDesignSystem._();

  /// 账户类型色彩映射
  static Color getAccountTypeColor(int accountType) {
    switch (accountType) {
      case 1: // 活期
        return FinanceColors.income;
      case 2: // 信用
        return FinanceColors.expense;
      case 3: // 资产
        return FinanceColors.asset;
      case 4: // 贷款
        return FinanceColors.transfer;
      default:
        return FinanceColors.neutral;
    }
  }

  /// 账户类型浅色背景
  static Color getAccountTypeLightColor(int accountType) {
    switch (accountType) {
      case 1: // 活期
        return FinanceColors.incomeLight;
      case 2: // 信用
        return FinanceColors.expenseLight;
      case 3: // 资产
        return FinanceColors.assetLight;
      case 4: // 贷款
        return FinanceColors.transferLight;
      default:
        return FinanceColors.neutralLight;
    }
  }

  /// 响应式工具方法
  static bool isMobile(double width) => width < Breakpoints.mobile;
  static bool isTablet(double width) => 
      width >= Breakpoints.mobile && width < Breakpoints.tablet;
  static bool isDesktop(double width) => width >= Breakpoints.tablet;

  /// 响应式列数计算
  static int getGridColumns(double width) {
    if (width < Breakpoints.mobile) return 1;
    if (width < Breakpoints.tablet) return 2;
    if (width < Breakpoints.desktop) return 3;
    return 4;
  }

  /// 账户类型图标
  static IconData getAccountTypeIcon(int accountType) {
    switch (accountType) {
      case 1: // 活期
        return Icons.account_balance_wallet_outlined;
      case 2: // 信用
        return Icons.credit_card_outlined;
      case 3: // 资产
        return Icons.savings_outlined;
      case 4: // 贷款
        return Icons.trending_down_outlined;
      default:
        return Icons.account_balance_outlined;
    }
  }
}

/// 扩展方法：为BuildContext添加设计系统访问
extension DesignSystemExtension on BuildContext {
  /// 获取响应式水平边距
  EdgeInsets get responsiveHorizontalPadding {
    final width = MediaQuery.of(this).size.width;
    return Paddings.pageHorizontal(width);
  }

  /// 判断是否为移动端
  bool get isMobile {
    final width = MediaQuery.of(this).size.width;
    return AccountDesignSystem.isMobile(width);
  }

  /// 判断是否为平板
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return AccountDesignSystem.isTablet(width);
  }

  /// 判断是否为桌面端
  bool get isDesktop {
    final width = MediaQuery.of(this).size.width;
    return AccountDesignSystem.isDesktop(width);
  }

  /// 获取网格列数
  int get gridColumns {
    final width = MediaQuery.of(this).size.width;
    return AccountDesignSystem.getGridColumns(width);
  }
}