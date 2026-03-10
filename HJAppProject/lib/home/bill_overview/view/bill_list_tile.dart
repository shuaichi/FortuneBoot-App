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
    // ==========================================
    // 🛒 购物与服饰 (紫色系)
    // ==========================================
    {
      'keywords':['衣服', '裤子', '鞋', '服饰', '包', '帽', '袜', '外套', '内衣', '打扮', '衣服饰品', '衣服裤子', '鞋帽包包', '衣着', '配饰', '鞋帽', 'T恤', '秋裤', '羽绒服', '袜子', '内裤', '褂子', '鞋子', '洗衣服'],
      'icon': Icons.checkroom_rounded,
      'color': const Color(0xFFAF52DE)
    },
    {
      'keywords':['化妆', '护肤', '美妆', '香水', '口红', '面膜', '美容', '化妆饰品', '形象维护', '护肤美妆', '洗漱类', '个人护理', '剪头', '眼镜', '美容费'],
      'icon': Icons.face_retouching_natural_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      'keywords':['淘宝', '京东', '拼多多', '快递', '网购', '邮费', '零售商'],
      'icon': Icons.shopping_cart_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords':['超市', '便利店', '杂货', '纸巾', '沐浴', '洗发', '日用品', '买菜', '维持类', '消费类', '日常用品', '日用', '清洁', '生活物资', '消防类'],
      'icon': Icons.local_grocery_store_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords':['购物', '买', '消费', '商场', '百货', '盲盒', '乐高'],
      'icon': Icons.local_mall_rounded,
      'color': const Color(0xFFAF52DE)
    },

    // ==========================================
    // 🍔 餐饮美食 (橙/咖色系)
    // ==========================================
    {
      'keywords':['咖啡', '星巴克', '瑞幸', '饮品', '奶茶', '喜茶', '水', '饮料', '烟酒茶', '烟酒', '饮用水', '牛奶'],
      'icon': Icons.local_cafe_rounded,
      'color': const Color(0xFFA2845E)
    },
    {
      'keywords':['早餐', '包子', '油条', '面包', '烘焙', '蛋糕', '甜品', '早午晚餐', '早饭', '午饭', '晚饭'],
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords':['酒', '酒吧', '啤酒', 'KTV', '派对', '烟', 'ktv'],
      'icon': Icons.local_bar_rounded,
      'color': const Color(0xFF5856D6)
    },
    {
      'keywords':['外卖', '美团', '饿了么', '快餐', '肯德基', '麦当劳', 'KFC', '堂食'],
      'icon': Icons.delivery_dining_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords':['餐饮', '餐', '吃', '食', '饭', '肉', '菜', '午餐', '晚餐', '夜宵', '零食', '烧烤', '火锅', '海鲜', '请客', '聚餐', '蔬菜', '调料', '干货', '肉类', '食品酒水', '饮食消费', '饮食', '水果', '餐饮食品', '食物', '粮油调味', '厨具', '吃饭', '腐败聚会'],
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFFF9500)
    },

    // ==========================================
    // 🚗 交通出行 (蓝色系)
    // ==========================================
    {
      'keywords':['公交', '地铁', '巴士', '乘车', '公共交通', '交通卡'],
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords':['高铁', '火车', '动车', '铁路', '出差-高铁'],
      'icon': Icons.train_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      'keywords': ['飞机', '航班', '机票', '航空', '机场', '出差-飞机'],
      'icon': Icons.flight_rounded,
      'color': const Color(0xFF30B0C7)
    },
    {
      'keywords':['打车', '出租', '滴滴', '网约车', '高德', '打车费', '打车租车', '顺风车', '租车', '出差-打车'],
      'icon': Icons.local_taxi_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords':['油费', '加油', '油', '燃料', '汽油', '加油充电', '充电'],
      'icon': Icons.local_gas_station_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords':['单车', '自行车', '骑行', '哈啰', '美团单车', '共享单车', '电动车'],
      'icon': Icons.directions_bike_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords':['停车', '违章', '保养', '洗车', '维修', 'ETC', '过路费', '高速', '车险', '私家车费用', '养车', '违章罚款', '年检', '车辆维修', '停车费', '买车养车'],
      'icon': Icons.car_repair_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords':['交通', '车', '行', '出行', '路', '费', '汽车消费', '汽车'],
      'icon': Icons.directions_car_rounded,
      'color': const Color(0xFF007AFF)
    },

    // ==========================================
    // 🏠 居住水电 (棕/灰系)
    // ==========================================
    {
      'keywords':['水费', '电费', '燃气', '煤气', '水电', '天然气', '水电煤气'],
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFCC00)
    },
    {
      'keywords':['网费', '话费', '宽带', '电信', '联通', '移动', '充值', '交流通讯', '座机费', '手机费', '上网费', '邮寄费', '通讯娱乐', '通讯', 'vpn'],
      'icon': Icons.wifi_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords':['装修', '家具', '家电', '床', '五金', '修理', '家政', '保洁', '维修保养', '居家物业', '居家生活', '家具家电', '智能家居', '厨房电器', '卫浴电器', '电器', '热水器', '空调', '插线板', '打气筒', '冰箱', '热水壶', '咖啡机', '加湿器', '空气炸锅', '门锁', '智能家具', '桌椅类', '寝具类', '储物类', '装饰类', '户外类', '配件类'],
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords':['房', '住', '租', '物业', '住宿', '酒店', '旅馆', '民宿', '物业费', '房租', '物业管理', '生活必要支出', '住房相关', '居住', '房产相关', '房屋税费', '出租', '管理费', '中介费', '出差-酒店'],
      'icon': Icons.home_rounded,
      'color': const Color(0xFFA2845E)
    },

    // ==========================================
    // 🎮 娱乐休闲 (粉/紫系)
    // ==========================================
    {
      'keywords':['游戏', '玩', '充值', '皮肤', '点券', 'Steam', 'Switch', 'PS5', '网吧', '休闲娱乐', 'QQ飞车', 'switch游戏', 'xbox游戏', '点卡', '游戏机', 'xbox', 'switch'],
      'icon': Icons.sports_esports_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      'keywords':['电影', '影', '剧', '视频', '爱奇艺', '腾讯', '优酷', 'B站', '大会员', '会员', '外卖会员', '小说'],
      'icon': Icons.movie_rounded,
      'color': const Color(0xFFAF52DE)
    },
    {
      'keywords':['唱', '音乐', '演唱会', 'QQ音乐', '网易云', 'Live', 'K歌'],
      'icon': Icons.music_note_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords':['游', '旅游', '门票', '景点', '度假', '露营', '公园', '旅游度假', '漫展'],
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords':['运动', '健身', '瑜伽', '游泳', '球', '私教', '体育', '跑步', '运动健身', '羽毛球'],
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      'keywords':['娱乐', '休闲', '玩乐', '密室', '剧本杀', '文化休闲', '桌游'],
      'icon': Icons.celebration_rounded,
      'color': const Color(0xFFFF9500)
    },

    // ==========================================
    // 💊 医疗健康 (红/青系)
    // ==========================================
    {
      'keywords':['药', '买药', '药店', '感冒', '维生素', '保健', '药品费', '保健费', '保健品', '药品', '药物'],
      'icon': Icons.medication_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords':['医', '病', '挂号', '体检', '牙', '住院', '诊所', '疫苗', '核酸', '医保', '医疗机构', '医疗保健', '治疗费', '医疗健康', '医疗', '牙科', '治疗', '医疗护理', '门诊', '急诊', '近视', '互联网医疗', '洗牙', '医保报销'],
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords':['理疗', '养生', '按摩', '洗浴', '足疗'],
      'icon': Icons.spa_rounded,
      'color': const Color(0xFFAF52DE)
    },

    // ==========================================
    // 📚 教育学习 (靛青系)
    // ==========================================
    {
      'keywords':['书', '资料', '文具', '笔', '本', '绘本', '阅读', '买书', '学习进修', '书报杂志', '教育工具', '书籍'],
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFA2845E)
    },
    {
      'keywords':['学', '教', '考', '培训', '课', '补习', '班', '学费', '报名费', '提升类', '教育机构', '培训进修', '教育成长支出', '子女教育', '成人学习', '教育', '培训考试', '学习教育', '学杂费', '校园', '学习', '考试', '网课', '自习室'],
      'icon': Icons.school_rounded,
      'color': const Color(0xFF5856D6)
    },

    // ==========================================
    // 🎁 人情与家庭 (粉/黄系)
    // ==========================================
    {
      'keywords':['人情', '礼', '红包', '份子', '结婚', '压岁钱', '捐', '慈善', '孝敬', '社交类', '人情往来', '送礼请客', '孝敬家长', '还人钱物', '慈善捐助', '公益捐款', '送礼', '礼物', '捐款', '爱心', '礼金', '份子钱', '社交', '礼品', '团建'],
      'icon': Icons.card_giftcard_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords':['孩', '婴', '奶粉', '尿不湿', '育儿', '玩具', '宝贝', '儿子', '女儿', '赡养抚养支出', '抚养子女'],
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFFFF9500)
    },
    {
      'keywords':['宠', '猫', '狗', '粮', '兽医', '驱虫', '宠物', '宠物宝贝', '萌宠', '宠物玩具'],
      'icon': Icons.pets_rounded,
      'color': const Color(0xFFA2845E)
    },

    // ==========================================
    // 💰 金融理财 (绿/红/灰系)
    // ==========================================
    {
      'keywords':['理财', '基金', '股', '投资', '收益', '被动收入', '资产增值', '其他被动', '金融理财', '投资收益', '利息', '股票', '炒股', '返利金', '平台返利', '羊毛', '薅羊毛', '计提收益', '额外福利', '知识产权', '意外所得', '彩票'],
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFFFF3B30) // 投资收益红色
    },
    {
      'keywords':['保险', '寿险', '重疾', '金融保险', '风险保障支出', '保险费用', '健康险', '财险', '意外险', '五险一金'],
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF34C759)
    },
    {
      'keywords':['贷款', '还款', '信用', '借', '欠', '赔', '押金', '罚', '税', '手续费', '分期', '房贷', '车贷', '息', '利息', '税务部门', '银行手续', '投资亏损', '按揭还款', '消费税收', '利息支出', '赔偿罚款', '烂账损失', '债务偿还支出', '信用卡还款', '消费贷款', '房贷车贷', '其他负债', '税费及其他支出', '房屋税费', '车辆税费', '计提亏损', '偿还本金', '偿还利息', '借款', '花呗还款', '白条还款', '刷卡金', '应付款项'],
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF8E8E93)
    },

    // ==========================================
    // 💸 收入相关 (红色系)
    // ==========================================
    {
      'keywords':['工资', '薪水', '奖金', '分红', '兼职', '外快', '收入', '发钱', '生活费', '主动收入', '兼职副业', '技能变现', '员工', '年终奖', '工龄收入', '工龄', '打工', '零花钱', '奖学金', '社交收入', '工资薪金'],
      'icon': Icons.payments_rounded,
      'color': const Color(0xFFFF3B30)
    },
    {
      'keywords':['退款', '报销', '补贴', '理赔', '公积金', '转移性收入', '社会福利', '其他转移', '退税', '补助', '充值赠款'],
      'icon': Icons.price_check_rounded,
      'color': const Color(0xFF32ADE6)
    },
    {
      'keywords': ['二手', '闲鱼', '卖', '转让', '出售二手物品'],
      'icon': Icons.storefront_rounded,
      'color': const Color(0xFFFF9500)
    },

    // ==========================================
    // 📱 数码与个人护理 (灰/紫系)
    // ==========================================
    {
      'keywords':['手机', '电脑', '平板', '外设', '耳机', '键盘', '鼠标', '数据线', '数码', '苹果', '华为', '电子产品', '手表', '壳', '电视', '其他电子产品', '电脑配件', '智能穿戴', '电子数码', '配件耗材'],
      'icon': Icons.devices_rounded,
      'color': const Color(0xFF8E8E93)
    },
    {
      'keywords':['理发', '剪', '头发', '美甲', '护发'],
      'icon': Icons.content_cut_rounded,
      'color': const Color(0xFF5856D6)
    },

    // ==========================================
    // 🚀 新增补充域：科技、商务与人际杂项
    // ==========================================
    {
      // 科技与云服务生产力 (暗色科技感)
      'keywords':['平台企业', 'cdn', '网心云', '京东云无限宝', '服务器', 'NAS', '开源', '云资源', 'PCDN', '软件'],
      'icon': Icons.dns_rounded,
      'color': const Color(0xFF48484A)
    },
    {
      // 银行与资金流转中枢 (金融蓝)
      'keywords':['金融', '银行', '账户互转', '群收款', '资金往来', '应收款项', '储蓄转移', '工商银行', '招商银行', '广发银行', '农业银行', '腾讯'],
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      // 家庭长辈互通 (暖心红)
      'keywords':['赡养父母', '其他亲属', '家庭支持', '父母', '长辈'],
      'icon': Icons.family_restroom_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      // 恋爱与伴侣 (浪漫粉)
      'keywords':['恋爱', '约会'],
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF2D55)
    },
    {
      // 办公与公司事务 (商务蓝)
      'keywords':['服务商', '制造商', '原材料', '设备', '门店', '营销', '招聘', '办公', '差旅', '公司', '公司事务', '办证', '证件照', '福利', '教育机构', '公共服务机构', '医疗机构'],
      'icon': Icons.business_center_rounded,
      'color': const Color(0xFF007AFF)
    },
    {
      // 偶发与其他杂项 (低调灰)
      'keywords':['个人', '其它', '其他杂项', '意外丢失', '偶发杂项', '其他支出', '其他', '智商税', '充值卡', 'app store', '校园卡'],
      'icon': Icons.more_horiz_rounded,
      'color': const Color(0xFF8E8E93)
    },
  ];

  /// 🚀 高级多维度权重匹配引擎
  static CategoryMatch match(BillItem bill) {
    int bestScore = -1;
    CategoryMatch? bestMatch;

    // 1. 提取所有可能包含信息的文本，并赋予初始权重
    // 权重：分类(100) > 标签(50) > 交易对象(10)
    final Map<String, int> textSources = {};

    // 1.1 提取分类
    if (bill.categoryAmountPair != null) {
      for (var cat in bill.categoryAmountPair!) {
        if (cat.categoryName != null && cat.categoryName!.isNotEmpty) {
          textSources[cat.categoryName!] = 100;
        }
      }
    }

    // 1.2 提取标签 (使用 putIfAbsent 确保如果标签和分类同名，保留分类的高权重)
    if (bill.tagList != null) {
      for (var tag in bill.tagList!) {
        if (tag.tagName != null && tag.tagName!.isNotEmpty) {
          textSources.putIfAbsent(tag.tagName!, () => 50);
        }
      }
    }

    // 1.3 提取交易对象
    if (bill.payeeName != null && bill.payeeName!.isNotEmpty) {
      textSources.putIfAbsent(bill.payeeName!, () => 10);
    }

    // 如果没有任何文本信息，直接走后备方案
    if (textSources.isEmpty) {
      return _fallback(bill.billType);
    }

    // 2. 遍历规则库，进行评分计算
    for (var rule in _rules) {
      final List keywords = rule['keywords'] as List;

      for (var kw in keywords) {
        final String keyword = kw.toString();

        for (var entry in textSources.entries) {
          final String sourceText = entry.key;
          final int baseWeight = entry.value;

          int currentScore = 0;

          // 核心打分逻辑：
          // 完全匹配 (Exact Match) 获得 10 倍加成
          // 模糊匹配 (Contains) 获得 2 倍加成
          // 关键词长度 (Length) 作为特异性加成（词越长越精准）
          if (sourceText == keyword) {
            currentScore = baseWeight * 10 * keyword.length;
          } else if (sourceText.contains(keyword)) {
            currentScore = baseWeight * 2 * keyword.length;
          }

          // 稳定性保证：严格使用 > (不使用 >=)
          // 确保分数相同时，永远是列表排在前面的规则和最高优先级的字段获胜
          if (currentScore > bestScore) {
            bestScore = currentScore;
            bestMatch = CategoryMatch(
              icon: rule['icon'] as IconData,
              color: rule['color'] as Color,
            );
          }
        }
      }
    }

    // 3. 返回最高分匹配项，若都未命中则降级到默认账单类型
    return bestMatch ?? _fallback(bill.billType);
  }

  /// 默认后备方案 (按照资金流向类型给色)
  static CategoryMatch _fallback(BillType? billType) {
    if (billType == BillType.income) {
      return CategoryMatch(icon: Icons.savings_rounded, color: FintechTheme.getBillColor(BillType.income));
    }
    if (billType == BillType.expenditure) {
      return CategoryMatch(icon: Icons.receipt_rounded, color: FintechTheme.getBillColor(BillType.expenditure));
    }
    if (billType == BillType.transfer) {
      return CategoryMatch(icon: Icons.sync_alt_rounded, color: FintechTheme.getBillColor(BillType.transfer));
    }
    if (billType == BillType.adjust) {
      return CategoryMatch(icon: Icons.tune_rounded, color: FintechTheme.getBillColor(BillType.adjust));
    }
    if (billType == BillType.advance) {
      return CategoryMatch(icon: Icons.payment_rounded, color: FintechTheme.getBillColor(BillType.advance));
    }
    if (billType == BillType.reimburse) {
      return CategoryMatch(icon: Icons.assignment_return_rounded, color: FintechTheme.getBillColor(BillType.reimburse));
    }
    return CategoryMatch(icon: Icons.help_outline_rounded, color: const Color(0xFF8E8E93));
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
    final matchedConfig = CategoryIconHelper.match(bill);
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
