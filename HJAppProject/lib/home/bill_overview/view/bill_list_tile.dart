import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:intl/intl.dart';

import 'bills_overview_page.dart';

// ==========================================
// 辅助类：用于封装匹配结果，消除 dynamic 告警
// ==========================================
class CategoryMatch {
  final IconData icon;
  final Color color;

  CategoryMatch({required this.icon, required this.color});
}

// ==========================================
// 智能图标与色彩匹配引擎
// ==========================================
class CategoryIconHelper {
  static final List<Map<String, dynamic>> _rules = [
    // --- 🛒 购物与服饰 (紫色系) ---
    {
      'keywords': ['衣服', '裤子', '鞋', '服饰', '包', '帽', '袜', '外套', '内衣', '打扮'],
      'icon': Icons.checkroom_rounded,
      'color': const Color(0xFFAF52DE)
    },
    {
      'keywords': ['化妆', '护肤', '美妆', '香水', '口红', '面膜', '美容'],
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      'keywords': ['淘宝', '京东', '拼多多', '快递', '网购', '邮费'],
      'icon': Icons.shopping_cart_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords': ['超市', '便利店', '杂货', '纸巾', '沐浴', '洗发', '日用品', '买菜'],
      'icon': Icons.local_grocery_store_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['购物', '买', '消费', '商场', '百货'],
      'icon': Icons.local_mall_rounded,
      'color': const Color(0xFFAF52DE)
    },

    // --- 🍔 餐饮美食 (橙/咖色系) ---
    {
      'keywords': ['咖啡', '星巴克', '瑞幸', '饮品', '奶茶', '喜茶', '水', '饮料'],
      'icon': Icons.local_cafe_rounded,
      'color': const Color(0xFFA2845E)
    },
    {
      'keywords': ['早餐', '包子', '油条', '面包', '烘焙', '蛋糕', '甜品'],
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords': ['酒', '酒吧', '啤酒', 'KTV', '派对'],
      'icon': Icons.local_bar_rounded,
      'color': const Color(0xFF5856D6)
    },
    {
      'keywords': ['外卖', '美团', '饿了么', '快餐', '肯德基', '麦当劳', 'KFC'],
      'icon': Icons.delivery_dining_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords': [
        '餐饮',
        '餐',
        '吃',
        '食',
        '饭',
        '肉',
        '菜',
        '午餐',
        '晚餐',
        '夜宵',
        '零食',
        '烧烤',
        '火锅',
        '海鲜',
        '请客',
        '聚餐'
      ],
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFF9500)
    },

    // --- 🚗 交通出行 (蓝色系) ---
    {
      'keywords': ['公交', '地铁', '巴士', '乘车'],
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['高铁', '火车', '动车', '铁路'],
      'icon': Icons.train_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      'keywords': ['飞机', '航班', '机票', '航空', '机场'],
      'icon': Icons.flight_rounded,
      'color': const Color(0xFF30B0C7)
    },
    {
      'keywords': ['打车', '出租', '滴滴', '网约车', '高德', '打车费'],
      'icon': Icons.local_taxi_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords': ['油费', '加油', '油'],
      'icon': Icons.local_gas_station_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords': ['单车', '自行车', '骑行', '哈啰', '美团单车'],
      'icon': Icons.directions_bike_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords': ['停车', '违章', '保养', '洗车', '维修', 'ETC', '过路费', '高速', '车险'],
      'icon': Icons.car_repair_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords': ['交通', '车', '行', '出行', '路', '费'],
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF007AFF)
    },

    // --- 🏠 居住水电 (棕/灰系) ---
    {
      'keywords': ['水费', '电费', '燃气', '煤气', '水电'],
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords': ['网费', '话费', '宽带', '电信', '联通', '移动', '充值'],
      'icon': Icons.wifi_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['装修', '家具', '家电', '床', '五金', '修理', '家政', '保洁'],
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords': ['房', '住', '租', '物业', '住宿', '酒店', '旅馆', '民宿'],
      'icon': Icons.home_rounded,
      'color': const Color(0xFFA2845E)
    },

    // --- 🎮 娱乐休闲 (粉/紫系) ---
    {
      'keywords': ['游戏', '玩', '充值', '皮肤', '点券', 'Steam', 'Switch', 'PS5', '网吧'],
      'icon': Icons.sports_esports_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      'keywords': ['电影', '影', '剧', '视频', '爱奇艺', '腾讯', '优酷', 'B站', '大会员', '会员'],
      'icon': Icons.movie_rounded,
      'color': const Color(0xFFAF52DE)
    },
    {
      'keywords': ['唱', '音乐', '演唱会', 'QQ音乐', '网易云', 'Live'],
      'icon': Icons.music_note_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords': ['游', '旅游', '门票', '景点', '度假', '露营', '公园'],
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords': ['运动', '健身', '瑜伽', '游泳', '球', '私教', '体育', '跑步'],
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      'keywords': ['娱乐', '休闲', '玩乐', '密室', '剧本杀'],
      'icon': Icons.celebration_rounded,
      'color': const Color(0xFFFF9500)
    },

    // --- 💊 医疗健康 (红/青系) ---
    {
      'keywords': ['药', '买药', '药店', '感冒', '维生素', '保健'],
      'icon': Icons.medication_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['医', '病', '挂号', '体检', '牙', '住院', '诊所', '疫苗', '核酸', '医保'],
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords': ['理疗', '养生', '按摩', '洗浴', '足疗'],
      'icon': Icons.spa_rounded,
      'color': const Color(0xFFAF52DE)
    },

    // --- 📚 教育学习 (靛青系) ---
    {
      'keywords': ['书', '资料', '文具', '笔', '本', '绘本', '阅读', '买书'],
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFA2845E)
    },
    {
      'keywords': ['学', '教', '考', '培训', '课', '补习', '班', '学费', '报名费'],
      'icon': Icons.school_rounded,
      'color': const Color(0xFF5856D6)
    },

    // --- 🎁 人情与家庭 (粉/黄系) ---
    {
      'keywords': ['人情', '礼', '红包', '份子', '结婚', '压岁钱', '捐', '慈善', '孝敬'],
      'icon': Icons.card_giftcard_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords': ['孩', '婴', '奶粉', '尿不湿', '育儿', '玩具', '宝贝', '儿子', '女儿'],
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords': ['宠', '猫', '狗', '粮', '兽医', '驱虫', '宠物'],
      'icon': Icons.pets_rounded,
      'color': const Color(0xFFA2845E)
    },

    // --- 💰 金融理财 (绿/红系) ---
    {
      'keywords': ['理财', '基金', '股', '投资', '收益'],
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFFF3B30)
    }, // 投资收益红色
    {
      'keywords': ['保险', '寿险', '重疾'],
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords': [
        '贷款',
        '还款',
        '信用',
        '借',
        '欠',
        '赔',
        '押金',
        '罚',
        '税',
        '手续费',
        '分期',
        '房贷',
        '车贷',
        '息',
        '利息'
      ],
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF8E8E93)
    },

    // --- 💸 收入相关 (红色系) ---
    {
      'keywords': ['工资', '薪水', '奖金', '分红', '兼职', '外快', '收入', '发钱', '生活费'],
      'icon': Icons.payments_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords': ['退款', '报销', '补贴', '理赔', '公积金'],
      'icon': Icons.price_check_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['二手', '闲鱼', '卖', '转让'],
      'icon': Icons.storefront_rounded,
      'color': const Color(0xFFFF9500)
    },

    // --- 📱 数码与个人护理 ---
    {
      'keywords': [
        '手机',
        '电脑',
        '平板',
        '外设',
        '耳机',
        '键盘',
        '鼠标',
        '数据线',
        '数码',
        '苹果',
        '华为'
      ],
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords': ['理发', '剪', '头发', '美甲', '护发'],
      'icon': Icons.content_cut_rounded,
      'color': const Color(0xFF5856D6)
    },
  ];

  static CategoryMatch match(String categoryName, BillType? billType) {
    if (categoryName.isNotEmpty) {
      for (var rule in _rules) {
        // 核心修改：先强转为 List，这样它就变成了 Iterable
        final List keywords = rule['keywords'] as List;

        for (var kw in keywords) {
          // 确保 kw 被当作 String 处理
          if (categoryName.contains(kw.toString())) {
            return CategoryMatch(
              icon: rule['icon'] as IconData,
              color: rule['color'] as Color,
            );
          }
        }
      }
    }
    // 后备方案
    if (billType == BillType.income) {
      return CategoryMatch(
          icon: Icons.savings_rounded,
          color: FintechTheme.getBillColor(BillType.income));
    }
    if (billType == BillType.expenditure) {
      return CategoryMatch(
          icon: Icons.receipt_rounded,
          color: FintechTheme.getBillColor(BillType.expenditure));
    }
    if (billType == BillType.transfer) {
      return CategoryMatch(
          icon: Icons.sync_alt_rounded,
          color: FintechTheme.getBillColor(BillType.transfer));
    }
    if (billType == BillType.adjust) {
      return CategoryMatch(
          icon: Icons.tune_rounded,
          color: FintechTheme.getBillColor(BillType.adjust));
    }
    if (billType == BillType.advance) {
      return CategoryMatch(
          icon: Icons.payment_rounded,
          color: FintechTheme.getBillColor(BillType.advance));
    }
    if (billType == BillType.reimburse) {
      return CategoryMatch(
          icon: Icons.assignment_return_rounded,
          color: FintechTheme.getBillColor(BillType.reimburse));
    }

    return CategoryMatch(
        icon: Icons.receipt_long_rounded, color: const Color(0xFF8E8E93));
  }
}

