import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/category_domain.dart';

/// 账单智能图标规则表（55+ 领域，14 大类）。
/// 从旧 SmartCategoryEngine 原样迁移，并补充会员订阅 / 转账细分 / 调整等 domain。
/// domain 各自的分类识别色保留（信息区分用）；billType 兜底色在引擎 _fallback 里另切 FxColors。
const List<CategoryRule> kCategoryRules = [
  // 🍔 1. 餐饮美食
  CategoryRule(
    domain: CategoryDomain(id: 'food_general', icon: Icons.restaurant_rounded, color: Color(0xFFFF9500)),
    merchants: ['海底捞', '呷哺呷哺', '巴奴', '凑凑', '外婆家', '西贝', '真功夫', '老乡鸡', '大米先生', '杨国福', '张亮麻辣烫', '探鱼', '太二', '绿茶餐厅', '眉州东坡', '九毛九', '费大厨', '半天妖', '木屋烧烤'],
    keywords: ['午餐', '晚餐', '夜宵', '正餐', '堂食', '火锅', '烧烤', '串串', '烤肉', '海鲜', '日料', '韩料', '寿司', '西餐', '牛排', '自助餐', '聚餐', '请客', '食堂', '饭卡', '餐费', '吃饭', '下馆子', '料理'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'food_fastfood', icon: Icons.fastfood_rounded, color: Color(0xFFFF9500)),
    merchants: ['麦当劳', 'McDonald', '肯德基', 'KFC', '汉堡王', 'Burger King', '必胜客', 'Pizza Hut', '达美乐', '华莱士', '塔斯汀', '尊宝比萨', '赛百味', 'Subway', 'Shake Shack'],
    keywords: ['快餐', '汉堡', '炸鸡', '披萨', '薯条', '简餐', '轻食', '沙拉', '三明治', '意面'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'food_delivery', icon: Icons.delivery_dining_rounded, color: Color(0xFFFF9500)),
    merchants: ['美团外卖', '饿了么', '美团拼好饭', 'KFC宅急送', '麦乐送'],
    keywords: ['外卖', '送餐', '跑腿代购', '外送费', '打包费', '订餐'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'food_coffee_tea', icon: Icons.local_cafe_rounded, color: Color(0xFFA2845E)),
    merchants: ['星巴克', 'Starbucks', '瑞幸', 'Luckin', '库迪', 'Cotti', '喜茶', 'Heytea', '奈雪', '蜜雪冰城', '茶颜悦色', '霸王茶姬', '一点点', '茶百道', '沪上阿姨', '古茗', 'Manner', 'Peets', 'Tim Hortons', 'Tims', 'M Stand'],
    keywords: ['咖啡', '奶茶', '果茶', '饮品', '买水', '饮料', '矿泉水', '冷饮', '冰水', '果汁', '拿铁', '美式'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'food_bakery', icon: Icons.bakery_dining_rounded, color: Color(0xFFFFCC00)),
    merchants: ['好利来', '鲍师傅', '味多美', '巴黎贝甜', '原麦山丘', '面包新语', '泸溪河', '吉姆大师傅', '爸爸糖'],
    keywords: ['早餐', '早点', '包子', '油条', '豆浆', '煎饼', '面包', '蛋糕', '甜品', '烘焙', '饼干', '吐司', '糕点', '点心', '生日蛋糕'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'food_bar_tobacco', icon: Icons.wine_bar_rounded, color: Color(0xFF5856D6)),
    merchants: ['1919', '海伦司', 'Helens', '酒小二', '泰山原浆', '百威', '茅台', '五粮液'],
    keywords: ['酒吧', '啤酒', '白酒', '洋酒', '红酒', '烟酒', '买烟', '香烟', '微醺', '清吧', '夜店', '酒水', '买酒'],
  ),

  // 🛒 2. 购物消费
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_online', icon: Icons.shopping_cart_rounded, color: Color(0xFFFF2D55)),
    merchants: ['淘宝', 'Taobao', '京东', 'JD', '拼多多', 'Pinduoduo', '天猫', 'Tmall', '唯品会', '得物', 'Poizon', '当当', '苏宁易购', '小红书', '抖音商城', '快手小店', '考拉海购', '1688', '阿里巴巴'],
    keywords: ['网购', '购物', '消费', '尾款', '定金', '代购', '海淘', '直播下单', '橱窗买单', '带货', '拼团'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_grocery', icon: Icons.local_grocery_store_rounded, color: Color(0xFF34C759)),
    merchants: ['盒马', '叮咚买菜', '朴朴', '永辉超市', '沃尔玛', 'Walmart', '山姆', 'Sam', '大润发', '七鲜', '美团优选', '多多买菜', '京东到家', '全家', 'FamilyMart', '罗森', 'Lawson', '7-Eleven', '711', '便利蜂', '美宜佳', '红旗连锁', '物美', '华润万家', '世纪联华', '家乐福', '麦德龙'],
    keywords: ['买菜', '生鲜', '水果', '蔬菜', '超市', '便利店', '杂货', '小卖部', '零食', '调料', '肉类', '海鲜水产', '粮油', '干货', '食品', '副食', '猪肉', '牛肉', '羊肉', '葱姜蒜'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_clothing', icon: Icons.checkroom_rounded, color: Color(0xFFAF52DE)),
    merchants: ['优衣库', 'Uniqlo', 'Zara', 'H&M', '耐克', 'Nike', '阿迪达斯', 'Adidas', '安踏', '李宁', '波司登', '海澜之家', 'UR', 'GAP', 'lululemon', '斐乐', 'FILA', '特步', 'Vans', 'Puma', 'ZARA', 'GU'],
    keywords: ['衣服', '裤子', '鞋子', '服饰', '包包', '外套', '内衣', '打扮', '配饰', '袜子', '裙子', '羽绒服', '童装', '男装', '女装', '买鞋', '帽子', '围巾', '手套', 'T恤', '卫衣', '毛衣', '西装'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_digital', icon: Icons.devices_rounded, color: Color(0xFF007AFF)),
    merchants: ['Apple', '苹果', '华为', 'Huawei', '小米', 'Xiaomi', 'OPPO', 'VIVO', '大疆', 'DJI', '戴森', 'Dyson', '联想', 'Lenovo', '华硕', '外星人', '罗技', 'Logitech', '索尼', 'Sony', '惠普', 'HP', '戴尔'],
    keywords: ['手机', '电脑', '平板', '耳机', '键盘', '鼠标', '数码', '电子产品', '智能穿戴', '配件', '数据线', '充电器', '相机', '路由器', '显示器', '充电宝', '内存卡', 'U盘', '主板', '显卡'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_beauty', icon: Icons.face_retouching_natural_rounded, color: Color(0xFFFF2D55)),
    merchants: ['丝芙兰', 'Sephora', '屈臣氏', 'Watsons', '完美日记', '花西子', '百雀羚', 'MAC', 'YSL', '雅诗兰黛', '欧莱雅', '兰蔻', '资生堂', 'SK-II', '海蓝之谜', '橘朵'],
    keywords: ['化妆品', '护肤品', '美妆', '香水', '口红', '面膜', '美容', '个人护理', '洗漱用品', '沐浴露', '洗发水', '防晒', '粉底', '眼影', '卸妆', '洁面', '爽肤水', '精华', '乳液', '面霜'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'shopping_home', icon: Icons.chair_rounded, color: Color(0xFFA2845E)),
    merchants: ['宜家', 'IKEA', '无印良品', 'MUJI', '名创优品', 'MINISO', '尼达利', 'NITORI', '网易严选', '苏泊尔', '九阳', '美的', '格力', '海尔', '全友'],
    keywords: ['家具', '家居', '家电', '日用品', '生活用品', '厨房用品', '床上用品', '纸巾', '清洁用品', '洗衣液', '绿植', '百货', '锅碗瓢盆', '抽纸', '垃圾袋', '拖把', '扫把', '衣架', '四件套', '被子', '枕头', '床垫', '五金', '灯泡'],
  ),

  // 🚗 3. 交通出行
  CategoryRule(
    domain: CategoryDomain(id: 'transport_taxi', icon: Icons.local_taxi_rounded, color: Color(0xFFFFCC00)),
    merchants: ['滴滴', '高德打车', '曹操出行', 'T3出行', '如祺出行', '嘀嗒出行', '花小猪', '首汽约车', '神州专车', '享道出行', '万顺叫车', '百度打车'],
    keywords: ['打车', '出租车', '网约车', '顺风车', '拼车', '快车', '专车', '车费', '打车费', '出行打车', '叫车'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transport_public', icon: Icons.directions_bus_rounded, color: Color(0xFF32ADE6)),
    merchants: ['地铁', '公交', '一卡通', '羊城通', '天府通', '八达通', '申通地铁', '京港地铁', '乘车码', '武汉通', '长安通', '金陵通'],
    keywords: ['公交车', '地铁票', '交通卡', '充地铁', '公共交通', '轮渡', '客车', '大巴', '公交费', '地铁费', '轻轨', '磁悬浮', '索道'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transport_trip', icon: Icons.flight_rounded, color: Color(0xFF007AFF)),
    merchants: ['铁路12306', '12306', '携程', 'Ctrip', '去哪儿', '飞猪', 'Fliggy', '同程', '国航', '南航', '东航', '海航', '春秋航空', '吉祥航空', '川航', '深航'],
    keywords: ['机票', '高铁', '火车票', '动车', '航班', '机场', '改签', '升舱', '出行差旅', '航空', '绿皮车', '卧铺', '退票费'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transport_gas_ev', icon: Icons.ev_station_rounded, color: Color(0xFFFF3B30)),
    merchants: ['中国石化', '中石化', '中国石油', '中石油', '中国海油', '壳牌', '特来电', '星星充电', '小桔充电', '国家电网充电', '蔚来充电', '特斯拉充电', '理想加电'],
    keywords: ['加油', '油费', '充电费', '燃油费', '新能源充电', '加油站', '充电桩', '汽油', '柴油'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transport_car_care', icon: Icons.car_repair_rounded, color: Color(0xFF8E8E93)),
    merchants: ['ETC', '捷停车', 'ETCP', '途虎养车', '停简单', '车主邦', '平安好车主', 'e代驾', '滴滴代驾'],
    keywords: ['停车费', '过路费', '高速费', '洗车', '保养', '车险', '违章', '罚款', '维修车辆', '养车', '代驾', '车牌', '年检', '补胎', '汽车配件'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transport_bike', icon: Icons.directions_bike_rounded, color: Color(0xFF34C759)),
    merchants: ['哈啰', '美团单车', '青桔', '小遛', '小鸣单车', '人民出行', '松果电单车'],
    keywords: ['共享单车', '自行车', '骑行', '电动车', '扫码骑车', '单车月卡', '单车季卡', '骑车费'],
  ),

  // 🏠 4. 居住物业
  CategoryRule(
    domain: CategoryDomain(id: 'housing_rent', icon: Icons.home_rounded, color: Color(0xFFA2845E)),
    merchants: ['自如', '链家', '贝壳', '泊寓', '冠寓', '魔方公寓', '相寓', '安居客', '我爱我家', '中原地产', '万科物业', '碧桂园服务', '绿城服务', '保利物业', '融创服务'],
    keywords: ['房租', '物业费', '交租', '租房', '中介费', '房屋管家', '房贷', '按揭', '还房贷', '公积金贷款', '商贷', '租金', '押金', '买房'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'housing_utilities', icon: Icons.lightbulb_rounded, color: Color(0xFFFFCC00)),
    merchants: ['国家电网', '南方电网', '中国水务', '港华燃气', '华润燃气', '新奥燃气', '中国燃气', '昆仑燃气', '水务集团'],
    keywords: ['电费', '水费', '燃气费', '煤气费', '交电费', '交水费', '水电煤', '天然气', '暖气费', '供暖费', '垃圾处理费'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'housing_telecom', icon: Icons.wifi_rounded, color: Color(0xFF32ADE6)),
    merchants: ['中国移动', '中国联通', '中国电信', '中国广电', '长城宽带'],
    keywords: ['话费', '充话费', '宽带', '网费', '流量', '通讯费', '手机费', '漫游费', '国际长途', '套餐费'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'housing_hotel', icon: Icons.hotel_rounded, color: Color(0xFF5856D6)),
    merchants: ['如家', '汉庭', '全季', '亚朵', '锦江之星', '希尔顿', 'Hilton', '万豪', 'Marriott', '洲际', '香格里拉', '桔子水晶', '维也纳', '七天', 'Airbnb', '爱彼迎', '途家'],
    keywords: ['住宿', '酒店', '旅馆', '民宿', '开房', '客栈', '度假村', '青旅', '房费'],
  ),

  // 🎮 5. 娱乐休闲
  CategoryRule(
    domain: CategoryDomain(id: 'entertainment_games', icon: Icons.sports_esports_rounded, color: Color(0xFFAF52DE)),
    merchants: ['Steam', 'App Store', '腾讯游戏', '网易游戏', '米哈游', 'miHoYo', '鹰角网络', 'Epic', 'Nintendo', 'PlayStation', 'Xbox', '王者荣耀', '和平精英', '原神', '心动网络', '完美世界', '西山居', '4399', 'TapTap'],
    keywords: ['游戏', '充值', '点券', '皮肤', '游戏机', '网吧', '电竞', '陪玩', '买号', '代练', '月卡', '战令', '通行证', '氪金', '周边', '点卡', '买单机'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'entertainment_media', icon: Icons.movie_rounded, color: Color(0xFFFF2D55)),
    merchants: ['爱奇艺', '腾讯视频', '优酷', 'B站', '哔哩哔哩', 'bilibili', '芒果TV', 'Netflix', 'Disney+', '抖音', '快手', '番茄短剧', '搜狐视频'],
    keywords: ['电影票', '电影', '看剧', '大会员', '视频会员', '影视', '追剧', '电影院', '点映', '影城', '影院', '充会员', '超级影视', '星钻会员', '短剧'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'entertainment_audio', icon: Icons.headphones_rounded, color: Color(0xFFFF3B30)),
    merchants: ['QQ音乐', '网易云音乐', '酷狗音乐', '酷我音乐', '苹果音乐', 'Apple Music', 'Spotify', '喜马拉雅', '蜻蜓FM', '荔枝FM', '懒人听书'],
    keywords: ['音乐会员', '听歌', '数字专辑', '有声书', '播客', '黑胶VIP', '绿钻', '付费电台', '电台会员', '听书'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'entertainment_play', icon: Icons.celebration_rounded, color: Color(0xFFFF9500)),
    merchants: ['大麦', '猫眼', '摩天轮', '秀动', '票牛', '欢乐谷', '迪士尼', '长隆', '方特', '海昌'],
    keywords: ['KTV', '剧本杀', '密室逃脱', '桌游', '台球', '游乐园', '门票', '看展', '漫展', '脱口秀', '相声', '剧院', '休闲玩乐', '演唱会', '音乐节', 'LiveHouse', '话剧', '音乐剧', '马戏团', '滑雪场', '水上乐园', '网咖', '电玩城', '夹娃娃', '抓娃娃', '游戏厅'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'entertainment_sports', icon: Icons.fitness_center_rounded, color: Color(0xFF007AFF)),
    merchants: ['Keep', '超级猩猩', '乐刻', '光猪圈', '一兆韦德', '威尔士', '中体倍力', '古德菲力', '迪卡侬'],
    keywords: ['健身', '私教', '瑜伽', '游泳', '打球', '篮球', '羽毛球', '足球', '网球', '滑雪', '运动装备', '体育', '攀岩', '潜水', '冲浪', '跳伞', '搏击', '普拉提', '舞蹈班', '健身房'],
  ),

  // 💊 6. 医疗健康
  CategoryRule(
    domain: CategoryDomain(id: 'medical_pharmacy', icon: Icons.medication_rounded, color: Color(0xFF32ADE6)),
    merchants: ['阿里健康', '京东健康', '美团买药', '饿了么买药', '大参林', '老百姓大药房', '益丰大药房', '海王星辰', '同仁堂', '张仲景大药房', '一心堂', '漱玉平民', '国大药房'],
    keywords: ['买药', '药店', '感冒药', '肠胃药', '维生素', '保健品', '创可贴', '退烧药', '医药费', '药房', '中药', '西药', '膏药', '眼药水', '口罩', '酒精'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'medical_hospital', icon: Icons.local_hospital_rounded, color: Color(0xFFFF3B30)),
    merchants: ['平安健康', '微医', '好大夫', '丁香医生', '春雨医生', '健康160', '爱康国宾', '美年大健康', '瑞慈体检', '慈铭体检', '拜博口腔', '瑞尔齿科', '雍禾医疗', '爱尔眼科'],
    keywords: ['医院', '挂号', '门诊', '急诊', '住院', '体检', '拔牙', '洗牙', '看病', '验光', '医保', '核酸', '疫苗', '治疗费', '检查费', '手术费', '化验费', '牙科', '眼科', '男科', '妇科', '儿科', '心理咨询', '救护车', '诊所'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'medical_spa', icon: Icons.spa_rounded, color: Color(0xFFAF52DE)),
    merchants: ['华夏良子', '常乐推拿', '康悦', '大桶大', '金色印象'],
    keywords: ['医美', '植发', '按摩', '推拿', '理疗', '采耳', '足浴', '足疗', '汗蒸', '洗浴', '桑拿', '艾灸', '拔罐', '刮痧', '中医馆', '养生'],
  ),

  // 📚 7. 教育学习
  CategoryRule(
    domain: CategoryDomain(id: 'education_course', icon: Icons.school_rounded, color: Color(0xFF5856D6)),
    merchants: ['学而思', '新东方', '猿辅导', '高途', '作业帮', '网易公开课', '腾讯课堂', '极客时间', '得到', 'Coursera', 'Duolingo', '樊登读书', '知乎', '中公教育', '粉笔教育', '华图教育', '斑马', '驾校'],
    keywords: ['学费', '培训班', '补习班', '网课', '知识付费', '考证', '报名费', '驾考', '考试费', '辅导', '兴趣班', '早教', '学车', '家教', '外教', '夏令营', '冬令营', '游学', '四六级', '考研', '考公', '公考', '教资'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'education_books', icon: Icons.menu_book_rounded, color: Color(0xFFA2845E)),
    merchants: ['新华书店', '西西弗', '言几又', '钟书阁', '方所', '单向空间', '当当网', 'Kindle', '微信读书', '番茄小说', '起点', '晋江', '晨光', '得力'],
    keywords: ['买书', '实体书', '电子书', '文具', '笔记本', '办公用品', '教辅', '绘本', '阅读', '资料打印', '复印资料', '教材', '试卷', '画具', '颜料', '买小说'],
  ),

  // 🎁 8. 人情社交与家庭
  CategoryRule(
    domain: CategoryDomain(id: 'social_gift', icon: Icons.card_giftcard_rounded, color: Color(0xFFFF2D55)),
    merchants: ['野兽派', 'Roseonly', '鲜花店', '礼品店', '花店'],
    keywords: ['送礼', '礼物', '红包', '份子钱', '结婚礼金', '压岁钱', '满月', '白事', '随礼', '人情往来', '探望', '买花', '订花', '伴手礼', '生日礼物', '节日礼物', '情人节', '七夕', '纪念日', '礼金'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'social_charity', icon: Icons.volunteer_activism_rounded, color: Color(0xFFFF3B30)),
    merchants: ['水滴筹', '腾讯公益', '轻松筹', '韩红爱心', '壹基金', '红十字会', '中华慈善总会', '支付宝公益'],
    keywords: ['捐款', '捐助', '慈善', '公益', '献爱心', '救助', '扶贫', '助学'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'family_kids', icon: Icons.stroller_rounded, color: Color(0xFFFF9500)),
    merchants: ['孩子王', '乐友', '蜜芽', '爱婴室', '好孩子', '贝贝网', '母婴店'],
    keywords: ['孝敬父母', '家用', '给长辈', '抚养', '育儿', '奶粉', '纸尿裤', '小孩', '辅食', '童车', '婴儿床', '奶瓶', '吸奶器', '孕妇装', '月嫂', '育婴师'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'family_pets', icon: Icons.pets_rounded, color: Color(0xFFA2845E)),
    merchants: ['波奇网', 'E宠', '极宠家', '瑞派', '新瑞鹏', '芭比堂', '安安宠医'],
    keywords: ['宠物', '猫粮', '狗粮', '罐头', '猫砂', '驱虫', '兽医', '宠物洗澡', '宠物医院', '逗猫棒', '牵引绳', '猫抓板', '狗笼', '猫包', '撸猫', '撸狗'],
  ),

  // 🏦 9. 金融理财
  CategoryRule(
    domain: CategoryDomain(id: 'finance_bank', icon: Icons.account_balance_rounded, color: Color(0xFF007AFF)),
    merchants: ['工商银行', 'ICBC', '招商银行', 'CMB', '建设银行', 'CCB', '农业银行', 'ABC', '中国银行', 'BOC', '交通银行', 'BOCOM', '平安银行', '浦发银行', '中信银行', '民生银行', '光大银行', '广发银行', '兴业银行', '微众银行', '网商银行', '支付宝', 'Alipay', '微信支付', 'WeChat Pay', '云闪付', '银联', 'Paypal'],
    keywords: ['收款', '提现', '手续费', '年费', '跨行转账', '服务费', '管理费', '短信费', '账户充值', '账户提现'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'finance_invest', icon: Icons.trending_up_rounded, color: Color(0xFFFF3B30)),
    merchants: ['余额宝', '理财通', '天天基金', '蚂蚁财富', '雪球', '同花顺', '东方财富', '大智慧', '富途', '老虎证券', '华泰证券', '中信建投', '广发证券'],
    keywords: ['理财', '基金', '股票', '投资', '定投', '国债', '黄金', '收益', '利息支出', '分红', '期权', '期货', '外汇', '信托', '私募', '买入', '卖出', '申购', '赎回'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'finance_loan', icon: Icons.credit_card_rounded, color: Color(0xFF8E8E93)),
    merchants: ['花呗', '借呗', '白条', '金条', '微粒贷', '分期乐', '拍拍贷', '度小满', '360借条', '安逸花'],
    keywords: ['贷款', '车贷', '信用卡还款', '分期', '借款', '利息', '逾期罚息', '借钱', '网贷', '消费贷', '经营贷', '信用贷', '抵押贷', '套现'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'finance_insurance', icon: Icons.shield_rounded, color: Color(0xFF34C759)),
    merchants: ['平安人寿', '中国人寿', '中国人保', 'PICC', '太平洋保险', 'CPIC', '泰康人寿', '新华保险', '众安保险', '水滴保', '蚂蚁保', '微保', '阳光保险'],
    keywords: ['保险', '保费', '重疾险', '医疗险', '意外险', '寿险', '交强险', '社保', '医保代扣', '理财险', '年金险', '财产险', '退保', '养老金'],
  ),

  // 💸 10. 收入来源
  CategoryRule(
    domain: CategoryDomain(id: 'income_salary', icon: Icons.payments_rounded, color: Color(0xFF16A34A)),
    keywords: ['工资', '薪水', '奖金', '绩效', '年终奖', '报酬', '兼职', '劳务费', '副业收入', '补贴', '津贴', '发薪', '底薪', '提成', '加班费', '高温补贴', '全勤奖', '餐补', '车补', '房补', '稿费', '版权收入', '薪资'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'income_refund', icon: Icons.price_check_rounded, color: Color(0xFF16A34A)),
    keywords: ['退款', '退税', '理赔款', '报销款', '押金退还', '退换货', '卖家退款', '撤销交易', '冲正', '冲账退回', '退保金', '退货'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'income_sales', icon: Icons.storefront_rounded, color: Color(0xFF16A34A)),
    merchants: ['闲鱼', '转转', '爱回收', '拍机堂', '多抓鱼', '红布林', '孔夫子旧书网'],
    keywords: ['卖二手', '闲置转让', '回收款', '货款', '营业收入', '出二手', '卖旧书', '卖衣服', '卖手机', '租金收入', '收租'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'income_other', icon: Icons.savings_rounded, color: Color(0xFF16A34A)),
    merchants: ['中国福利彩票', '中国体育彩票'],
    keywords: ['收红包', '收到转账', '投资收益', '利息收入', '平台返利', '羊毛', '中奖', '彩票', '意外所得', '现金奖励', '礼金收入', '收款单'],
  ),

  // 🚀 11. 数字与云服务
  CategoryRule(
    domain: CategoryDomain(id: 'tech_cloud', icon: Icons.cloud_rounded, color: Color(0xFF48484A)),
    merchants: ['阿里云', '腾讯云', '华为云', 'AWS', 'Google Cloud', 'Azure', 'GitHub', 'GitLab', 'Gitee', 'Vercel', 'Cloudflare', 'iCloud', '百度网盘', '夸克网盘', '迅雷网盘', '115网盘', '七牛云'],
    keywords: ['服务器', '域名', '云存储', '网盘会员', '数据库', 'CDN', 'API续费', '云服务', '云主机', 'VPS', 'SSL证书', 'OSS', '对象存储'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'tech_software', icon: Icons.laptop_windows_rounded, color: Color(0xFF5856D6)),
    merchants: ['OpenAI', 'ChatGPT', 'Claude', 'Midjourney', 'Github Copilot', 'JetBrains', 'Adobe', 'Autodesk', 'Figma', 'Sketch', 'Notion', 'Canva', 'Xmind', '亿图', '幕布', 'Setapp'],
    keywords: ['软件订阅', 'App订阅', '买软件', '激活码', '授权码', '插件', '主题', '模板', '素材', '字体', '正版软件', '专业版', '高级版'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'subscription', icon: Icons.subscriptions_rounded, color: Color(0xFF5856D6)),
    merchants: ['Apple One', '京东PLUS', '88VIP', 'YouTube Premium', 'Amazon Prime'],
    keywords: ['会员', '订阅', '续费', '包月', '包年', '连续包月', '自动续费', 'VIP', 'PLUS会员', '超级会员', '会员费'],
  ),

  // 💼 12. 工作商业与生活服务
  CategoryRule(
    domain: CategoryDomain(id: 'business_office', icon: Icons.business_center_rounded, color: Color(0xFF007AFF)),
    merchants: ['钉钉', 'DingTalk', '企业微信', '飞书', 'Lark', 'WPS', '石墨文档', '腾讯会议', 'Zoom', '企查查', '天眼查', '启信宝', '智联招聘', '前程无忧', 'BOSS直聘', '猎聘'],
    keywords: ['办公用品', '差旅费', '招待费', '公司团建', '企业服务', '工商注册', '财务代账', '印花税', '律师费', '打字复印', '发票邮寄', '采购', '进货', '原材料', '招聘费', '推广费', '广告费', '营销费'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'life_delivery', icon: Icons.local_shipping_rounded, color: Color(0xFFFF9500)),
    merchants: ['顺丰', '中通', '圆通', '申通', '韵达', '京东物流', '菜鸟', '极兔', '丰巢', '邮政', 'EMS', '货拉拉', '快狗打车', '闪送', '达达', '蜂鸟', 'UU跑腿', '顺丰同城'],
    keywords: ['寄件', '寄快递', '邮费', '运费', '同城急送', '搬家', '跑腿', '快递柜', '取件', '托运', '物流', '快递'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'life_services', icon: Icons.cleaning_services_rounded, color: Color(0xFF8E8E93)),
    merchants: ['天鹅到家', '万师傅', '啄木鸟', '鲁班到家', 'e袋洗'],
    keywords: ['保洁', '家政', '修理', '开锁', '配钥匙', '干洗', '洗衣费', '洗鞋', '擦鞋', '缝补', '改衣服', '通马桶', '清洗空调', '清洗油烟机', '保姆', '钟点工'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'life_beauty_hair', icon: Icons.content_cut_rounded, color: Color(0xFFAF52DE)),
    merchants: ['藤野造型', '优剪', '星客多', '快发', '木北造型'],
    keywords: ['理发', '剪发', '烫头', '染发', '做头发', '美甲', '美睫', '做指甲', '种睫毛', '纹眉', '洗剪吹', '发廊', '理发店'],
  ),

  // 🔁 13. 转账与调整（细分，billType 3/4 用）
  CategoryRule(
    domain: CategoryDomain(id: 'transfer_repay', icon: Icons.credit_score_rounded, color: Color(0xFF7C3AED)),
    keywords: ['还款', '还信用卡', '还花呗', '还借呗', '还白条', '还房贷', '还车贷', '还贷', '还钱', '房贷', '车贷'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transfer_salary', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF7C3AED)),
    keywords: ['工资转入', '发薪转账', '薪资到账'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'transfer_internal', icon: Icons.swap_horiz_rounded, color: Color(0xFF7C3AED)),
    keywords: ['内部转账', '转账', '账户互转', '资金归集', '转存'],
  ),
  CategoryRule(
    domain: CategoryDomain(id: 'adjust_balance', icon: Icons.tune_rounded, color: Color(0xFFF59E0B)),
    keywords: ['余额调整', '调整', '平账', '对账'],
  ),

  // 🧾 14. 其他
  CategoryRule(
    domain: CategoryDomain(id: 'misc_others', icon: Icons.more_horiz_rounded, color: Color(0xFF8E8E93)),
    keywords: ['其他', '杂项', '意外遗失', '糊涂账', '未知消费', '坏账', '冲账', '其他支出', '未分类', '找零', '补差价', '违约金', '赔偿款'],
  ),
];
