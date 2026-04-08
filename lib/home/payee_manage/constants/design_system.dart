import 'package:flutter/material.dart';

/// 交易对象管理设计系统
/// 基于账户管理设计系统，针对交易对象特性进行语义化调整

/// 字体大小层级（复用通用规范）
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

/// 字重系统（复用通用规范）
class FontWeights {
  FontWeights._();
  
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// 行高系统（复用通用规范）
class LineHeights {
  LineHeights._();
  
  static const double tight = 1.1;
  static const double normal = 1.2;
  static const double relaxed = 1.4;
  static const double loose = 1.6;
}

/// 交易对象专用字体样式
class PayeeTextStyles {
  PayeeTextStyles._();
  
  // 交易对象名称样式
  static const TextStyle payeeName = TextStyle(
    fontSize: FontSizes.title,
    fontWeight: FontWeights.semiBold,
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

  // 排序号样式
  static const TextStyle sortNumber = TextStyle(
    fontSize: FontSizes.caption,
    fontWeight: FontWeights.medium,
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

/// 交易对象专用色彩语义
class PayeeColors {
  PayeeColors._();
  
  // 收入权限色彩（绿色系）
  static const Color incomeEnabled = Color(0xFF10B981);
  static const Color incomeEnabledLight = Color(0xFFD1FAE5);
  static const Color incomeEnabledDark = Color(0xFF059669);
  
  // 支出权限色彩（红色系）
  static const Color expenseEnabled = Color(0xFFEF4444);
  static const Color expenseEnabledLight = Color(0xFFFEE2E2);
  static const Color expenseEnabledDark = Color(0xFFDC2626);
  
  // 禁用状态色彩（灰色系）
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color disabledLight = Color(0xFFF3F4F6);
  static const Color disabledDark = Color(0xFF6B7280);
  
  // 启用状态色彩（蓝色系）
  static const Color enabled = Color(0xFF3B82F6);
  static const Color enabledLight = Color(0xFFDBEAFE);
  static const Color enabledDark = Color(0xFF2563EB);
  
  // 主色调（紫色系）
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryDark = Color(0xFF7C3AED);
  
  // 中性色彩
  static const Color neutral = Color(0xFF6B7280);
  static const Color neutralLight = Color(0xFFF3F4F6);
  static const Color neutralDark = Color(0xFF374151);
  
  // 交易对象卡片背景渐变
  static const Color cardGradientStart = Color(0xFFFAFAFA);
  static const Color cardGradientEnd = Color(0xFFF8FAFC);
}

/// 8dp网格系统间距（复用通用规范）
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

/// 边距预设（复用通用规范）
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

/// 圆角半径（复用通用规范）
class BorderRadiusValues {
  BorderRadiusValues._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 999.0; // 胶囊形状
}

/// 圆角预设（复用通用规范）
class BorderRadii {
  BorderRadii._();
  
  static final BorderRadius card = BorderRadius.circular(BorderRadiusValues.lg);
  static final BorderRadius button = BorderRadius.circular(BorderRadiusValues.md);
  static final BorderRadius chip = BorderRadius.circular(BorderRadiusValues.pill);
  static final BorderRadius sheet = const BorderRadius.vertical(
    top: Radius.circular(BorderRadiusValues.xl),
  );
}

/// Material 3 阴影层级（复用通用规范）
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

/// 动画时长（复用通用规范）
class Durations {
  Durations._();
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

/// 动画曲线（复用通用规范）
class AnimationCurves {
  AnimationCurves._();
  
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
}

/// 屏幕断点（复用通用规范）
class Breakpoints {
  Breakpoints._();
  
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;
}

/// 交易对象状态图标
class PayeeStatusIcons {
  PayeeStatusIcons._();
  
  static const IconData incomeEnabled = Icons.arrow_downward;
  static const IconData incomeDisabled = Icons.arrow_downward;
  static const IconData expenseEnabled = Icons.arrow_upward;
  static const IconData expenseDisabled = Icons.arrow_upward;
  static const IconData enabled = Icons.check_circle_outline;
  static const IconData disabled = Icons.cancel_outlined;
  static const IconData payee = Icons.person_outline;
  static const IconData company = Icons.business_outlined;
  static const IconData shop = Icons.store_outlined;
}

/// 交易对象管理模块设计系统常量
class PayeeDesignSystem {
  PayeeDesignSystem._();

  /// 获取收入权限状态颜色
  static Color getIncomePermissionColor(bool canIncome) {
    return canIncome ? PayeeColors.incomeEnabled : PayeeColors.disabled;
  }

  /// 获取支出权限状态颜色
  static Color getExpensePermissionColor(bool canExpense) {
    return canExpense ? PayeeColors.expenseEnabled : PayeeColors.disabled;
  }

  /// 获取启用状态颜色
  static Color getEnabledStatusColor(bool enabled) {
    return enabled ? PayeeColors.enabled : PayeeColors.disabled;
  }

  /// 获取收入权限状态浅色背景
  static Color getIncomePermissionLightColor(bool canIncome) {
    return canIncome ? PayeeColors.incomeEnabledLight : PayeeColors.disabledLight;
  }

  /// 获取支出权限状态浅色背景
  static Color getExpensePermissionLightColor(bool canExpense) {
    return canExpense ? PayeeColors.expenseEnabledLight : PayeeColors.disabledLight;
  }

  /// 获取启用状态浅色背景
  static Color getEnabledStatusLightColor(bool enabled) {
    return enabled ? PayeeColors.enabledLight : PayeeColors.disabledLight;
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

  /// 获取交易对象图标（基于名称推测类型）
  static IconData getPayeeIcon(String payeeName) {
    final name = payeeName.toLowerCase();
    if (name.contains('公司') || name.contains('企业') || name.contains('集团')) {
      return PayeeStatusIcons.company;
    } else if (name.contains('店') || name.contains('商') || name.contains('超市')) {
      return PayeeStatusIcons.shop;
    } else {
      return PayeeStatusIcons.payee;
    }
  }

  /// 获取状态标签文本
  static String getIncomePermissionText(bool canIncome) {
    return canIncome ? '收入' : '收入禁止';
  }

  static String getExpensePermissionText(bool canExpense) {
    return canExpense ? '支出' : '支出禁止';
  }

  static String getEnabledStatusText(bool enabled) {
    return enabled ? '启用' : '停用';
  }
}

/// 扩展方法：为BuildContext添加交易对象设计系统访问
extension PayeeDesignSystemExtension on BuildContext {
  /// 获取响应式水平边距
  EdgeInsets get responsiveHorizontalPadding {
    final width = MediaQuery.of(this).size.width;
    return Paddings.pageHorizontal(width);
  }

  /// 判断是否为移动端
  bool get isMobile {
    final width = MediaQuery.of(this).size.width;
    return PayeeDesignSystem.isMobile(width);
  }

  /// 判断是否为平板
  bool get isTablet {
    final width = MediaQuery.of(this).size.width;
    return PayeeDesignSystem.isTablet(width);
  }

  /// 判断是否为桌面端
  bool get isDesktop {
    final width = MediaQuery.of(this).size.width;
    return PayeeDesignSystem.isDesktop(width);
  }

  /// 获取网格列数
  int get gridColumns {
    final width = MediaQuery.of(this).size.width;
    return PayeeDesignSystem.getGridColumns(width);
  }
}