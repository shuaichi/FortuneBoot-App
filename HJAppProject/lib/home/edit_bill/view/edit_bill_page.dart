import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

// --- 原有导入 ---
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

// ==========================================
// 数据模型
// ==========================================
class CategoryAmountItem {
  int? categoryId;
  double amount;
  final UniqueKey key;

  CategoryAmountItem({this.categoryId, required this.amount})
      : key = UniqueKey();
}

// ==========================================
// 页面入口与Bloc供给
// ==========================================
class EditBillPage extends StatelessWidget {
  const EditBillPage({super.key});

  static Route<void> route(
      {BillItemAdd? initialBill, bool isCopyBill = false}) {
    return CupertinoPageRoute(
      fullscreenDialog: true, // 使用标准的原生模态弹出动画
      builder: (context) => BlocProvider(
        create: (context) => EditBillBloc(
          billRepository: context.read<BillsRepository>(),
          initialBill: initialBill,
          isCopyBill: isCopyBill,
        )..add(EditBillInitialized(
            BillType.fromValue(initialBill?.data?.billType ?? 1) ??
                BillType.expenditure)),
        child: const EditBillPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners:[
        BlocListener<EditBillBloc, EditBillState>(
          listenWhen: (prev, cur) => prev.status != cur.status,
          listener: (context, state) {
            if (state.status == EditBillStatus.failure) {
              _showSnack(context, S.current.todosOverviewErrorSnackbarText,
                  isError: true);
            } else if (state.status == EditBillStatus.closed) {
              _showSnack(context, state.isNewBill ? '记账成功' : '修改成功');
              Navigator.of(context).pop();
            } else if (state.status == EditBillStatus.submitFailed) {
              _showSnack(context, '保存失败', isError: true);
            }
          },
        ),
      ],
      child: const EditBillView(),
    );
  }
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  HapticFeedback.mediumImpact(); // 震动反馈
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        message,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
      ),
      backgroundColor:
      isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ));
}

// ==========================================
// 主视图 (现代金融原生风格)
// ==========================================
class EditBillView extends StatefulWidget {
  const EditBillView({super.key});

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final ValueNotifier<bool> _isMoreExpanded = ValueNotifier(false);
  final ValueNotifier<bool?> _confirm = ValueNotifier(null);
  final ValueNotifier<bool?> _include = ValueNotifier(null);
  final ValueNotifier<String?> _tradeTimeStr = ValueNotifier(null);
  final ValueNotifier<int> _activeAmountIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(false);

  late List<CategoryAmountItem> _categoryAmountItems;
  String? _tempAmountString;

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _remarkFocusNode = FocusNode();

  // 修复 Bug：增加一个空白占位焦点节点，用于彻底释放 TextField 的焦点记录
  final FocusNode _unfocusNode = FocusNode();

  // 高级金融级配色系统
  static const Color bgColor = Color(0xFFF2F4F7); // 极其干净的蓝灰色背景
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    final state = context.read<EditBillBloc>().state;
    _initCategoryAmountItems(state);

    if (state.editBill.data?.remark != null) {
      _remarkController.text = state.editBill.data!.remark!;
    }
    if (state.editBill.data?.title != null) {
      _titleController.text = state.editBill.data!.title!;
    }

    _titleFocusNode.addListener(_onTextFieldFocusChange);
    _remarkFocusNode.addListener(_onTextFieldFocusChange);

