import 'package:flutter/material.dart';

/// 应用内图标解析工具。
///
/// 后端 `icon` 字段存储的是 Iconify 图标名（例如 `ep:wallet`），
/// 桌面端通过 Iconify 在线组件渲染；移动端没有 Iconify 运行时，
/// 因此这里维护一份「图标名 → Flutter [IconData]」的映射表，
/// 供图标选择器展示、以及列表/表单中渲染使用。
///
/// 约定：
/// - 自定义图标优先，其次按业务类型取默认图标名，最后回退到具体 IconData；
/// - 未收录的图标名一律回退，不会出现空白占位；
/// - 映射表覆盖常用图标，与桌面端默认图标名保持一致，便于两端数据互通。
class AppIcon {
  const AppIcon._();

  /// 账户：类型缺失时的兜底图标名
  static const String accountFallback = 'ep:wallet';

  /// 分类默认图标名
  static const String categoryFallback = 'ep:menu';

  /// 标签默认图标名
  static const String tagFallback = 'ep:collection-tag';

  /// 成员默认图标名
  static const String memberFallback = 'ep:user';

  /// 交易对象默认图标名
  static const String payeeFallback = 'ep:shop';

  /// 账户类型 → 默认图标名，与桌面端 `accountIcon.ts` 保持一致。
  /// 1 活期 / 2 信用 / 3 资产 / 4 贷款
  static String accountTypeFallback(int? accountType) {
    switch (accountType) {
      case 2:
        return 'ep:credit-card';
      case 3:
        return 'ep:coin';
      case 4:
        return 'ep:money';
      default:
        return accountFallback;
    }
  }

  /// 解析图标名。未收录或为空时返回 null。
  static IconData? resolve(String? name) {
    if (name == null) return null;
    final String key = name.trim();
    if (key.isEmpty) return null;
    return _icons[key];
  }

  /// 解析图标名，未收录时回退到 [fallback]。
  static IconData resolveOr(String? name, IconData fallback) =>
      resolve(name) ?? fallback;

  /// 账户图标：自定义图标 → 账户类型默认图标 → 通用兜底。
  static IconData accountIcon(String? icon, int? accountType) =>
      resolve(icon) ??
      resolve(accountTypeFallback(accountType)) ??
      Icons.account_balance_wallet_outlined;

  /// 全部可解析的图标（图标名 → IconData）。
  static Map<String, IconData> get all => _icons;

  /// 分组后的可选图标，供选择器按类别展示。
  static List<AppIconGroup> get groups => _groups;

