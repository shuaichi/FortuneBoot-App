import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:intl/intl.dart';

import 'bills_overview_page.dart';

// ==========================================
// 1. 实体与强类型定义
// ==========================================
class CategoryMatch {
  final IconData icon;
  final Color color;

  CategoryMatch({required this.icon, required this.color});
}

/// 类别领域实体 (增加了唯一的 ID，并重写 hashCode 和 ==)
class CategoryDomain {
  final String id; // 例如: 'shopping', 'food'
  final IconData icon;
  final Color color;

  const CategoryDomain({required this.id, required this.icon, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoryDomain && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// 强类型的规则类
class CategoryRule {
  final CategoryDomain domain;
  final List<String> merchants; // 商户特征 (强特征，权重最高)
  final List<String> keywords;  // 关键词特征 (中等特征)

  CategoryRule({
    required this.domain,
    this.merchants = const [],
    this.keywords = const[],
  });
}

// ==========================================
// 2. 字典树 (Trie) 实现 - (解决问题 1：支持多 Domain 挂载)
// ==========================================
class TrieNode {
  final Map<String, TrieNode> children = {};
  List<CategoryDomain> domains =[]; // 改为 List，防止关键词冲突覆盖
  String? keyword;
}

class TrieMatchResult {
  final String keyword;
  final List<CategoryDomain> domains;
  TrieMatchResult(this.keyword, this.domains);
}

class KeywordTrie {
  final TrieNode root = TrieNode();

  void insert(String keyword, CategoryDomain domain) {
    if (keyword.isEmpty) return;
    TrieNode current = root;
    for (int i = 0; i < keyword.length; i++) {
      final char = keyword[i];
      current.children.putIfAbsent(char, () => TrieNode());
      current = current.children[char]!;
    }
    // 防止重复添加相同的 domain
    if (!current.domains.contains(domain)) {
      current.domains.add(domain);
    }
    current.keyword = keyword;
  }

  List<TrieMatchResult> scanText(String text) {
    List<TrieMatchResult> results =[];
    if (text.isEmpty) return results;

    for (int i = 0; i < text.length; i++) {
      TrieNode current = root;
      int j = i;
      List<CategoryDomain>? lastMatchDomains;
      String? lastMatchKeyword;

      while (j < text.length && current.children.containsKey(text[j])) {
        current = current.children[text[j]]!;
        if (current.domains.isNotEmpty) {
          lastMatchDomains = current.domains;
          lastMatchKeyword = current.keyword;
        }
        j++;
      }

      if (lastMatchDomains != null && lastMatchKeyword != null) {
        results.add(TrieMatchResult(lastMatchKeyword, lastMatchDomains));
        i += lastMatchKeyword.length - 1; // 跳过已匹配部分
      }
    }
    return results;
  }
}

// ==========================================
// 3. 智能图标与色彩匹配引擎
// ==========================================
class SmartCategoryEngine {
  static final SmartCategoryEngine _instance = SmartCategoryEngine._internal();
  factory SmartCategoryEngine() => _instance;

  // 核心架构：商户索引 + 关键词索引 + Trie 兜底
  final Map<String, List<CategoryDomain>> _merchantIndex = {}; // 存放星巴克、滴滴等
  final Map<String, List<CategoryDomain>> _keywordIndex = {};  // 存放餐饮、交通等
  final KeywordTrie _trie = KeywordTrie();

  bool _isInitialized = false;

  SmartCategoryEngine._internal() {
    _initEngine();
  }

  void _initEngine() {
    if (_isInitialized) return;

    // 使用强类型定义规则
    final List<CategoryRule> rules =[// 🛒 购物
      CategoryRule(
        domain: const CategoryDomain(id: 'shopping', icon: Icons.shopping_cart_rounded, color: Color(0xFFFF9500)),
        merchants:['淘宝', '京东', '拼多多', '天猫'], // 强商户特征
        keywords:['衣服', '裤子', '鞋', '包', '超市', '便利店', '购物','快递', '网购', '邮费'], // 普通关键词
      ),
      // 🍔 餐饮
      CategoryRule(
        domain: const CategoryDomain(id: 'food', icon: Icons.restaurant_rounded, color: Color(0xFFFF9500)),
        merchants:['星巴克', '瑞幸', '肯德基', '麦当劳', '美团', '饿了么'],
        keywords: ['咖啡', '外卖', '早餐', '餐饮', '零食','餐', '吃', '食', '饭', '肉', '菜', '午餐', '晚餐', '夜宵', '烧烤', '火锅', '海鲜', '请客', '聚餐', '蔬菜', '调料', '干货', '肉类', '食品酒水', '饮食消费', '饮食', '水果', '餐饮食品', '食物', '粮油调味', '厨具', '吃饭'],
      ),
      // 🚗 交通
      CategoryRule(
        domain: const CategoryDomain(id: 'transport', icon: Icons.directions_car_rounded, color: Color(0xFF007AFF)),
        merchants:['滴滴', '高德打车', '哈啰', '铁路12306', '中国石化', '中国石油'],
        keywords:['公交', '地铁', '打车', '油费', '停车', '机票','交通', '车', '行', '出行', '路', '费', '汽车消费', '汽车'],
      ),
      // 🎮 娱乐 (包含冲突词 "充值")
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment', icon: Icons.sports_esports_rounded, color: Color(0xFFFF2D55)),
        merchants:['Steam', 'App Store', '腾讯游戏', '网易游戏','Switch', 'PS5', 'QQ飞车', 'xbox', 'switch'],
        keywords:['游戏', '充值', '电影', '会员', 'KTV','玩', '皮肤', '点券', '网吧', '休闲娱乐', 'switch游戏', 'xbox游戏', '点卡', '游戏机'],
      ),
      // 🏠 水电煤/通讯 (包含冲突词 "充值")
      CategoryRule(
        domain: const CategoryDomain(id: 'utilities', icon: Icons.wifi_rounded, color: Color(0xFF32ADE6)),
        merchants:['国家电网', '中国移动', '中国联通', '中国电信','电信', '联通', '移动'],
        keywords:['话费', '充值', '电费', '水费', '宽带','网费', '交流通讯', '座机费', '手机费', '上网费', '邮寄费', '通讯娱乐', '通讯', 'vpn'],
      ),
      // 🏦 金融与转账
      CategoryRule(
        domain: const CategoryDomain(id: 'finance', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF8E8E93)),
        merchants:['工商银行', '招商银行', '支付宝', '微信支付', '广发银行', '农业银行', '腾讯'],
        keywords:['转账', '理财', '红包', '收款','金融', '银行', '账户互转', '群收款', '资金往来', '应收款项', '储蓄转移'],
      ),
// 🛒 购物与服饰
      CategoryRule(
        domain: const CategoryDomain(id: 'shopping_clothing', icon: Icons.checkroom_rounded, color: Color(0xFFAF52DE)),
        keywords:['衣服', '裤子', '鞋', '服饰', '包', '帽', '袜', '外套', '内衣', '打扮', '衣服饰品', '衣服裤子', '鞋帽包包', '衣着', '配饰', '鞋帽', 'T恤', '秋裤', '羽绒服', '袜子', '内裤', '褂子', '鞋子', '洗衣服'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'shopping_beauty', icon: Icons.face_retouching_natural_rounded, color: Color(0xFFFF2D55)),
        keywords:['化妆', '护肤', '美妆', '香水', '口红', '面膜', '美容', '化妆饰品', '形象维护', '护肤美妆', '洗漱类', '个人护理', '剪头', '眼镜', '美容费'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'shopping_grocery', icon: Icons.local_grocery_store_rounded, color: Color(0xFF32ADE6)),
        keywords:['超市', '便利店', '杂货', '纸巾', '沐浴', '洗发', '日用品', '买菜', '维持类', '消费类', '日常用品', '日用', '清洁', '生活物资', '消防类'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'shopping_general', icon: Icons.local_mall_rounded, color: Color(0xFFAF52DE)),
        merchants: ['乐高'],
        keywords:['购物', '买', '消费', '商场', '百货', '盲盒'],
      ),

// 🍔 餐饮美食
      CategoryRule(
        domain: const CategoryDomain(id: 'food_coffee', icon: Icons.local_cafe_rounded, color: Color(0xFFA2845E)),
        merchants:['星巴克', '瑞幸', '喜茶'],
        keywords:['咖啡', '饮品', '奶茶', '水', '饮料', '烟酒茶', '烟酒', '饮用水', '牛奶'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'food_bakery', icon: Icons.bakery_dining_rounded, color: Color(0xFFFFCC00)),
        keywords:['早餐', '包子', '油条', '面包', '烘焙', '蛋糕', '甜品', '早午晚餐', '早饭', '午饭', '晚饭'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'food_bar', icon: Icons.local_bar_rounded, color: Color(0xFF5856D6)),
        keywords:['酒', '酒吧', '啤酒', 'KTV', '派对', '烟', 'ktv'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'food_fastfood', icon: Icons.delivery_dining_rounded, color: Color(0xFFFF9500)),
        merchants:['美团', '饿了么', '肯德基', '麦当劳', 'KFC'],
        keywords:['外卖', '快餐', '堂食'],
      ),

// 🚗 交通出行
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_bus', icon: Icons.directions_bus_rounded, color: Color(0xFF32ADE6)),
        keywords:['公交', '地铁', '巴士', '乘车', '公共交通', '交通卡'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_train', icon: Icons.train_rounded, color: Color(0xFF007AFF)),
        keywords:['高铁', '火车', '动车', '铁路', '出差-高铁'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_flight', icon: Icons.flight_rounded, color: Color(0xFF30B0C7)),
        keywords:['飞机', '航班', '机票', '航空', '机场', '出差-飞机'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_taxi', icon: Icons.local_taxi_rounded, color: Color(0xFFFFCC00)),
        merchants: ['滴滴', '高德'],
        keywords:['打车', '出租', '网约车', '打车费', '打车租车', '顺风车', '租车', '出差-打车'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_gas', icon: Icons.local_gas_station_rounded, color: Color(0xFFFF3B30)),
        keywords:['油费', '加油', '油', '燃料', '汽油', '加油充电', '充电'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_bike', icon: Icons.directions_bike_rounded, color: Color(0xFF34C759)),
        merchants:['哈啰', '美团单车'],
        keywords:['单车', '自行车', '骑行', '共享单车', '电动车'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'transport_repair', icon: Icons.car_repair_rounded, color: Color(0xFF8E8E93)),
        merchants: ['ETC'],
        keywords:['停车', '违章', '保养', '洗车', '维修', '过路费', '高速', '车险', '私家车费用', '养车', '违章罚款', '年检', '车辆维修', '停车费', '买车养车'],
      ),

// 🏠 居住水电
      CategoryRule(
        domain: const CategoryDomain(id: 'utilities_energy', icon: Icons.lightbulb_rounded, color: Color(0xFFFFCC00)),
        keywords:['水费', '电费', '燃气', '煤气', '水电', '天然气', '水电煤气'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'utilities_repair', icon: Icons.handyman_rounded, color: Color(0xFF8E8E93)),
        keywords:['装修', '家具', '家电', '床', '五金', '修理', '家政', '保洁', '维修保养', '居家物业', '居家生活', '家具家电', '智能家居', '厨房电器', '卫浴电器', '电器', '热水器', '空调', '插线板', '打气筒', '冰箱', '热水壶', '咖啡机', '加湿器', '空气炸锅', '门锁', '智能家具', '桌椅类', '寝具类', '储物类', '装饰类', '户外类', '配件类'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'utilities_rent', icon: Icons.home_rounded, color: Color(0xFFA2845E)),
        keywords:['房', '住', '租', '物业', '住宿', '酒店', '旅馆', '民宿', '物业费', '房租', '物业管理', '生活必要支出', '住房相关', '居住', '房产相关', '房屋税费', '出租', '管理费', '中介费', '出差-酒店'],
      ),

// 🎮 娱乐休闲
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment_movie', icon: Icons.movie_rounded, color: Color(0xFFAF52DE)),
        merchants: ['爱奇艺', '腾讯', '优酷', 'B站'],
        keywords:['电影', '影', '剧', '视频', '大会员', '会员', '外卖会员', '小说'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment_music', icon: Icons.music_note_rounded, color: Color(0xFFFF3B30)),
        merchants: ['QQ音乐', '网易云'],
        keywords:['唱', '音乐', '演唱会', 'Live', 'K歌'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment_travel', icon: Icons.landscape_rounded, color: Color(0xFF34C759)),
        keywords:['游', '旅游', '门票', '景点', '度假', '露营', '公园', '旅游度假', '漫展'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment_sport', icon: Icons.fitness_center_rounded, color: Color(0xFF007AFF)),
        keywords:['运动', '健身', '瑜伽', '游泳', '球', '私教', '体育', '跑步', '运动健身', '羽毛球'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'entertainment_leisure', icon: Icons.celebration_rounded, color: Color(0xFFFF9500)),
        keywords:['娱乐', '休闲', '玩乐', '密室', '剧本杀', '文化休闲', '桌游'],
      ),

// 💊 医疗健康
      CategoryRule(
        domain: const CategoryDomain(id: 'medical_medicine', icon: Icons.medication_rounded, color: Color(0xFF32ADE6)),
        keywords:['药', '买药', '药店', '感冒', '维生素', '保健', '药品费', '保健费', '保健品', '药品', '药物'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'medical_hospital', icon: Icons.medical_services_rounded, color: Color(0xFFFF3B30)),
        keywords:['医', '病', '挂号', '体检', '牙', '住院', '诊所', '疫苗', '核酸', '医保', '医疗机构', '医疗保健', '治疗费', '医疗健康', '医疗', '牙科', '治疗', '医疗护理', '门诊', '急诊', '近视', '互联网医疗', '洗牙', '医保报销'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'medical_spa', icon: Icons.spa_rounded, color: Color(0xFFAF52DE)),
        keywords:['理疗', '养生', '按摩', '洗浴', '足疗'],
      ),

// 📚 教育学习
      CategoryRule(
        domain: const CategoryDomain(id: 'education_books', icon: Icons.menu_book_rounded, color: Color(0xFFA2845E)),
        keywords:['书', '资料', '文具', '笔', '本', '绘本', '阅读', '买书', '学习进修', '书报杂志', '教育工具', '书籍'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'education_training', icon: Icons.school_rounded, color: Color(0xFF5856D6)),
        keywords:['学', '教', '考', '培训', '课', '补习', '班', '学费', '报名费', '提升类', '教育机构', '培训进修', '教育成长支出', '子女教育', '成人学习', '教育', '培训考试', '学习教育', '学杂费', '校园', '学习', '考试', '网课', '自习室'],
      ),

// 🎁 人情与家庭
      CategoryRule(
        domain: const CategoryDomain(id: 'family_gift', icon: Icons.card_giftcard_rounded, color: Color(0xFFFF3B30)),
        keywords:['人情', '礼', '红包', '份子', '结婚', '压岁钱', '捐', '慈善', '孝敬', '社交类', '人情往来', '送礼请客', '孝敬家长', '还人钱物', '慈善捐助', '公益捐款', '送礼', '礼物', '捐款', '爱心', '礼金', '份子钱', '社交', '礼品', '团建'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'family_kids', icon: Icons.child_care_rounded, color: Color(0xFFFF9500)),
        keywords:['孩', '婴', '奶粉', '尿不湿', '育儿', '玩具', '宝贝', '儿子', '女儿', '赡养抚养支出', '抚养子女'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'family_pets', icon: Icons.pets_rounded, color: Color(0xFFA2845E)),
        keywords:['宠', '猫', '狗', '粮', '兽医', '驱虫', '宠物', '宠物宝贝', '萌宠', '宠物玩具'],
      ),

// 💰 金融理财
      CategoryRule(
        domain: const CategoryDomain(id: 'finance_investment', icon: Icons.trending_up_rounded, color: Color(0xFFFF3B30)),
        keywords:['理财', '基金', '股', '投资', '收益', '被动收入', '资产增值', '其他被动', '金融理财', '投资收益', '利息', '股票', '炒股', '返利金', '平台返利', '羊毛', '薅羊毛', '计提收益', '额外福利', '知识产权', '意外所得', '彩票'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'finance_insurance', icon: Icons.shield_rounded, color: Color(0xFF34C759)),
        keywords:['保险', '寿险', '重疾', '金融保险', '风险保障支出', '保险费用', '健康险', '财险', '意外险', '五险一金'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'finance_loan', icon: Icons.account_balance_rounded, color: Color(0xFF8E8E93)),
        merchants: ['花呗', '白条'],
        keywords:['贷款', '还款', '信用', '借', '欠', '赔', '押金', '罚', '税', '手续费', '分期', '房贷', '车贷', '息', '利息', '税务部门', '银行手续', '投资亏损', '按揭还款', '消费税收', '利息支出', '赔偿罚款', '烂账损失', '债务偿还支出', '信用卡还款', '消费贷款', '房贷车贷', '其他负债', '税费及其他支出', '房屋税费', '车辆税费', '计提亏损', '偿还本金', '偿还利息', '借款', '花呗还款', '白条还款', '刷卡金', '应付款项'],
      ),

// 💸 收入相关
      CategoryRule(
        domain: const CategoryDomain(id: 'income_salary', icon: Icons.payments_rounded, color: Color(0xFFFF3B30)),
        keywords:['工资', '薪水', '奖金', '分红', '兼职', '外快', '收入', '发钱', '生活费', '主动收入', '兼职副业', '技能变现', '员工', '年终奖', '工龄收入', '工龄', '打工', '零花钱', '奖学金', '社交收入', '工资薪金'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'income_refund', icon: Icons.price_check_rounded, color: Color(0xFF32ADE6)),
        keywords:['退款', '报销', '补贴', '理赔', '公积金', '转移性收入', '社会福利', '其他转移', '退税', '补助', '充值赠款'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'income_secondhand', icon: Icons.storefront_rounded, color: Color(0xFFFF9500)),
        merchants: ['闲鱼'],
        keywords: ['二手', '卖', '转让', '出售二手物品'],
      ),

// 📱 数码与个人护理
      CategoryRule(
        domain: const CategoryDomain(id: 'digital_devices', icon: Icons.devices_rounded, color: Color(0xFF8E8E93)),
        merchants: ['苹果', '华为'],
        keywords:['手机', '电脑', '平板', '外设', '耳机', '键盘', '鼠标', '数据线', '数码', '电子产品', '手表', '壳', '电视', '其他电子产品', '电脑配件', '智能穿戴', '电子数码', '配件耗材'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'digital_care', icon: Icons.content_cut_rounded, color: Color(0xFF5856D6)),
        keywords:['理发', '剪', '头发', '美甲', '护发'],
      ),

// 🚀 科技商务与杂项
      CategoryRule(
        domain: const CategoryDomain(id: 'others_tech', icon: Icons.dns_rounded, color: Color(0xFF48484A)),
        merchants: ['网心云', '京东云无限宝'],
        keywords:['平台企业', 'cdn', '服务器', 'NAS', '开源', '云资源', 'PCDN', '软件'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'others_family', icon: Icons.family_restroom_rounded, color: Color(0xFFFF2D55)),
        keywords:['赡养父母', '其他亲属', '家庭支持', '父母', '长辈'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'others_romance', icon: Icons.favorite_rounded, color: Color(0xFFFF2D55)),
        keywords:['恋爱', '约会'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'others_business', icon: Icons.business_center_rounded, color: Color(0xFF007AFF)),
        keywords:['服务商', '制造商', '原材料', '设备', '门店', '营销', '招聘', '办公', '差旅', '公司', '公司事务', '办证', '证件照', '福利', '教育机构', '公共服务机构', '医疗机构'],
      ),
      CategoryRule(
        domain: const CategoryDomain(id: 'others_misc', icon: Icons.more_horiz_rounded, color: Color(0xFF8E8E93)),
        merchants:['app store', 'App Store'],
        keywords:['个人', '其它', '其他杂项', '意外丢失', '偶发杂项', '其他支出', '其他', '智商税', '充值卡', '校园卡'],
      ),
    ];

    // 构建引擎索引
    for (var rule in rules) {
      // 1. 建立商户精确索引 (权重最高)
      for (var merchant in rule.merchants) {
        _merchantIndex.putIfAbsent(merchant, () =>[]).add(rule.domain);
        _trie.insert(merchant, rule.domain); // 商户名也加入 Trie 以便在长标题中扫描
      }

      // 2. 建立关键词精确索引
      for (var kw in rule.keywords) {
        _keywordIndex.putIfAbsent(kw, () =>[]).add(rule.domain);
        _trie.insert(kw, rule.domain);
      }
    }
    _isInitialized = true;
  }

  static CategoryMatch match(dynamic bill) {
    return _instance._calculateMatch(bill);
  }

  CategoryMatch _calculateMatch(dynamic bill) {
    final Map<CategoryDomain, int> scoreBoard = {};

    void addScore(List<CategoryDomain> domains, int score) {
      for (var domain in domains) {
        scoreBoard[domain] = (scoreBoard[domain] ?? 0) + score;
      }
    }

    // =======================================
    // 阶段 1：商户精确匹配 (最高优先级，权重 500)
    // 逻辑：如果交易对手是“滴滴”，几乎不用看别的，直接归为“交通”
    // =======================================
    final payeeName = bill.payeeName?.toString() ?? '';
    if (payeeName.isNotEmpty) {
      if (_merchantIndex.containsKey(payeeName)) {
        addScore(_merchantIndex[payeeName]!, 500);
      }
    }

    // =======================================
    // 阶段 2：标签/分类 Exact 匹配 (高优先级，权重 100)
    // 逻辑：账单自带的结构化标签
    // =======================================
    List<String> strongFeatures =[];
    if (bill.categoryAmountPair != null) {
      for (var c in (bill.categoryAmountPair as List)) {
        strongFeatures.add((c as dynamic).categoryName?.toString() ?? '');
      }
    }
    if (bill.tagList != null) {
      for (var t in (bill.tagList as List)) {
        strongFeatures.add((t as dynamic).tagName?.toString() ?? '');
      }
    }

    for (var feature in strongFeatures) {
      if (feature.isEmpty) continue;

      // 先查商户索引，再查关键词索引
      if (_merchantIndex.containsKey(feature)) {
        addScore(_merchantIndex[feature]!, 200);
      } else if (_keywordIndex.containsKey(feature)) {
        addScore(_keywordIndex[feature]!, 100);
      }
    }

    // =======================================
    // 阶段 3：Trie 树全文兜底扫描 (低优先级，权重 10 ~ 20)
    // 逻辑：处理类似“在星巴克买的拿铁”这种长文本
    // =======================================
    Map<String, int> scanTexts = {};
    if (payeeName.isNotEmpty) scanTexts[payeeName] = 20;

    final title = bill.title?.toString() ?? '';
    if (title.isNotEmpty) scanTexts[title] = 10;

    for (var entry in scanTexts.entries) {
      final matches = _trie.scanText(entry.key);
      for (var match in matches) {
        // 权重算法：基础权重 * 命中词的长度 (匹配的词越长，特征越明显)
        addScore(match.domains, entry.value * match.keyword.length);
      }
    }

    // =======================================
    // 4. 仲裁与返回
    // =======================================
    if (scoreBoard.isEmpty) {
      return _fallback(bill.billType);
    }

    // 找出得分最高的 Domain
    final bestDomain = scoreBoard.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return CategoryMatch(icon: bestDomain.icon, color: bestDomain.color);
  }

  /// 默认后备方案 (按照资金流向类型给色)
  CategoryMatch _fallback(dynamic billType) {
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
    final matchedConfig = SmartCategoryEngine.match(bill);
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