class BillListTile extends StatelessWidget {
  const BillListTile({
    required this.bill,
    super.key,
    this.onToggleCompleted,
    this.onDismissed,
    this.onCopy,
    this.onTap,
  });

  final BillItem bill;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final Function? onCopy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 提取分类名
    String categoryName = '';
    if (bill.categoryAmountPair != null &&
        bill.categoryAmountPair!.isNotEmpty) {
      categoryName = bill.categoryAmountPair!
          .map((cat) => cat.categoryName ?? '')
          .where((name) => name.isNotEmpty)
          .join(', ');
    }

    String title = bill.title ?? '';
    if (title.isEmpty && categoryName.isNotEmpty) {
      title = categoryName;
    } else if (categoryName.isNotEmpty && title != categoryName) {
      title = title;
    } else if (title.isEmpty) {
      title = '未命名记录';
    }

    DateFormat formatter = DateFormat('HH:mm');
    String formattedTime = formatter.format(bill.tradeTime ?? DateTime.now());

    // 🚀 核心：调用智能引擎获取专属图标与色彩
    final matchedConfig = CategoryIconHelper.match(categoryName, bill.billType);
    final IconData iconData = matchedConfig.icon;
    final Color iconBgColor = matchedConfig.color;

    // 金额文本与颜色处理 (依据国内习惯：收入红，支出绿)
    String amountText = FintechTheme.formatAmount(bill.convertedAmount ?? 0);
    Color amountColor = (bill.billType == BillType.income)
        ? FintechTheme.getBillColor(BillType.income)
        : FintechTheme.textPrimary; // 支出保持沉稳的黑色