  static const Map<String, IconData> _icons = <String, IconData>{
    // ===== 账户与资金 =====
    'ep:wallet': Icons.account_balance_wallet_outlined,
    'ep:credit-card': Icons.credit_card,
    'ep:coin': Icons.monetization_on_outlined,
    'ep:money': Icons.payments_outlined,
    'mdi:bank': Icons.account_balance,
    'mdi:cash': Icons.payments,
    'mdi:piggy-bank': Icons.savings,
    'mdi:savings': Icons.savings_outlined,
    'mdi:chart-line': Icons.trending_up,
    'mdi:currency-cny': Icons.currency_yuan,
    'mdi:hand-coin': Icons.volunteer_activism_outlined,
    'mdi:receipt': Icons.receipt_long_outlined,
    'mdi:bank-transfer': Icons.swap_horiz,
    'mdi:invoice': Icons.request_quote_outlined,
    'mdi:credit-card-outline': Icons.credit_card_outlined,

    // ===== 餐饮购物 =====
    'mdi:food': Icons.restaurant,
    'mdi:food-fork-drink': Icons.restaurant_menu,
    'mdi:noodles': Icons.ramen_dining,
    'mdi:coffee': Icons.local_cafe_outlined,
    'mdi:ice-cream': Icons.icecream_outlined,
    'mdi:glass-cocktail': Icons.local_bar_outlined,
    'mdi:cake': Icons.cake_outlined,
    'mdi:cart': Icons.shopping_cart_outlined,
    'mdi:shopping': Icons.shopping_bag_outlined,
    'mdi:tshirt-crew': Icons.checkroom,
    'mdi:flower': Icons.local_florist_outlined,
    'mdi:gift': Icons.card_giftcard,

    // ===== 交通出行 =====
    'mdi:car': Icons.directions_car_outlined,
    'mdi:bus': Icons.directions_bus_outlined,
    'mdi:train': Icons.train_outlined,
    'mdi:airplane': Icons.flight_outlined,
    'mdi:bike': Icons.pedal_bike_outlined,
    'mdi:taxi': Icons.local_taxi_outlined,
    'mdi:run': Icons.directions_run,
    'mdi:map-marker': Icons.location_on_outlined,

    // ===== 居家生活 =====
    'mdi:home': Icons.home_outlined,
    'mdi:home-city': Icons.apartment_outlined,
    'mdi:phone': Icons.phone_android_outlined,
    'mdi:cellphone': Icons.smartphone,
    'mdi:laptop': Icons.laptop_mac,
    'mdi:wifi': Icons.wifi,
    'mdi:flash': Icons.bolt_outlined,
    'mdi:water': Icons.water_drop_outlined,
    'mdi:fire': Icons.local_fire_department_outlined,
    'mdi:gas-cylinder': Icons.propane_tank_outlined,
    'mdi:washing-machine': Icons.local_laundry_service_outlined,
    'mdi:scissors': Icons.content_cut,
    'mdi:paw': Icons.pets,
    'mdi:baby-carriage': Icons.child_friendly_outlined,

    // ===== 医疗 / 教育 / 娱乐 =====
    'mdi:hospital': Icons.local_hospital_outlined,
    'mdi:pill': Icons.medication_outlined,
    'mdi:school': Icons.school_outlined,
    'mdi:book-open': Icons.menu_book_outlined,
    'mdi:gamepad-variant': Icons.sports_esports_outlined,
    'mdi:movie': Icons.movie_outlined,
    'mdi:music': Icons.music_note_outlined,
    'mdi:basketball': Icons.sports_basketball_outlined,
    'mdi:soccer': Icons.sports_soccer_outlined,
    'mdi:dumbbell': Icons.fitness_center,
    'mdi:beach': Icons.beach_access_outlined,
    'mdi:briefcase': Icons.work_outline,

    // ===== 标签与标记 =====
    'ep:collection-tag': Icons.label_outline,
    'mdi:tag': Icons.local_offer_outlined,
    'mdi:tag-multiple': Icons.sell_outlined,
    'mdi:bookmark': Icons.bookmark_border,
    'mdi:flag': Icons.flag_outlined,
    'mdi:star': Icons.star_border,
    'mdi:heart': Icons.favorite_border,
    'mdi:bell': Icons.notifications_none,
    'mdi:calendar': Icons.calendar_today_outlined,
    'mdi:clock': Icons.schedule,
    'mdi:note': Icons.sticky_note_2_outlined,
    'mdi:lightbulb': Icons.lightbulb_outline,
    'mdi:alert': Icons.warning_amber_outlined,
    'mdi:check-circle': Icons.check_circle_outline,
    'mdi:close-circle': Icons.cancel_outlined,
    'mdi:information': Icons.info_outline,
    'ep:menu': Icons.category_outlined,

    // ===== 成员与人物 =====
    'ep:user': Icons.person_outline,
    'mdi:account': Icons.person_outline,
    'mdi:account-multiple': Icons.people_outline,
    'mdi:account-group': Icons.group_outlined,
    'mdi:human-male': Icons.man_outlined,
    'mdi:human-female': Icons.woman_outlined,
    'mdi:human-male-boy': Icons.boy_outlined,
    'mdi:human-female-girl': Icons.girl_outlined,
    'mdi:baby': Icons.child_care_outlined,
    'mdi:human-cane': Icons.elderly_outlined,
    'mdi:face-man': Icons.face_outlined,
    'mdi:account-child': Icons.escalator_warning_outlined,

    // ===== 商户与机构 =====
    'ep:shop': Icons.storefront_outlined,
    'mdi:store': Icons.store_outlined,
    'mdi:storefront': Icons.storefront,
    'mdi:silverware-fork-knife': Icons.restaurant_outlined,
    'mdi:hotel': Icons.hotel_outlined,
    'mdi:hospital-box': Icons.local_hospital_outlined,
    'mdi:domain': Icons.domain_outlined,
    'mdi:office-building': Icons.business_outlined,
    'mdi:web': Icons.language_outlined,
    'mdi:factory': Icons.factory_outlined,
  };

