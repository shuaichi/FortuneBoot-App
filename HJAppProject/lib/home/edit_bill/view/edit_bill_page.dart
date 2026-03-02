import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

void _showToast(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? CupertinoColors.destructiveRed : CupertinoColors.activeGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
}
// ==========================================
// 1. PAGE & ENTRY VIEW
// ==========================================

class EditBillPage extends StatelessWidget {
  const EditBillPage({super.key});

  static Route<void> route({BillItemAdd? initialBill, bool isCopyBill = false}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
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
    return BlocListener<EditBillBloc, EditBillState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditBillStatus.failure) {
          _showToast(context, S.current.todosOverviewErrorSnackbarText, isError: true);
        } else if (state.status == EditBillStatus.closed) {
          _showToast(context, state.isNewBill ? '添加成功' : '修改成功');
          Navigator.of(context).pop();
        } else if (state.status == EditBillStatus.submitFailed) {
          _showToast(context, '提交失败', isError: true);
        }
      },
      child: const EditBillView(),
    );
  }

}

class EditBillView extends StatefulWidget {
  const EditBillView({super.key});

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  // --- 核心状态 ---
  final ValueNotifier<int> _activeAmountIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(true);

  // Focus Nodes (系统键盘与自定义键盘互斥控制)
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _remarkFocusNode = FocusNode();

  late List<CategoryAmountItem> _categoryAmountItems;

  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ValueNotifier<bool> _isSecondaryExpanded = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  String? _tempAmountString;