    // 副标题拼接
    List<String> subItems = [];
    if (bill.accountName != null && bill.accountName!.isNotEmpty) {
      subItems.add(bill.accountName!);
    }
    subItems.add(formattedTime);
    String subtitle = subItems.join('  •  ');

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🍎 iOS 设置页经典呈现方式：饱满色彩圆角方块 + 纯白 Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: iconBgColor.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(iconData, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              // 中间文字描述
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: FintechTheme.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: FintechTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (bill.remark != null && bill.remark!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.chat_bubble_text,
                              size: 12, color: Color(0xFFC7C7CC)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 金额
              Text(
                amountText,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Dismissible(
      key: Key('billListTile_dismissible_${bill.billId}'),
      onDismissed: onDismissed,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        if (direction == DismissDirection.endToStart) {
          if (onDismissed != null) {
            return await showCupertinoDialog<bool>(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除这条记录吗？'),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text('取消',
                            style:
                                TextStyle(color: FintechTheme.textSecondary)),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                ) ??
                false;
          }
        } else if (direction == DismissDirection.startToEnd) {
          if (bill.billType == BillType.adjust) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('余额调整账单不支持复制')));
            return false;
          }
          final confirmed = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('是否复制'),
              content: const Text('确定要复制这条记录吗？'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('取消',
                      style: TextStyle(color: FintechTheme.textSecondary)),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                CupertinoDialogAction(
                  child: Text('复制',
                      style: TextStyle(
                          color: FintechTheme.getBillColor(BillType.transfer))),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
          if (confirmed == true) onCopy?.call();
          return false;
        }
        return false;
      },
      background: _buildDismissBackground(true),
      secondaryBackground: _buildDismissBackground(false),
      child: card,
    );
  }

  Widget _buildDismissBackground(bool isPrimary) {
    return Container(
      color: isPrimary
          ? FintechTheme.getBillColor(BillType.transfer)
          : FintechTheme.getBillColor(BillType.income),
      alignment: isPrimary ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Icon(
        isPrimary
            ? CupertinoIcons.doc_on_clipboard_fill
            : CupertinoIcons.delete_solid,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