    _activeAmountIndex.addListener(() {
      _tempAmountString = null;
      HapticFeedback.selectionClick();
    });
  }

  void _initCategoryAmountItems(EditBillState state) {
    _categoryAmountItems =[];
    final pairs = state.editBill.data?.categoryAmountPair;
    if (pairs != null && pairs.isNotEmpty) {
      for (var p in pairs) {
        _categoryAmountItems.add(CategoryAmountItem(
          categoryId: (p['categoryId'] as num?)?.toInt(),
          amount: (p['amount'] as num?)?.toDouble() ?? 0.0,
        ));
      }
    } else {
      _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
    }
  }

  void _onTextFieldFocusChange() {
    if (_titleFocusNode.hasFocus || _remarkFocusNode.hasFocus) {
      // 只要系统输入框获取了焦点，自定义键盘必须消失
      _isKeyboardVisible.value = false;
      // 同时取消金额区域的选中高亮，避免用户混淆
      _activeAmountIndex.value = -99;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _remarkController.dispose();
    _isMoreExpanded.dispose();
    _confirm.dispose();
    _include.dispose();
    _tradeTimeStr.dispose();
    _activeAmountIndex.dispose();
    _isKeyboardVisible.dispose();
    _titleFocusNode.dispose();
    _remarkFocusNode.dispose();
    _unfocusNode.dispose(); // 记得销毁节点
    super.dispose();
  }

  BillType _currentBillType(EditBillState state) {
    return BillType.fromValue(state.editBill.data?.billType ?? 1) ??
        BillType.expenditure;
  }

  // Apple HIG 标准高质感色彩
  Color _getThemeColor(BillType type) {
    switch (type) {
      case BillType.expenditure:
        return const Color(0xFF34C759); // iOS Green
      case BillType.income:
        return const Color(0xFFFF3B30); // iOS Red
      case BillType.transfer:
        return const Color(0xFF007AFF); // iOS Blue
      default:
        return textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditBillBloc>().state;
    final billType = _currentBillType(state);
    final themeColor = _getThemeColor(billType);

    // 拦截余额调整
    if (state.initialBill != null && billType == BillType.adjust) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('余额调整不支持编辑')));
        Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    _syncFormStates(state, billType);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: textPrimary, size: 32),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            state.isNewBill ? '记一笔' : '编辑账单',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 17, color: textPrimary),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Focus( // 包裹 Focus 辅助节点拦截未被捕获的焦点状态回退
            focusNode: _unfocusNode,
            child: Column(
              children:[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _dismissKeyboard(); // 采用新的 dismiss 方法
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      slivers:[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children:[
                                const SizedBox(height: 8),
                                // 1. 现代化分段控制器
                                _buildModernSegmentControl(billType, themeColor),
                                const SizedBox(height: 24),

                                // 2. 灵动的巨型金额显示区
                                _buildDynamicAmountSection(
                                    state, billType, themeColor),
                                const SizedBox(height: 24),

                                // 3. 高级圆角卡片表单 (Glass/Card feel)
                                _ModernCardGroup(
                                  children:[
                                    _buildTitleInput(state, themeColor),
                                    const _ModernDivider(),
                                    _buildAccountSelector(
                                        state, billType, themeColor),
                                    const _ModernDivider(),
                                    _buildTimeSelector(state, themeColor),
                                    const _ModernDivider(),
                                    _buildTagSelector(state, themeColor),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 4. 展开更多按钮
                                Center(
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: _isMoreExpanded,
                                    builder: (context, expanded, child) {
                                      return TextButton.icon(
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          _dismissKeyboard(); // 采用新的 dismiss 方法
                                          _isMoreExpanded.value = !expanded;
                                        },
                                        icon: Icon(
                                            expanded
                                                ? Icons.keyboard_arrow_up_rounded
                                                : Icons
                                                .keyboard_arrow_down_rounded,
                                            color: textSecondary,
                                            size: 20),
                                        label: Text(
                                            expanded ? '收起更多选项' : '展开更多选项',
                                            style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // 5. 次要表单信息
                                ValueListenableBuilder<bool>(
                                  valueListenable: _isMoreExpanded,
                                  builder: (context, expanded, child) {
                                    return AnimatedSize(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOutCubic,
                                      alignment: Alignment.topCenter,
                                      child: !expanded
                                          ? const SizedBox(width: double.infinity)
                                          : Column(
                                        children: [
                                          _ModernCardGroup(
                                            children:[
                                              if (billType !=
                                                  BillType.transfer) ...[
                                                _buildPayeeSelector(
                                                    state, themeColor),
                                                const _ModernDivider(),
                                              ],
                                              _buildRemarkInput(
                                                  state, themeColor),
                                              const _ModernDivider(),
                                              IntrinsicHeight(
                                                child: Row(
                                                  children:[
                                                    Expanded(
                                                        child: _buildModernSwitch(
                                                            '确认入账',
                                                            Icons
                                                                .verified_rounded,
                                                            Colors.orange,
                                                            _confirm,
                                                            state,
                                                            billType,
                                                            themeColor)),
                                                    Container(
                                                        width: 0.5,
                                                        color: const Color(
                                                            0xFFE5E5EA)),
                                                    Expanded(
                                                        child: _buildModernSwitch(
                                                            '纳入统计',
                                                            Icons
                                                                .pie_chart_rounded,
                                                            Colors.purple,
                                                            _include,
                                                            state,
                                                            billType,
                                                            themeColor)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _ModernCardGroup(
                                            padding:
                                            const EdgeInsets.all(16),
                                            children:[
                                              AttachmentUploadWidget(
                                                initialAttachments:
                                                state.attachments,
                                                onAttachmentsChanged:
                                                    (attachments) => context
                                                    .read<
                                                    EditBillBloc>()
                                                    .add(EditBillAttachmentsChanged(
                                                    attachments)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 40),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 底部按钮与自定义键盘区的无缝衔接
                ValueListenableBuilder<bool>(
                  valueListenable: _isKeyboardVisible,
                  builder: (context, visible, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        if (!visible) _buildSubmitButton(state, themeColor),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          height: visible
                              ? 290 + MediaQuery.of(context).padding.bottom
                              : 0,
                          child: visible
                              ? _buildModernNumPad(themeColor)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _syncFormStates(EditBillState state, BillType billType) {
    if (_confirm.value == null || _include.value == null) {
      if (billType == BillType.transfer) {
        _confirm.value = true;
        _include.value = true;
        state.editBill.data!.confirm = true;
        state.editBill.data!.include = true;
      } else {
        _confirm.value = state.editBill.data!.confirm ?? true;
        _include.value = state.editBill.data!.include ?? true;
      }
    } else if (billType == BillType.transfer) {
      _confirm.value = true;
      _include.value = true;
      state.editBill.data!.confirm = true;
      state.editBill.data!.include = true;
    }
    if (state.editBill.data?.remark != null && _remarkController.text.isEmpty) {
      _remarkController.text = state.editBill.data!.remark!;
    }
    if (state.editBill.data?.title != null && _titleController.text.isEmpty) {
      _titleController.text = state.editBill.data!.title!;
    }
  }

  // ==========================================
  // 核心视觉组件
  // ==========================================

  Widget _buildModernSegmentControl(BillType currentType, Color themeColor) {
    final enable =
        context.read<EditBillBloc>().state.status != EditBillStatus.loading;
    return Opacity(
      opacity: enable ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !enable,
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5EA), // iOS 经典控件底色
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children:[
              _buildSegmentPill(
                  '支出', BillType.expenditure, currentType, themeColor),
              _buildSegmentPill('收入', BillType.income, currentType, themeColor),
              _buildSegmentPill(
                  '转账', BillType.transfer, currentType, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentPill(
      String label, BillType type, BillType currentType, Color themeColor) {
    final isSelected = type == currentType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (type == BillType.transfer) {
            _confirm.value = true;
            _include.value = true;
            context.read<EditBillBloc>().state.editBill.data?.confirm = true;
            context.read<EditBillBloc>().state.editBill.data?.include = true;
          }
          context.read<EditBillBloc>().add(EditBillTypeChange(type));
          setState(() {
            _activeAmountIndex.value = type == BillType.transfer ? -1 : 0;
            _categoryAmountItems =[CategoryAmountItem(amount: 0.0)];
            _tempAmountString = null;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ?[
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]
                :[],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? textPrimary : textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicAmountSection(
      EditBillState state, BillType billType, Color themeColor) {
    if (billType == BillType.transfer) {
      return GestureDetector(
        onTap: () {
          // 第一步：先彻底关闭系统键盘
          FocusScope.of(context).unfocus();

          // 第二步：给系统一点点时间（毫秒级）来处理键盘收起逻辑
          // 这样可以避免自定义键盘弹出时，系统键盘还在占位的视觉闪烁
          Future.delayed(const Duration(milliseconds: 10), () {
            _activeAmountIndex.value = -1;
            _isKeyboardVisible.value = true;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: ValueListenableBuilder<int>(
          valueListenable: _activeAmountIndex,
          builder: (_, activeIndex, __) {
            final isActive = activeIndex == -1;
            final amount = state.editBill.data?.amount ?? 0.0;
            return _AnimatedAmountTicker(
              amountStr: _formatAmountString(isActive, amount),
              isActive: isActive,
              themeColor: themeColor,
            );
          },
        ),
      );
    }

    return Column(
      children:[
        ...List.generate(_categoryAmountItems.length, (index) {
          final item = _categoryAmountItems[index];
          final catName = _getCategoryName(state.categoryList, item.categoryId);
          return Dismissible(
            key: item.key,
            direction: _categoryAmountItems.length > 1
                ? DismissDirection.endToStart
                : DismissDirection.none,
            onDismissed: (_) {
              setState(() {
                _categoryAmountItems.removeAt(index);
                if (_activeAmountIndex.value >= _categoryAmountItems.length) {
                  _activeAmountIndex.value = _categoryAmountItems.length - 1;
                }
              });
              _syncCategoryAmountToState();
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.white, size: 28),
            ),
            child: GestureDetector(
              onTap: () {
                // 强制收回系统键盘
                FocusScope.of(context).unfocus();
                // 延迟 10-50ms 确保系统键盘开始收起动作后再显示自定义键盘
                Future.delayed(const Duration(milliseconds: 10), () {
                  _activeAmountIndex.value = index;
                  _isKeyboardVisible.value = true;
                });
              },
              child: ValueListenableBuilder<int>(
                valueListenable: _activeAmountIndex,
                builder: (_, activeIndex, __) {
                  final isActive = activeIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isActive
                              ? themeColor.withOpacity(0.3)
                              : Colors.transparent,
                          width: 2),
                      boxShadow: isActive
                          ?[
                        BoxShadow(
                            color: themeColor.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                          :[],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            GestureDetector(
                              onTap: () {
                                // 第一步：先彻底关闭系统键盘
                                FocusScope.of(context).unfocus();

                                // 第二步：给系统一点点时间（毫秒级）来处理键盘收起逻辑
                                // 这样可以避免自定义键盘弹出时，系统键盘还在占位的视觉闪烁
                                Future.delayed(const Duration(milliseconds: 10), () {
                                  _activeAmountIndex.value = index;
                                  _isKeyboardVisible.value = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children:[
                                    Icon(Icons.category_rounded,
                                        size: 16, color: themeColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      catName.isEmpty
                                          ? '选择分类'
                                          : catName.split(' > ').last,
                                      style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _AnimatedAmountTicker(
                          amountStr: _formatAmountString(isActive, item.amount),
                          isActive: isActive,
                          themeColor: themeColor,
                          isCompact: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }),
        if (_categoryAmountItems.length < 5)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 10), () {
                  setState(() {
                    _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
                    _activeAmountIndex.value = _categoryAmountItems.length - 1;
                    _isKeyboardVisible.value = true;
                  });
                  _syncCategoryAmountToState();
                });
              },
              icon: Icon(Icons.add_circle_rounded, color: themeColor),
              label: Text('添加多分类明细',
                  style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              style: TextButton.styleFrom(
                  backgroundColor: themeColor.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
          )
      ],
    );
  }

  String _formatAmountString(bool isActive, double amount) {
    if (isActive && _tempAmountString != null) {
      String str = _tempAmountString!;
      if (str.isEmpty) return '0.00';
      if (str == '-' || str == '-0' || str == '-0.') return '-0.00';
      return str;
    } else {
      if (amount == 0) return amount.isNegative ? '-0.00' : '0.00';
      return amount.toStringAsFixed(2);
    }
  }

  String _getCategoryName(List<CategorySelectItem> categories, int? id) {
    if (id == null) return '';
    try {
      return CategorySelectItem.getFullPathById(categories, id);
    } catch (_) {
      return categories
          .firstWhere((e) => e.id == id, orElse: () => categories.first)
          .title;
    }
  }

  // ==========================================
  // 高级表单控件
  // ==========================================
  Widget _buildTitleInput(EditBillState state, Color themeColor) {
    return _ModernFormRow(
      icon: Icons.edit_rounded,
      iconColor: Colors.blueGrey,
      label: '标题',
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        onTap: () {
          // 【关键】一旦点击系统输入框，立即隐藏自定义键盘
          _isKeyboardVisible.value = false;
          // 重置金额的高亮状态
          _activeAmountIndex.value = -99;
        },
        style: const TextStyle(
            fontSize: 16, color: textPrimary, fontWeight: FontWeight.w500),
        textAlign: TextAlign.right,
        cursorColor: themeColor,
        decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '输入标题...',
            hintStyle:
            TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
            contentPadding: EdgeInsets.zero),
        onChanged: (val) => state.editBill.data?.title = val,
      ),
    );
  }

  // 修改 _buildAccountSelector 方法

  Widget _buildAccountSelector(EditBillState state, BillType billType, Color themeColor) {
    if (billType == BillType.transfer) {
      final inItems = state.transferAccountList;
      final outItems = state.transferOutAccountList;

      // 【修复 Bug 1 & 2】直接取模型值，不再使用 ?? default...
      final outItem = outItems
          .where((i) => i.value.id == state.editBill.data?.accountId)
          .firstOrNull?.value;
      final inItem = inItems
          .where((i) => i.value.id == state.editBill.data?.toAccountId)
          .firstOrNull?.value;

      return Column(
        children: [
          _ModernFormRow(
              icon: Icons.arrow_upward_rounded,
              iconColor: Colors.orange,
              label: '转出账户',
              valueText: outItem?.title ?? '请选择', // 如果没值就显示请选择
              onTap: () {
                _dismissKeyboard();
                _showPickerBottomSheet(
                    '选择转出账户',
                    outItems,
                    outItem?.id,
                        (val) => setState(() => state.editBill.data?.accountId = val?.id), // 注意这里允许 val 为 null
                    themeColor);
              }),
          const _ModernDivider(),
          _ModernFormRow(
              icon: Icons.arrow_downward_rounded,
              iconColor: Colors.blue,
              label: '转入账户',
              valueText: inItem?.title ?? '请选择',
              onTap: () {
                _dismissKeyboard();
                _showPickerBottomSheet(
                    '选择转入账户',
                    inItems,
                    inItem?.id,
                        (val) => setState(() => state.editBill.data?.toAccountId = val?.id),
                    themeColor);
              }),
        ],
      );
    } else {
      final items = billType == BillType.income ? state.incomeAccountList : state.expenseAccountList;

      // 【修复 Bug 1 & 2】直接取模型值
      final accItem = items
          .where((i) => i.value.id == state.editBill.data?.accountId)
          .firstOrNull?.value;

      return _ModernFormRow(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: Colors.blue,
          label: '账户',
          valueText: accItem?.title ?? '请选择',
          onTap: () {
            _dismissKeyboard();
            _showPickerBottomSheet(
                '选择账户',
                items,
                accItem?.id,
                    (val) => setState(() => state.editBill.data?.accountId = val?.id),
                themeColor);
          });
    }
  }

  Widget _buildTimeSelector(EditBillState state, Color themeColor) {
    return ValueListenableBuilder<String?>(
      valueListenable: _tradeTimeStr,
      builder: (context, value, child) {
        final displayTime = state.editBill.data?.tradeTime ??
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        return _ModernFormRow(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.redAccent,
            label: '日期',
            valueText: displayTime,
            onTap: () {
              _dismissKeyboard();
              _showCustomDateTimePicker(
                  context, value ?? displayTime, state, themeColor);
            });
      },
    );
  }

  Widget _buildTagSelector(EditBillState state, Color themeColor) {
    final ids = state.editBill.data?.tagIdList ??[];
    return _ModernFormRow(
        icon: Icons.local_offer_rounded,
        iconColor: Colors.green,
        label: '标签',
        valueText: ids.isEmpty ? '请选择' : '已选 ${ids.length} 个',
        onTap: () {
          _dismissKeyboard();
          _showTagSelector(context, state, themeColor);
        });
  }

  Widget _buildPayeeSelector(EditBillState state, Color themeColor) {
    final payeeItem = state.payeeList
        .where((i) => i.value.id == state.editBill.data?.payeeId)
        .firstOrNull
        ?.value;
    return _ModernFormRow(
        icon: Icons.storefront_rounded,
        iconColor: Colors.deepPurpleAccent,
        label: '交易对象',
        valueText: payeeItem?.title ?? '请选择',
        onTap: () {
          _dismissKeyboard();
          _showPickerBottomSheet(
              '选择交易对象',
              state.payeeList,
              payeeItem?.id,
                  (val) => setState(() => state.editBill.data?.payeeId = val?.id),
              themeColor);
        });
  }

  Widget _buildRemarkInput(EditBillState state, Color themeColor) {
    return _ModernFormRow(
      icon: Icons.notes_rounded,
      iconColor: Colors.grey,
      label: '备注',
      child: TextField(
        controller: _remarkController,
        focusNode: _remarkFocusNode,
        onTap: () {
          // 【关键】一旦点击系统输入框，立即隐藏自定义键盘
          _isKeyboardVisible.value = false;
          // 重置金额的高亮状态
          _activeAmountIndex.value = -99;
        },
        style: const TextStyle(fontSize: 16, color: textPrimary),
        textAlign: TextAlign.right,
        maxLines: null,
        cursorColor: themeColor,
        decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '添加备注...',
            hintStyle: TextStyle(color: textSecondary),
            contentPadding: EdgeInsets.zero),
        onChanged: (val) => state.editBill.data?.remark = val,
      ),
    );
  }

  Widget _buildModernSwitch(
      String label,
      IconData icon,
      Color iColor,
      ValueNotifier<bool?> notifier,
      EditBillState state,
      BillType type,
      Color themeColor) {
    final isTransfer = type == BillType.transfer;
    return ValueListenableBuilder<bool?>(
      valueListenable: notifier,
      builder: (_, val, __) {
        final current = isTransfer ? true : (val ?? true);
        return InkWell(
          onTap: isTransfer
              ? null
              : () {
            HapticFeedback.lightImpact();
            final next = !current;
            if (label == '确认入账') state.editBill.data?.confirm = next;
            if (label == '纳入统计') state.editBill.data?.include = next;
            notifier.value = next;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:[
                Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: iColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, size: 16, color: iColor)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))),
                Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                        activeColor: themeColor,
                        value: current,
                        onChanged: isTransfer
                            ? null
                            : (v) {
                          HapticFeedback.lightImpact();
                          if (label == '确认入账') {
                            state.editBill.data?.confirm = v;
                          }
                          if (label == '纳入统计') {
                            state.editBill.data?.include = v;
                          }
                          notifier.value = v;
                        })),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(EditBillState state, Color themeColor) {
    final isLoading = state.status.isLoadingOrInit;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: isLoading
              ? null
              : () {
            HapticFeedback.mediumImpact();
            _dismissKeyboard(); // 触发焦点释放
            _submitBill(state.editBill, state);
          },
          child: isLoading
              ? const CupertinoActivityIndicator(color: Colors.white)
              : const Text('保存',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0)),
        ),
      ),
    );
  }

  // ==========================================
  // 定制化金融级数字键盘 (完美融合原生)
  // ==========================================
  Widget _buildModernNumPad(Color themeColor) {
    return Container(
      color: const Color(0xFFD1D5DB), // 经典 iOS 键盘底层灰
      child: SafeArea(
        top: false,
        child: Column(
          children:[
            Container(
              height: 40,
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  IconButton(
                    icon: const Icon(Icons.keyboard_hide_rounded,
                        color: textSecondary),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _isKeyboardVisible.value = false;
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children:[
                          _buildKeyboardRow(['1', '2', '3']),
                          _buildKeyboardRow(['4', '5', '6']),
                          _buildKeyboardRow(['7', '8', '9']),
                          _buildKeyboardRow(['.', '0', 'DEL']),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children:[
                          _buildKey('-', flex: 1),
                          _buildKey('完成',
                              flex: 3,
                              bgColor: themeColor,
                              textColor: Colors.white, onTap: () {
                                HapticFeedback.mediumImpact();
                                _dismissKeyboard(); // 触发焦点释放
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Expanded(
      child: Row(children: keys.map((k) => _buildKey(k)).toList()),
    );
  }

  Widget _buildKey(String key,
      {int flex = 1, Color? bgColor, Color? textColor, VoidCallback? onTap}) {
    final isAction = key == 'DEL' || key == '-' || key == '完成';
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 0.5,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap ??
                    () {
                  HapticFeedback.lightImpact();
                  _onKeyTap(key);
                },
            child: Center(
              child: key == 'DEL'
                  ? const Icon(Icons.backspace_rounded,
                  size: 24, color: textPrimary)
                  : Text(
                key,
                style: TextStyle(
                  fontSize: key == '完成' ? 18 : 26,
                  fontWeight:
                  isAction ? FontWeight.w600 : FontWeight.w400,
                  color: textColor ?? textPrimary,
                  fontFamily:
                  isAction ? null : 'SF Pro Display', // 模拟苹果数字字体
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyTap(String key) {
    final idx = _activeAmountIndex.value;
    final state = context.read<EditBillBloc>().state;
    double currentVal = idx == -1
        ? (state.editBill.data?.amount ?? 0)
        : _categoryAmountItems[idx].amount;

    if (_tempAmountString == null) {
      bool isNegativeZero = currentVal == 0 && (1 / currentVal).isNegative;
      _tempAmountString = isNegativeZero
          ? '-0'
          : (currentVal == 0
          ? ''
          : currentVal.toString().replaceAll(RegExp(r'\.0$'), ''));
    }

    String strVal = _tempAmountString!;
    if (key == '-') {
      strVal = strVal.startsWith('-')
          ? strVal.substring(1)
          : (strVal.isEmpty ? '-' : '-$strVal');
      if (strVal == '-') strVal = '-0';
    } else if (key == 'DEL') {
      if (strVal.isNotEmpty) {
        strVal = strVal.substring(0, strVal.length - 1);
        if (strVal == '-') strVal = '';
      }
    } else if (key == '.') {
      if (!strVal.contains('.')) {
        strVal = strVal.isEmpty ? '0.' : (strVal == '-' ? '-0.' : '$strVal.');
      }
    } else {
      if (strVal == '-0') {
        strVal = key != '0' ? '-$key' : '-0';
      } else if (strVal == '0') {
        strVal = key;
      } else if (strVal.contains('.')) {
        if (strVal.split('.')[1].length < 2) strVal += key;
      } else {
        if (strVal.length < (strVal.startsWith('-') ? 10 : 9)) strVal += key;
      }
    }

    _tempAmountString = strVal;
    double newVal = (strVal.isNotEmpty && strVal != '-' && strVal != '-0.')
        ? (double.tryParse(strVal) ?? 0)
        : 0;
    if (strVal == '-0' || strVal == '-0.') newVal = -0.0;

    setState(() {
      if (idx == -1) {
        state.editBill.data?.amount = newVal;
      } else {
        _categoryAmountItems[idx].amount = newVal;
        _syncCategoryAmountToState();
      }
    });
  }

  void _syncCategoryAmountToState() {
    final state = context.read<EditBillBloc>().state;
    List<Map<String, num>> pairs =[];
    double total = 0;
    for (var item in _categoryAmountItems) {
      if (item.categoryId != null) {
        pairs.add({'categoryId': item.categoryId!, 'amount': item.amount});
      }
      total += item.amount;
    }
    state.editBill.data?.categoryAmountPair = pairs;
    state.editBill.data?.amount = total;
  }

  // ==========================================
  // 高级丝滑底部弹窗
  // ==========================================
  void _showPickerBottomSheet<T extends BaseSelectItem>(
      String title,
      List<DropdownItem<T>> items,
      int? currentId,
      Function(T?) onSelected, // 改为接收可选的 T
      Color themeColor) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModernSheetHeader(title: title),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // 【修复 Bug 3】添加“清除选择”选项
                  if (currentId != null)
                    InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(ctx);
                        onSelected(null); // 传回 null
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        child: Row(
                          children: [
                            const Icon(Icons.block, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 12),
                            const Text('不选择 / 清除',
                                style: TextStyle(fontSize: 16, color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ),
                  if (currentId != null) const _ModernDivider(),

                  // 原有的列表项
                  ...items.map((item) {
                    final isSelected = currentId == item.value.id;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(ctx);
                            onSelected(item.value);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: Row(
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected ? themeColor : textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: themeColor, size: 22),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 24, endIndent: 24, color: Color(0xFFF2F2F7)),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _dismissKeyboard() {
    // 1. 强制系统键盘收起（这是最彻底的方法）
    FocusScope.of(context).unfocus();
    // 2. 确保没有任何节点保持焦点
    FocusManager.instance.primaryFocus?.unfocus();
    // 3. 隐藏自定义键盘
    _isKeyboardVisible.value = false;
  }

  void _showCategorySelector(
      BuildContext context, EditBillState state, int index, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children:[
              const _ModernSheetHeader(title: '选择分类'),
              Expanded(
                child: TreeSelectorWidget<CategorySelectItem>(
                  items: state.categoryList,
                  isMultiSelect: false,
                  selectedIds: _categoryAmountItems[index].categoryId != null
                      ? [_categoryAmountItems[index].categoryId!]
                      :[],
                  onChanged: (ids) {
                    if (ids.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      setState(() =>
                      _categoryAmountItems[index].categoryId = ids.first);
                      _syncCategoryAmountToState();
                      Navigator.pop(context);
                    }
                  },
                  activeColor: themeColor,
                  getId: (item) => item.id,
                  getTitle: (item) => item.title,
                  getChildren: (item) => item.children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagSelector(
      BuildContext context, EditBillState state, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children:[
              const _ModernSheetHeader(title: '选择标签'),
              Expanded(
                child: TagSelectorSheetContent(
                  tags: state.tagList,
                  selectedIds: state.editBill.data?.tagIdList ?? [],
                  onChanged: (ids) =>
                      setState(() => state.editBill.data?.tagIdList = ids),
                  activeColor: themeColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDateTimePicker(BuildContext context, String currentValue,
      EditBillState state, Color themeColor) {
    DateTime initDate;
    try {
      initDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(currentValue);
    } catch (_) {
      try {
        initDate = DateFormat('yyyy-MM-dd HH:mm').parse(currentValue);
      } catch (_) {
        initDate = DateTime.now();
      }
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 380,
          child: CustomDateTimePicker(
            initialDate: initDate,
            themeColor: themeColor,
            onDateTimeChanged: (DateTime newDate) {
              _tradeTimeStr.value =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate);
              state.editBill.data?.tradeTime = _tradeTimeStr.value;
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }

  void _submitBill(BillItemAdd billItemAdd, EditBillState state) {
    if (billItemAdd.data?.title?.trim().isEmpty ?? true) {
      // return _showSnack(context, '请填写标题', isError: true);
      // TODO 暂时设置成默认值，后续改成配置的
      billItemAdd.data?.title = '未命名账单';
    }
    if (billItemAdd.data?.billType == BillType.transfer.value) {
      if (billItemAdd.data?.amount == null || billItemAdd.data!.amount == 0) {
        return _showSnack(context, '请填入有效金额', isError: true);
      }
      if (billItemAdd.data?.accountId == null ||
          billItemAdd.data?.toAccountId == null) {
        return _showSnack(context, '请选择完整的转入/转出账户', isError: true);
      }
    } else {
      if (_categoryAmountItems.isEmpty) {
        return _showSnack(context, '请填入有效金额', isError: true);
      }
      if (_categoryAmountItems.any((e) => e.categoryId == null)) {
        return _showSnack(context, '请为每笔金额选择分类', isError: true);
      }
    }
    context.read<EditBillBloc>().add(EditBillSubmitted());
  }
}

// ==========================================
// 辅助视觉微件 (精细打磨)
// ==========================================

class _AnimatedAmountTicker extends StatelessWidget {
  final String amountStr;
  final bool isActive;
  final Color themeColor;
  final bool isCompact;

  const _AnimatedAmountTicker(
      {required this.amountStr,
        required this.isActive,
        required this.themeColor,
        this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        if (!isCompact)
          Text('金额',
              style: TextStyle(
                  color: _EditBillViewState.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Text('¥',
                style: TextStyle(
                    fontSize: isCompact ? 28 : 36,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? themeColor
                        : _EditBillViewState.textPrimary)),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    amountStr,
                    key: ValueKey<String>(amountStr),
                    style: TextStyle(
                      fontSize: isCompact ? 40 : 56,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? themeColor
                          : _EditBillViewState.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernCardGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const _ModernCardGroup({required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow:[
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      padding: padding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _ModernFormRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String? valueText;
  final Widget? child;
  final VoidCallback? onTap;

  const _ModernFormRow(
      {required this.label,
        required this.icon,
        required this.iconColor,
        this.valueText,
        this.child,
        this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children:[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: _EditBillViewState.textPrimary,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Expanded(
              child: child ??
                  Text(
                    valueText ?? '',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      color: (valueText?.contains('请选择') ?? false)
                          ? _EditBillViewState.textSecondary
                          : _EditBillViewState.textPrimary,
                    ),
                  ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFC7C7CC), size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModernDivider extends StatelessWidget {
  const _ModernDivider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, thickness: 0.5, indent: 56, color: Color(0xFFF2F2F7));
}

class _ModernSheetHeader extends StatelessWidget {
  final String title;

  const _ModernSheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('取消', style: TextStyle(color: Colors.transparent)),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: _EditBillViewState.textPrimary)),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: const Text('完成',
                    style: TextStyle(
                        color: _EditBillViewState.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 数据/逻辑层展示部件
// ==========================================

class TreeSelectorWidget<T> extends StatefulWidget {
  final List<T> items;
  final bool isMultiSelect;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final Color activeColor;
  final int Function(T) getId;
  final String Function(T) getTitle;
  final List<T>? Function(T) getChildren;

  const TreeSelectorWidget(
      {super.key,
        required this.items,
        required this.isMultiSelect,
        required this.selectedIds,
        required this.onChanged,
        required this.activeColor,
        required this.getId,
        required this.getTitle,
        required this.getChildren});

  @override
  State<TreeSelectorWidget<T>> createState() => _TreeSelectorWidgetState<T>();
}

class _TreeSelectorWidgetState<T> extends State<TreeSelectorWidget<T>> {
  late ValueNotifier<Set<int>> _expandedKeys;
  late ValueNotifier<Set<int>> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _expandedKeys = ValueNotifier({});
    _selectedKeys = ValueNotifier(widget.selectedIds.toSet());
  }

  void _handleToggle(int id) {
    HapticFeedback.lightImpact();
    final current = Set<int>.from(_selectedKeys.value);
    if (widget.isMultiSelect) {
      current.contains(id) ? current.remove(id) : current.add(id);
    } else {
      current.clear();
      current.add(id);
    }
    _selectedKeys.value = current;
    widget.onChanged(current.toList());
  }

  void _handleExpand(int id) {
    HapticFeedback.lightImpact();
    final current = Set<int>.from(_expandedKeys.value);
    current.contains(id) ? current.remove(id) : current.add(id);
    _expandedKeys.value = current;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _TreeNode<T>(
            item: widget.items[index],
            depth: 0,
            expandedKeys: _expandedKeys,
            selectedKeys: _selectedKeys,
            onToggle: _handleToggle,
            onExpand: _handleExpand,
            isMultiSelect: widget.isMultiSelect,
            activeColor: widget.activeColor,
            getId: widget.getId,
            getTitle: widget.getTitle,
            getChildren: widget.getChildren);
      },
    );
  }
}

class _TreeNode<T> extends StatelessWidget {
  final T item;
  final int depth;
  final ValueNotifier<Set<int>> expandedKeys;
  final ValueNotifier<Set<int>> selectedKeys;
  final Function(int) onToggle;
  final Function(int) onExpand;
  final bool isMultiSelect;
  final Color activeColor;
  final int Function(T) getId;
  final String Function(T) getTitle;
  final List<T>? Function(T) getChildren;

  const _TreeNode(
      {required this.item,
        required this.depth,
        required this.expandedKeys,
        required this.selectedKeys,
        required this.onToggle,
        required this.onExpand,
        required this.isMultiSelect,
        required this.activeColor,
        required this.getId,
        required this.getTitle,
        required this.getChildren});

  @override
  Widget build(BuildContext context) {
    final id = getId(item);
    final children = getChildren(item);
    final hasChildren = children != null && children.isNotEmpty;
    return ValueListenableBuilder<Set<int>>(
      valueListenable: expandedKeys,
      builder: (context, expandedSet, _) {
        final isExpanded = expandedSet.contains(id);
        return ValueListenableBuilder<Set<int>>(
          valueListenable: selectedKeys,
          builder: (context, selectedSet, _) {
            final isSelected = selectedSet.contains(id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:[
                InkWell(
                  onTap: () => onToggle(id),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 24 + depth * 24.0,
                        right: 24,
                        top: 16,
                        bottom: 16),
                    child: Row(
                      children:[
                        if (isMultiSelect)
                          Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? activeColor
                                  : _EditBillViewState.textSecondary
                                  .withOpacity(0.5),
                              size: 22),
                        if (isMultiSelect) const SizedBox(width: 12),
                        Expanded(
                          child: Text(getTitle(item),
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected && !isMultiSelect
                                      ? activeColor
                                      : _EditBillViewState.textPrimary,
                                  fontWeight: isSelected && !isMultiSelect
                                      ? FontWeight.w600
                                      : FontWeight.w400)),
                        ),
                        if (!isMultiSelect && isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: activeColor, size: 22),
                        if (hasChildren) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onExpand(id),
                            child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F7),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: _EditBillViewState.textSecondary)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (depth == 0 && !isExpanded)
                  const Divider(
                      height: 1, indent: 24, color: Color(0xFFF2F2F7)),
                if (isExpanded && hasChildren)
                  Column(
                    children: children!
                        .map((child) => _TreeNode<T>(
                        item: child,
                        depth: depth + 1,
                        expandedKeys: expandedKeys,
                        selectedKeys: selectedKeys,
                        onToggle: onToggle,
                        onExpand: onExpand,
                        isMultiSelect: isMultiSelect,
                        activeColor: activeColor,
                        getId: getId,
                        getTitle: getTitle,
                        getChildren: getChildren))
                        .toList(),
                  )
              ],
            );
          },
        );
      },
    );
  }
}

class TagSelectorSheetContent extends StatefulWidget {
  final List<TagSelectItem> tags;
  final List<int> selectedIds;
  final Function(List<int>) onChanged;
  final Color activeColor;

  const TagSelectorSheetContent(
      {super.key,
        required this.tags,
        required this.selectedIds,
        required this.onChanged,
        required this.activeColor});

  @override
  State<TagSelectorSheetContent> createState() =>
      _TagSelectorSheetContentState();
}

class _TagSelectorSheetContentState extends State<TagSelectorSheetContent> {
  late List<int> _current;

  @override
  void initState() {
    super.initState();
    _current = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Expanded(
          child: TreeSelectorWidget<TagSelectItem>(
              items: widget.tags,
              isMultiSelect: true,
              selectedIds: _current,
              onChanged: (ids) => setState(() => _current = ids),
              activeColor: widget.activeColor,
              getId: (item) => item.id,
              getTitle: (item) => item.title,
              getChildren: (item) => item.children),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.activeColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onChanged(_current);
                Navigator.pop(context);
              },
              child: const Text('应用选择',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        )
      ],
    );
  }
}

class CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateTimeChanged;
  final Color themeColor;

  const CustomDateTimePicker(
      {super.key,
        required this.initialDate,
        required this.onDateTimeChanged,
        required this.themeColor});

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late FixedExtentScrollController _y, _m, _d, _h, _min;
  late int sY, sM, sD, sH, sMin;
  final int startYear = 2000;

  @override
  void initState() {
    super.initState();
    sY = widget.initialDate.year;
    sM = widget.initialDate.month;
    sD = widget.initialDate.day;
    sH = widget.initialDate.hour;
    sMin = widget.initialDate.minute;
    _y = FixedExtentScrollController(initialItem: sY - startYear);
    _m = FixedExtentScrollController(initialItem: sM - 1);
    _d = FixedExtentScrollController(initialItem: sD - 1);
    _h = FixedExtentScrollController(initialItem: sH);
    _min = FixedExtentScrollController(initialItem: sMin);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        const _ModernSheetHeader(title: '选择时间'),
        Expanded(
          child: DefaultTextStyle(
            style: const TextStyle(
                color: _EditBillViewState.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500),
            child: Row(
              children:[
                _buildPicker(_y, 50, (i) => setState(() => sY = startYear + i),
                        (i) => '${startYear + i}年'),
                _buildPicker(_m, 12, (i) => setState(() => sM = i + 1),
                        (i) => '${i + 1}月'),
                _buildPicker(_d, 31, (i) => setState(() => sD = i + 1),
                        (i) => '${i + 1}日'),
                _buildPicker(
                    _h, 24, (i) => setState(() => sH = i), (i) => '${i}时'),
                _buildPicker(
                    _min, 60, (i) => setState(() => sMin = i), (i) => '${i}分'),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onDateTimeChanged(DateTime(sY, sM, sD, sH, sMin));
              },
              child: const Text('确认',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPicker(FixedExtentScrollController c, int count,
      ValueChanged<int> onChanged, String Function(int) label) {
    return Expanded(
      child: CupertinoPicker.builder(
        scrollController: c,
        itemExtent: 44,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: widget.themeColor.withOpacity(0.08)),
        onSelectedItemChanged: (v) {
          HapticFeedback.selectionClick();
          onChanged(v);
        },
        itemBuilder: (context, index) => Center(child: Text(label(index))),
        childCount: count,
      ),
    );
  }
}