  static const List<AppIconGroup> _groups = <AppIconGroup>[
    AppIconGroup('账户与资金', <String>[
      'ep:wallet',
      'ep:credit-card',
      'ep:coin',
      'ep:money',
      'mdi:bank',
      'mdi:cash',
      'mdi:piggy-bank',
      'mdi:savings',
      'mdi:chart-line',
      'mdi:currency-cny',
      'mdi:hand-coin',
      'mdi:receipt',
      'mdi:bank-transfer',
      'mdi:invoice',
      'mdi:credit-card-outline',
    ]),
    AppIconGroup('餐饮购物', <String>[
      'mdi:food',
      'mdi:food-fork-drink',
      'mdi:noodles',
      'mdi:coffee',
      'mdi:ice-cream',
      'mdi:glass-cocktail',
      'mdi:cake',
      'mdi:cart',
      'mdi:shopping',
      'mdi:tshirt-crew',
      'mdi:flower',
      'mdi:gift',
    ]),
    AppIconGroup('交通出行', <String>[
      'mdi:car',
      'mdi:bus',
      'mdi:train',
      'mdi:airplane',
      'mdi:bike',
      'mdi:taxi',
      'mdi:run',
      'mdi:map-marker',
    ]),
    AppIconGroup('居家生活', <String>[
      'mdi:home',
      'mdi:home-city',
      'mdi:phone',
      'mdi:cellphone',
      'mdi:laptop',
      'mdi:wifi',
      'mdi:flash',
      'mdi:water',
      'mdi:fire',
      'mdi:gas-cylinder',
      'mdi:washing-machine',
      'mdi:scissors',
      'mdi:paw',
      'mdi:baby-carriage',
    ]),
    AppIconGroup('医疗 / 教育 / 娱乐', <String>[
      'mdi:hospital',
      'mdi:pill',
      'mdi:school',
      'mdi:book-open',
      'mdi:gamepad-variant',
      'mdi:movie',
      'mdi:music',
      'mdi:basketball',
      'mdi:soccer',
      'mdi:dumbbell',
      'mdi:beach',
      'mdi:briefcase',
    ]),
    AppIconGroup('标签与标记', <String>[
      'ep:collection-tag',
      'mdi:tag',
      'mdi:tag-multiple',
      'mdi:bookmark',
      'mdi:flag',
      'mdi:star',
      'mdi:heart',
      'mdi:bell',
      'mdi:calendar',
      'mdi:clock',
      'mdi:note',
      'mdi:lightbulb',
      'mdi:alert',
      'mdi:check-circle',
      'mdi:close-circle',
      'mdi:information',
      'ep:menu',
    ]),
    AppIconGroup('成员与人物', <String>[
      'ep:user',
      'mdi:account',
      'mdi:account-multiple',
      'mdi:account-group',
      'mdi:human-male',
      'mdi:human-female',
      'mdi:human-male-boy',
      'mdi:human-female-girl',
      'mdi:baby',
      'mdi:human-cane',
      'mdi:face-man',
      'mdi:account-child',
    ]),
    AppIconGroup('商户与机构', <String>[
      'ep:shop',
      'mdi:store',
      'mdi:storefront',
      'mdi:silverware-fork-knife',
      'mdi:hotel',
      'mdi:hospital-box',
      'mdi:domain',
      'mdi:office-building',
      'mdi:web',
      'mdi:factory',
    ]),
  ];
}

/// 图标分组，供 [AppIcon.groups] 使用。
class AppIconGroup {
  const AppIconGroup(this.label, this.names);

  /// 分组标题
  final String label;

  /// 该分组下的图标名
  final List<String> names;
}