  // iOS Style Theme Colors
  Color _getThemeColor(BillType type) {
    switch (type) {
      case BillType.expenditure:
        return CupertinoColors.activeGreen;
      case BillType.income:
        return CupertinoColors.destructiveRed;
      case BillType.transfer:
        return CupertinoColors.activeBlue;
      default:
        return CupertinoColors.activeGreen;
    }
  }

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
    });
  }

  void _onTextFieldFocusChange() {
    if (_titleFocusNode.hasFocus || _remarkFocusNode.hasFocus) {
      _isKeyboardVisible.value = false;
    }
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

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _remarkFocusNode.dispose();
    _activeAmountIndex.dispose();
    _isKeyboardVisible.dispose();
    _remarkController.dispose();
    _titleController.dispose();
    _isSecondaryExpanded.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _dismissAllKeyboards() {
    FocusScope.of(context).unfocus();
    _isKeyboardVisible.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditBillBloc>().state;
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
    final isTransfer = billType == BillType.transfer;
    final themeColor = _getThemeColor(billType);

    // 浅灰背景提升 iOS 层级感
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _buildAppBar(state, billType, themeColor),
      body: Column(
        children:[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismissAllKeyboards,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers:[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          // 1. 金额及分类区
                          if (isTransfer)
                            _buildTransferAmountSection(state, themeColor)
                          else
                            _buildCategoryAmountList(state, themeColor),

                          const SizedBox(height: 24),

                          // 2. 主表单区
                          _buildMainInfoSection(state, isTransfer, themeColor),

                          const SizedBox(height: 24),

                          // 3. 次要信息区 (平滑折叠)
                          _buildSecondaryInfoSection(state, isTransfer, themeColor),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // 4. 自定义数字键盘
          ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisible,
            builder: (context, visible, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: visible ? 280 : 0, // 优化高度适配刘海屏
                child: Wrap(
                  children:[
                    if (visible) _buildNumericKeyboard(themeColor),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. UI WIDGETS
  // ==========================================

  AppBar _buildAppBar(EditBillState state, BillType currentType, Color themeColor) {
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.clear, color: Colors.black87, size: 24),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _SegmentedTypeSwitcher(
        currentType: currentType,
        isLoading: state.status == EditBillStatus.loading,
        themeColor: themeColor,
        onChanged: (type) {
          _dismissAllKeyboards();
          context.read<EditBillBloc>().add(EditBillTypeChange(type));
          setState(() {
            _activeAmountIndex.value = type == BillType.transfer ? -1 : 0;
            _categoryAmountItems =[CategoryAmountItem(amount: 0.0)];
          });
        },
      ),
      centerTitle: true,
      actions:[
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: state.status.isLoadingOrInit ? null : () {
            _dismissAllKeyboards();
            _submit(state);
          },
          child: state.status.isLoadingOrInit
              ? const CupertinoActivityIndicator()
              : Text('完成', style: TextStyle(color: themeColor, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }

  // --- 转移金额区 (极简大字号) ---
  Widget _buildTransferAmountSection(EditBillState state, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
        const Text('转账金额', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _activeAmountIndex.value = -1;
            _isKeyboardVisible.value = true;
          },
          child: ValueListenableBuilder<int>(
            valueListenable: _activeAmountIndex,
            builder: (_, activeIndex, __) {
              final isActive = activeIndex == -1;
              final amount = state.editBill.data?.amount ?? 0.0;
              final displayText = _formatAmountText(isActive, amount);

              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: isActive ? themeColor : Colors.black87,
                  fontFamily: 'HelveticaNeue', // iOS Standard Number Font
                  letterSpacing: -1.5,
                ),
                child: Text(displayText),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 分类与金额明细列表 (可添加多条) ---
  Widget _buildCategoryAmountList(EditBillState state, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
        ...List.generate(_categoryAmountItems.length, (index) {
          final item = _categoryAmountItems[index];
          final categoryName = _getCategoryName(state.categoryList, item.categoryId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: item.key,
              direction: _categoryAmountItems.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: CupertinoColors.destructiveRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(CupertinoIcons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                setState(() {
                  _categoryAmountItems.removeAt(index);
                  if (_activeAmountIndex.value >= _categoryAmountItems.length) {
                    _activeAmountIndex.value = _categoryAmountItems.length - 1;
                  }
                });
                _syncCategoryAmountToState();
              },
              child: ValueListenableBuilder<int>(
                valueListenable: _activeAmountIndex,
                builder: (_, activeIndex, __) {
                  final isActive = activeIndex == index;
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _activeAmountIndex.value = index;
                      _isKeyboardVisible.value = true;
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? themeColor.withOpacity(0.5) : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow:[
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children:[
                          // 左侧：分类选择
                          GestureDetector(
                            onTap: () => _showCategorySelector(context, state, index, themeColor),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  Icon(
                                    categoryName.isEmpty ? CupertinoIcons.square_grid_2x2 : CupertinoIcons.tag_fill,
                                    size: 16,
                                    color: categoryName.isEmpty ? Colors.black45 : themeColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    categoryName.isEmpty ? '选择分类' : categoryName.split(' > ').last,
                                    style: TextStyle(
                                      color: categoryName.isEmpty ? Colors.black45 : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          // 右侧：大字号金额
                          Text(
                            _formatAmountText(isActive, item.amount),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: isActive ? themeColor : Colors.black87,
                              fontFamily: 'HelveticaNeue',
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),

        // 拆账按钮
        if (_categoryAmountItems.length < 5)
          Align(
            alignment: Alignment.center,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
                  _activeAmountIndex.value = _categoryAmountItems.length - 1;
                  _isKeyboardVisible.value = true;
                });
                _syncCategoryAmountToState();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Icon(CupertinoIcons.add_circled_solid, size: 20, color: themeColor),
                  const SizedBox(width: 6),
                  Text('添加一笔明细', style: TextStyle(color: themeColor, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- 主表单区 ---
  Widget _buildMainInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return _CupertinoFormGroup(
      children:[
        // 标题输入
        _FormRow(
          icon: CupertinoIcons.pen,
          label: '标题',
          customChild: Expanded(
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: '必填',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              onChanged: (v) => state.editBill.data?.title = v,
            ),
          ),
        ),

        // 账户 / 转出账户
        _FormRow(
          icon: isTransfer ? CupertinoIcons.arrow_up_right_circle : CupertinoIcons.creditcard,
          label: isTransfer ? '转出账户' : '账户',
          valueText: _getAccountName(state, state.editBill.data?.accountId),
          placeholder: '请选择',
          onTap: () => _showAccountSelector(context, state, isSource: true),
        ),

        // 转入账户 (仅转账)
        if (isTransfer)
          _FormRow(
            icon: CupertinoIcons.arrow_down_right_circle,
            label: '转入账户',
            valueText: _getAccountName(state, state.editBill.data?.toAccountId),
            placeholder: '请选择',
            onTap: () => _showAccountSelector(context, state, isSource: false),
          ),

        // 时间
        _FormRow(
          icon: CupertinoIcons.clock,
          label: '时间',
          valueText: state.editBill.data?.tradeTime ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          onTap: () => _showTimeSelector(context, state),
        ),

        // 交易对象 (非转账)
        if (!isTransfer)
          _FormRow(
            icon: CupertinoIcons.person,
            label: '交易对象',
            valueText: _getPayeeName(state, state.editBill.data?.payeeId),
            placeholder: '无',
            onTap: () => _showPayeeSelector(context, state),
          ),
      ],
    );
  }

  // --- 次要信息区 (包含动画展开) ---
  Widget _buildSecondaryInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSecondaryExpanded,
      builder: (_, isExpanded, __) {
        return Column(
          children:[
            GestureDetector(
              onTap: () {
                _dismissAllKeyboards();
                _isSecondaryExpanded.value = !isExpanded;
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Text(isExpanded ? '收起更多选项' : '展开更多选项',
                        style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500)),
                    Icon(isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, size: 14, color: Colors.black45),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !isExpanded
                  ? const SizedBox(width: double.infinity, height: 0)
                  : Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _CupertinoFormGroup(
                  children:[
                    _buildTagInfoRow(state, themeColor),
                    _FormRow(
                      icon: CupertinoIcons.text_justify,
                      label: '备注',
                      customChild: Expanded(
                        child: TextField(
                          controller: _remarkController,
                          focusNode: _remarkFocusNode,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            hintText: '选填',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (v) => state.editBill.data?.remark = v,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: AttachmentUploadWidget(
                        initialAttachments: state.attachments,
                        onAttachmentsChanged: (list) => context.read<EditBillBloc>().add(EditBillAttachmentsChanged(list)),
                      ),
                    ),
                    _buildSwitchRow('计入收支统计', state.editBill.data?.include ?? true, isTransfer ? null : (v) => setState(() => state.editBill.data?.include = v), themeColor),
                    _buildSwitchRow('已确认', state.editBill.data?.confirm ?? true, isTransfer ? null : (v) => setState(() => state.editBill.data?.confirm = v), themeColor),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTagInfoRow(EditBillState state, Color themeColor) {
    final hasTags = state.editBill.data?.tagIdList?.isNotEmpty ?? false;
    return InkWell(
      onTap: () => _showTagSelector(context, state, themeColor),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children:[
            const Icon(CupertinoIcons.tag, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            const Text('标签', style: TextStyle(fontSize: 16, color: Colors.black87)),
            const Spacer(),
            if (hasTags)
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 4,
                  children: state.editBill.data!.tagIdList!.map((id) {
                    final tagName = _getTagName(state.tagList, id);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(tagName, style: TextStyle(fontSize: 12, color: themeColor)),
                    );
                  }).toList(),
                ),
              )
            else
              const Text('无', style: TextStyle(color: Colors.black26, fontSize: 16)),
            const SizedBox(width: 4),
            const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, Function(bool)? onChanged, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          CupertinoSwitch(
            value: value,
            activeColor: themeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // --- 数字键盘 (重构为扁平无界风) ---
  Widget _buildNumericKeyboard(Color themeColor) {
    return Container(
      color: const Color(0xFFE5E5EA), // iOS Keyboard background
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          // 顶部收起条
          GestureDetector(
            onTap: () => _isKeyboardVisible.value = false,
            child: Container(
              height: 36,
              color: Colors.transparent,
              child: Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ),
          // 键盘网格
          Container(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            height: 240,
            child: Row(
              children:[
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildKeyRow(['1', '2', '3']),
                      _buildKeyRow(['4', '5', '6']),
                      _buildKeyRow(['7', '8', '9']),
                      _buildKeyRow(['.', '0', '-']), // '-' 放到这里
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children:[
                      _buildActionKey('DEL', CupertinoIcons.delete_left),
                      _buildConfirmKey(themeColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) => _buildNumberKey(key)).toList(),
      ),
    );
  }

  Widget _buildNumberKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyTap(label),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const[BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 0)]),
            child: Center(
              child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black87)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(String key, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: () => _onKeyTap(key),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(color: const Color(0xFFD1D1D6), borderRadius: BorderRadius.circular(10), boxShadow: const[BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 0)]),
            child: Center(child: Icon(icon, color: Colors.black87, size: 24)),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmKey(Color themeColor) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: _dismissAllKeyboards,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(10), boxShadow: const[BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 0)]),
            child: const Center(
              child: Text('完成', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. LOGIC & DATA HANDLING (Keep Intact)
  // ==========================================

  String _formatAmountText(bool isActive, double amount) {
    if (isActive && _tempAmountString != null) {
      String t = _tempAmountString!;
      if (t.isEmpty) return '0.00';
      if (t == '-') return '-0.00';
      if (t == '-0' || t == '-0.') return '-0.00';
      return t;
    } else {
      if (amount == 0) {
        return amount.isNegative ? '-0.00' : '0.00';
      }
      return amount.toStringAsFixed(2);
    }
  }

  void _onKeyTap(String key) {
    final idx = _activeAmountIndex.value;
    final state = context.read<EditBillBloc>().state;

    double currentVal = idx == -1 ? (state.editBill.data?.amount ?? 0) : _categoryAmountItems[idx].amount;

    if (_tempAmountString == null) {
      bool isNegativeZero = currentVal == 0 && (1 / currentVal).isNegative;
      if (isNegativeZero) {
        _tempAmountString = '-0';
      } else {
        _tempAmountString = currentVal == 0 ? '' : currentVal.toString();
        if (_tempAmountString!.endsWith('.0')) {
          _tempAmountString = _tempAmountString!.substring(0, _tempAmountString!.length - 2);
        }
      }
    }

    String strVal = _tempAmountString!;

    if (key == '-') {
      if (strVal.startsWith('-')) {
        strVal = strVal.substring(1);
      } else {
        strVal = strVal.isEmpty ? '-' : '-$strVal';
      }
      if (strVal == '-') strVal = '-0';
    } else if (key == 'DEL') {
      if (strVal.isNotEmpty) {
        strVal = strVal.substring(0, strVal.length - 1);
        if (strVal == '-') strVal = '';
      }
    } else if (key == '.') {
      if (!strVal.contains('.')) {
        if (strVal.isEmpty) strVal = '0.';
        else if (strVal == '-') strVal = '-0.';
        else strVal = '$strVal.';
      }
    } else {
      if (strVal == '-0') {
        if (key != '0') strVal = '-$key';
      } else if (strVal == '0') {
        strVal = key;
      } else {
        if (strVal.contains('.')) {
          if (strVal.split('.')[1].length < 2) strVal += key;
        } else {
          int maxLen = strVal.startsWith('-') ? 10 : 9;
          if (strVal.length < maxLen) strVal += key;
        }
      }
    }

    _tempAmountString = strVal;
    double newVal = 0;
    if (strVal.isNotEmpty && strVal != '-' && strVal != '-0.') {
      newVal = double.tryParse(strVal) ?? 0;
    }
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

  String _getCategoryName(List<CategorySelectItem> categories, int? id) {
    if (id == null) return '';
    return CategorySelectItem.getFullPathById(categories, id);
  }

  String _getAccountName(EditBillState state, int? id) {
    if (id == null) return '';
    for (var i in[...state.expenseAccountList, ...state.incomeAccountList, ...state.transferAccountList]) {
      if (i.value.id == id) return i.label;
    }
    return '';
  }

  String _getPayeeName(EditBillState state, int? id) {
    if (id == null) return '';
    for (var i in state.payeeList) {
      if (i.value.id == id) return i.label;
    }
    return '';
  }

  String _getTagName(List<TagSelectItem> tags, int id) => TagSelectItem.getFullPathById(tags, id);

  void _submit(EditBillState state) {
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);
    if (billType == BillType.transfer) {
      if ((state.editBill.data?.amount ?? 0) <= 0) {
        _showToast(context, '请输入金额', isError: true); return;
      }
      if (state.editBill.data?.accountId == null || state.editBill.data?.toAccountId == null) {
        _showToast(context, '请选择转账账户', isError: true); return;
      }
    } else {
      if (_categoryAmountItems.isEmpty || _categoryAmountItems.every((e) => e.amount == 0)) {
        _showToast(context, '请输入金额', isError: true); return;
      }
      if (_categoryAmountItems.any((e) => e.categoryId == null)) {
        _showToast(context, '请完善分类选择', isError: true); return;
      }
      if (state.editBill.data?.title?.isEmpty ?? true) {
        _showToast(context, '请输入标题', isError: true); return;
      }
    }
    context.read<EditBillBloc>().add(EditBillSubmitted());
  }

  // ==========================================
  // 4. BOTTOM SHEETS (Re-styled to iOS)
  // ==========================================

  void _showCategorySelector(BuildContext context, EditBillState state, int index, Color themeColor) {
    _dismissAllKeyboards();
    _showNativeBottomSheet(
      context: context,
      title: '选择分类',
      child: TreeSelectorWidget<CategorySelectItem>(
        items: state.categoryList,
        isMultiSelect: false,
        selectedIds: _categoryAmountItems[index].categoryId != null ? [_categoryAmountItems[index].categoryId!] :[],
        activeColor: themeColor,
        getId: (item) => item.id,
        getTitle: (item) => item.title,
        getChildren: (item) => item.children,
        onChanged: (ids) {
          if (ids.isNotEmpty) {
            setState(() => _categoryAmountItems[index].categoryId = ids.first);
            _syncCategoryAmountToState();
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showTagSelector(BuildContext context, EditBillState state, Color themeColor) {
    _dismissAllKeyboards();
    List<int> tempSelected = List.from(state.editBill.data?.tagIdList ??[]);
    _showNativeBottomSheet(
      context: context,
      title: '选择标签',
      actionTitle: '确定',
      actionColor: themeColor,
      onAction: () {
        setState(() => state.editBill.data?.tagIdList = tempSelected);
        Navigator.pop(context);
      },
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return TreeSelectorWidget<TagSelectItem>(
            items: state.tagList,
            isMultiSelect: true,
            selectedIds: tempSelected,
            activeColor: themeColor,
            getId: (item) => item.id,
            getTitle: (item) => item.title,
            getChildren: (item) => item.children,
            onChanged: (ids) => tempSelected = ids,
          );
        },
      ),
    );
  }

  void _showAccountSelector(BuildContext context, EditBillState state, {required bool isSource}) {
    _dismissAllKeyboards();
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
    List<DropdownItem<AccountSelectItem>> list = billType == BillType.transfer
        ? (isSource ? state.transferOutAccountList : state.transferAccountList)
        : (billType == BillType.income ? state.incomeAccountList : state.expenseAccountList);

    _showNativeBottomSheet(
      context: context,
      title: isSource ? '转出账户' : '转入账户',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
        itemBuilder: (_, i) => ListTile(
          title: Text(list[i].label, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black26),
          onTap: () {
            setState(() {
              if (billType == BillType.transfer) {
                if (isSource) state.editBill.data?.accountId = list[i].value.id;
                else state.editBill.data?.toAccountId = list[i].value.id;
              } else {
                state.editBill.data?.accountId = list[i].value.id;
              }
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showPayeeSelector(BuildContext context, EditBillState state) {
    _dismissAllKeyboards();
    _showNativeBottomSheet(
      context: context,
      title: '选择交易对象',
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: state.payeeList.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
        itemBuilder: (_, i) => ListTile(
          title: Text(state.payeeList[i].label, style: const TextStyle(fontSize: 16)),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black26),
          onTap: () {
            setState(() => state.editBill.data?.payeeId = state.payeeList[i].value.id);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showTimeSelector(BuildContext context, EditBillState state) {
    _dismissAllKeyboards();
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(state.editBill.data?.tradeTime ?? '');
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        DateTime tempDate = initialDate;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                height: 50,
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    CupertinoButton(child: const Text('取消', style: TextStyle(color: Colors.black54)), onPressed: () => Navigator.pop(context)),
                    const Text('选择时间', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    CupertinoButton(child: const Text('确定'), onPressed: () {
                      setState(() => state.editBill.data?.tradeTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(tempDate));
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
              SizedBox(
                height: 250,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (dt) => tempDate = dt,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNativeBottomSheet({required BuildContext context, required String title, required Widget child, String? actionTitle, Color? actionColor, VoidCallback? onAction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children:[
            Container(
              height: 56,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
              child: Stack(
                children:[
                  Center(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  if (actionTitle != null && onAction != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 16), onPressed: onAction, child: Text(actionTitle, style: TextStyle(color: actionColor, fontWeight: FontWeight.w600))),
                    )
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. REUSABLE UI COMPONENTS
// ==========================================

class CategoryAmountItem {
  int? categoryId;
  double amount;
  final UniqueKey key;
  CategoryAmountItem({this.categoryId, required this.amount}) : key = UniqueKey();
}

/// 顶部 iOS 风格段控器
class _SegmentedTypeSwitcher extends StatelessWidget {
  final BillType currentType;
  final bool isLoading;
  final Color themeColor;
  final ValueChanged<BillType> onChanged;

  const _SegmentedTypeSwitcher({required this.currentType, required this.isLoading, required this.themeColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(
        children:[
          _buildSegment(BillType.expenditure, '支出'),
          _buildSegment(BillType.income, '收入'),
          _buildSegment(BillType.transfer, '转账'),
        ],
      ),
    );
  }

  Widget _buildSegment(BillType type, String label) {
    final isSelected = type == currentType;
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : () => onChanged(type),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ?[const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS 风格的表单组 (白色卡片包含多行)
class _CupertinoFormGroup extends StatelessWidget {
  final List<Widget> children;
  const _CupertinoFormGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children:[
              child,
              if (index < children.length - 1)
                const Divider(height: 1, indent: 48, endIndent: 16, color: Color(0xFFE5E5EA)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 通用表单行
class _FormRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? valueText;
  final String? placeholder;
  final Widget? customChild;
  final VoidCallback? onTap;

  const _FormRow({required this.icon, required this.label, this.valueText, this.placeholder, this.customChild, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText != null && valueText!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children:[
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(width: 16),
            if (customChild != null)
              customChild!
            else ...[
              const Spacer(),
              Text(
                hasValue ? valueText! : (placeholder ?? ''),
                style: TextStyle(fontSize: 16, color: hasValue ? Colors.black87 : Colors.black26),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.black26),
            ]
          ],
        ),
      ),
    );
  }
}

// --- 高级树形选择器 (保持您原有算法，优化UI) ---
class TreeSelectorWidget<T> extends StatefulWidget {
  final List<T> items;
  final bool isMultiSelect;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onChanged;
  final Color activeColor;
  final int Function(T) getId;
  final String Function(T) getTitle;
  final List<T>? Function(T) getChildren;

  const TreeSelectorWidget({
    super.key, required this.items, required this.isMultiSelect, required this.selectedIds, required this.onChanged,
    required this.activeColor, required this.getId, required this.getTitle, required this.getChildren,
  });

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
    final current = Set<int>.from(_selectedKeys.value);
    if (widget.isMultiSelect) {
      if (current.contains(id)) current.remove(id); else current.add(id);
    } else {
      current.clear(); current.add(id);
    }
    _selectedKeys.value = current;
    widget.onChanged(current.toList());
  }

  void _handleExpand(int id) {
    final current = Set<int>.from(_expandedKeys.value);
    if (current.contains(id)) current.remove(id); else current.add(id);
    _expandedKeys.value = current;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _TreeNode<T>(
          item: widget.items[index], depth: 0, expandedKeys: _expandedKeys, selectedKeys: _selectedKeys,
          onToggle: _handleToggle, onExpand: _handleExpand, isMultiSelect: widget.isMultiSelect,
          activeColor: widget.activeColor, getId: widget.getId, getTitle: widget.getTitle, getChildren: widget.getChildren,
        );
      },
    );
  }
}

class _TreeNode<T> extends StatelessWidget {
  final T item; final int depth; final ValueNotifier<Set<int>> expandedKeys; final ValueNotifier<Set<int>> selectedKeys;
  final Function(int) onToggle; final Function(int) onExpand; final bool isMultiSelect; final Color activeColor;
  final int Function(T) getId; final String Function(T) getTitle; final List<T>? Function(T) getChildren;

  const _TreeNode({
    required this.item, required this.depth, required this.expandedKeys, required this.selectedKeys, required this.onToggle, required this.onExpand,
    required this.isMultiSelect, required this.activeColor, required this.getId, required this.getTitle, required this.getChildren,
  });

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
              children:[
                InkWell(
                  onTap: () => onToggle(id),
                  child: Padding(
                    padding: EdgeInsets.only(left: 16 + depth * 24.0, right: 16, top: 14, bottom: 14),
                    child: Row(
                      children:[
                        if (isMultiSelect)
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 22, height: 22,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? activeColor : Colors.black26, width: 2), color: isSelected ? activeColor : Colors.transparent),
                            child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        Expanded(child: Text(getTitle(item), style: TextStyle(fontSize: 16, color: isSelected && !isMultiSelect ? activeColor : Colors.black87, fontWeight: isSelected && !isMultiSelect ? FontWeight.w600 : FontWeight.normal))),
                        if (!isMultiSelect && isSelected) Icon(CupertinoIcons.checkmark_alt, size: 20, color: activeColor),
                        if (hasChildren) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onExpand(id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(6)),
                              child: Icon(isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down, size: 16, color: Colors.black54),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (depth == 0) const Divider(height: 1, indent: 16, color: Color(0xFFE5E5EA)),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200), curve: Curves.easeOutCubic, alignment: Alignment.topCenter,
                  child: isExpanded && hasChildren
                      ? Column(children: children!.map((child) => _TreeNode<T>(item: child, depth: depth + 1, expandedKeys: expandedKeys, selectedKeys: selectedKeys, onToggle: onToggle, onExpand: onExpand, isMultiSelect: isMultiSelect, activeColor: activeColor, getId: getId, getTitle: getTitle, getChildren: getChildren)).toList())
                      : const SizedBox(width: double.infinity, height: 0),
                ),
              ],
            );
          },
        );
      },
    );
  }
}