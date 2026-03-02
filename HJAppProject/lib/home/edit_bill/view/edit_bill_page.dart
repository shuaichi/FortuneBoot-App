import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

// --- 假设以下为您项目中的原有导入 ---
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

// ==========================================
// 核心页面入口
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
    return MultiBlocListener(
      listeners:[
        BlocListener<EditBillBloc, EditBillState>(
          listenWhen: (prev, cur) => prev.status != cur.status,
          listener: (context, state) {
            if (state.status == EditBillStatus.failure) {
              _showToast(context, S.current.todosOverviewErrorSnackbarText);
            } else if (state.status == EditBillStatus.closed) {
              _showToast(context, state.isNewBill ? '添加成功' : '修改成功');
              Navigator.of(context).pop();
            } else if (state.status == EditBillStatus.submitFailed) {
              _showToast(context, '添加失败');
            }
          },
        ),
      ],
      child: const EditBillView(),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
  }
}

// ==========================================
// 主视图视图 (Stateful)
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
      _isKeyboardVisible.value = false;
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
    super.dispose();
  }

  BillType _currentBillType(EditBillState state) {
    return BillType.fromValue(state.editBill.data?.billType ?? 1) ??
        BillType.expenditure;
  }

  String _getCategoryName(List<CategorySelectItem> categories, int? id) {
    if (id == null) return '';
    // 如果有 getFullPathById 方法则调用，否则做普通查找回退
    try {
      return CategorySelectItem.getFullPathById(categories, id);
    } catch (_) {
      return categories.firstWhere((e) => e.id == id, orElse: () => categories.first).title;
    }
  }

  String _getTagsDisplay(EditBillState state) {
    final ids = state.editBill.data?.tagIdList ??[];
    if (ids.isEmpty) return '请选择';
    try {
      return ids.map((id) => TagSelectItem.getFullPathById(state.tagList, id)).join(', ');
    } catch (_) {
      return '已选择 ${ids.length} 个标签';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditBillBloc>().state;
    final status = state.status;
    final isNewBill = state.isNewBill;
    final billType = _currentBillType(state);

    // 拦截余额调整
    final bool isAdjust = state.initialBill != null && billType == BillType.adjust;
    if (isAdjust) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('余额调整账单不支持复制或编辑')),
        );
        Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    // 状态初始化补全
    _syncFormStates(state, billType);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          isNewBill ? '记一笔' : '编辑账单',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children:[
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _isKeyboardVisible.value = false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers:[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildBillTypeSelector(billType),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:[
                            // ==========================================
                            // 1. 常驻核心信息区块
                            // ==========================================
                            _SectionGroup(
                              children:[
                                _buildTitleInput(state),
                                const Divider(height: 1, indent: 48),
                                _buildAmountAndCategory(state, billType),
                                const Divider(height: 1, indent: 48),
                                _buildAccountPrimary(state, billType),
                                const Divider(height: 1, indent: 48),
                                _buildTimeSelector(state),
                                const Divider(height: 1, indent: 48),
                                _buildTagSectionModalTrigger(state),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 展开/收起 触发器
                            Center(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _isMoreExpanded,
                                builder: (context, expanded, child) {
                                  return TextButton.icon(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      _isKeyboardVisible.value = false;
                                      _isMoreExpanded.value = !expanded;
                                    },
                                    icon: Icon(
                                        expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.black54),
                                    label: Text(expanded ? '收起更多选项' : '展开更多选项',
                                        style: const TextStyle(color: Colors.black54)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ==========================================
                            // 2. 附加信息区块 (默认折叠)
                            // ==========================================
                            ValueListenableBuilder<bool>(
                              valueListenable: _isMoreExpanded,
                              builder: (context, expanded, child) {
                                if (!expanded) return const SizedBox.shrink();
                                return Column(
                                  children:[
                                    _SectionGroup(
                                      children: [
                                        if (billType != BillType.transfer) ...[
                                          _buildPayeeSecondary(state),
                                          const Divider(height: 1, indent: 48),
                                        ],
                                        _buildRemarkInput(state),
                                        const Divider(height: 1),
                                        Row(
                                          children:[
                                            Expanded(child: _buildConfirmSwitch(state, billType)),
                                            Container(width: 1, height: 32, color: Colors.black12),
                                            Expanded(child: _buildIncludeSwitch(state, billType)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _SectionGroup(
                                      padding: const EdgeInsets.all(16),
                                      children:[
                                        AttachmentUploadWidget(
                                          initialAttachments: state.attachments,
                                          onAttachmentsChanged: (attachments) {
                                            context.read<EditBillBloc>().add(EditBillAttachmentsChanged(attachments));
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 底部悬浮按钮
            ValueListenableBuilder<bool>(
              valueListenable: _isKeyboardVisible,
              builder: (context, visible, child) {
                if (visible) return const SizedBox.shrink();
                return _buildBottomActionBar(status, state);
              },
            ),
            // 自定义数字键盘
            ValueListenableBuilder<bool>(
              valueListenable: _isKeyboardVisible,
              builder: (context, visible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: visible ? 280 + MediaQuery.of(context).padding.bottom : 0,
                  child: visible ? _buildNumericKeyboard() : const SizedBox.shrink(),
                );
              },
            ),
          ],
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
  // 组件: 分段控制器 (账单类型)
  // ==========================================
  Widget _buildBillTypeSelector(BillType currentType) {
    final enable = context.read<EditBillBloc>().state.status != EditBillStatus.loading;

    return Center(
      child: Opacity(
        opacity: enable ? 1.0 : 0.5,
        child: IgnorePointer(
          ignoring: !enable,
          child: CupertinoSlidingSegmentedControl<BillType>(
            backgroundColor: CupertinoColors.tertiarySystemFill,
            thumbColor: Colors.white,
            groupValue: currentType,
            children: {
              BillType.expenditure: _segmentText('支出'),
              BillType.income: _segmentText('收入'),
              BillType.transfer: _segmentText('转账'),
            },
            onValueChanged: (BillType? newSelection) {
              if (newSelection == null) return;

              if (newSelection == BillType.transfer) {
                _confirm.value = true;
                _include.value = true;
                context.read<EditBillBloc>().state.editBill.data?.confirm = true;
                context.read<EditBillBloc>().state.editBill.data?.include = true;
              }
              context.read<EditBillBloc>().add(EditBillTypeChange(newSelection));

              setState(() {
                _activeAmountIndex.value = newSelection == BillType.transfer ? -1 : 0;
                _categoryAmountItems = [CategoryAmountItem(amount: 0.0)];
                _tempAmountString = null;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _segmentText(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  );

  // ==========================================
  // 组件: 标题输入
  // ==========================================
  Widget _buildTitleInput(EditBillState state) {
    return _FormRowWidget(
      label: '标题',
      icon: Icons.title,
      iconColor: Colors.black54,
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '请输入标题',
          hintStyle: TextStyle(color: Colors.black26),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) => state.editBill.data?.title = val,
      ),
    );
  }

  // ==========================================
  // 组件: 分类选择与金额输入
  // ==========================================
  Widget _buildAmountAndCategory(EditBillState state, BillType billType) {
    final activeThemeColor = const Color(0xFF007AFF);

    if (billType == BillType.transfer) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('金额', style: TextStyle(fontSize: 14, color: Colors.grey)),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                _activeAmountIndex.value = -1;
                _isKeyboardVisible.value = true;
              },
              behavior: HitTestBehavior.opaque,
              child: ValueListenableBuilder<int>(
                valueListenable: _activeAmountIndex,
                builder: (_, activeIndex, __) {
                  final isActive = activeIndex == -1;
                  final amount = state.editBill.data?.amount ?? 0.0;
                  return Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children:[
                        const Text('¥', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text(
                          _formatAmountString(isActive, amount),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: isActive ? activeThemeColor : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:[
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _categoryAmountItems.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 48),
          itemBuilder: (context, index) {
            final item = _categoryAmountItems[index];
            final categoryName = _getCategoryName(state.categoryList, item.categoryId);

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
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: const Color(0xFFFF3B30),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _activeAmountIndex,
                builder: (_, activeIndex, __) {
                  final isActive = activeIndex == index;
                  return Container(
                    color: isActive ? activeThemeColor.withOpacity(0.04) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _isKeyboardVisible.value = false;
                            _showCategorySelector(context, state, index, activeThemeColor);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: activeThemeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: activeThemeColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                Icon(Icons.category_rounded, color: activeThemeColor, size: 18),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 120),
                                  child: Text(
                                    categoryName.isEmpty ? '选择分类' : categoryName.split(' > ').last,
                                    style: TextStyle(
                                        color: activeThemeColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _activeAmountIndex.value = index;
                              _isKeyboardVisible.value = true;
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children:[
                                const SizedBox(height: 4),
                                Text(
                                  _formatAmountString(isActive, item.amount),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: isActive ? activeThemeColor : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (_categoryAmountItems.length < 5) ...[
          const Divider(height: 1, indent: 16),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
                _activeAmountIndex.value = _categoryAmountItems.length - 1;
                _isKeyboardVisible.value = true;
              });
              _syncCategoryAmountToState();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text('+ 添加多分类明细',
                  style: TextStyle(color: activeThemeColor, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]
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

  // ==========================================
  // 组件: 账户选取 (Primary)
  // ==========================================
  Widget _buildAccountPrimary(EditBillState state, BillType billType) {
    if (billType == BillType.transfer) {
      final inItems = state.transferAccountList;
      final outItems = state.transferOutAccountList;
      final outId = state.editBill.data?.accountId ?? state.defaultTransferOutAccountId;
      final inId = state.editBill.data?.toAccountId ?? state.defaultTransferInAccountId;
      final outItem = outItems.where((i) => i.value.id == outId).firstOrNull?.value;
      final inItem = inItems.where((i) => i.value.id == inId).firstOrNull?.value;

      if (state.editBill.data?.accountId == null && outItem != null) state.editBill.data?.accountId = outItem.id;
      if (state.editBill.data?.toAccountId == null && inItem != null) state.editBill.data?.toAccountId = inItem.id;

      return Column(
        children:[
          _FormRowWidget(
            label: '转出账户',
            icon: Icons.arrow_upward_rounded,
            iconColor: Colors.orange,
            valueText: outItem?.title ?? '请选择',
            onTap: () {
              FocusScope.of(context).unfocus();
              _isKeyboardVisible.value = false;
              _showPickerBottomSheet(
                title: '选择转出账户',
                items: outItems,
                currentId: outItem?.id,
                onSelected: (val) => setState(() => state.editBill.data?.accountId = val.id),
              );
            },
          ),
          const Divider(height: 1, indent: 48),
          _FormRowWidget(
            label: '转入账户',
            icon: Icons.arrow_downward_rounded,
            iconColor: Colors.blue,
            valueText: inItem?.title ?? '请选择',
            onTap: () {
              FocusScope.of(context).unfocus();
              _isKeyboardVisible.value = false;
              _showPickerBottomSheet(
                title: '选择转入账户',
                items: inItems,
                currentId: inItem?.id,
                onSelected: (val) => setState(() => state.editBill.data?.toAccountId = val.id),
              );
            },
          ),
        ],
      );
    } else {
      final items = billType == BillType.income ? state.incomeAccountList : state.expenseAccountList;
      final accId = state.editBill.data?.accountId ??
          (billType == BillType.income ? state.defaultIncomeAccountId : state.defaultExpenseAccountId);
      final accItem = items.where((i) => i.value.id == accId).firstOrNull?.value;

      if (state.editBill.data?.accountId == null && accItem != null) state.editBill.data?.accountId = accItem.id;

      return _FormRowWidget(
        label: '账户',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Colors.blue,
        valueText: accItem?.title ?? '请选择账户',
        onTap: () {
          FocusScope.of(context).unfocus();
          _isKeyboardVisible.value = false;
          _showPickerBottomSheet(
            title: '选择账户',
            items: items,
            currentId: accItem?.id,
            onSelected: (val) => setState(() => state.editBill.data?.accountId = val.id),
          );
        },
      );
    }
  }

  // ==========================================
  // 组件: 交易对象选取 (Secondary)
  // ==========================================
  Widget _buildPayeeSecondary(EditBillState state) {
    final payeeItems = state.payeeList;
    final payeeItem = payeeItems.where((i) => i.value.id == state.editBill.data?.payeeId).firstOrNull?.value;

    return _FormRowWidget(
      label: '交易对象',
      icon: Icons.storefront_rounded,
      iconColor: Colors.purple,
      valueText: payeeItem?.title ?? '请选择',
      onTap: () {
        FocusScope.of(context).unfocus();
        _isKeyboardVisible.value = false;
        _showPickerBottomSheet(
          title: '选择交易对象',
          items: payeeItems,
          currentId: payeeItem?.id,
          onSelected: (val) => setState(() => state.editBill.data?.payeeId = val.id),
        );
      },
    );
  }

  // ==========================================
  // 组件: 时间选择 (Primary)
  // ==========================================
  Widget _buildTimeSelector(EditBillState state) {
    return ValueListenableBuilder<String?>(
      valueListenable: _tradeTimeStr,
      builder: (context, value, child) {
        final displayTime = state.editBill.data?.tradeTime ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        return _FormRowWidget(
          label: '日期',
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.redAccent,
          valueText: displayTime,
          onTap: () {
            FocusScope.of(context).unfocus();
            _isKeyboardVisible.value = false;
            _showCustomDateTimePicker(context, value ?? displayTime, state);
          },
        );
      },
    );
  }

  // ==========================================
  // 组件: 标签选择 (Modal Trigger)
  // ==========================================
  Widget _buildTagSectionModalTrigger(EditBillState state) {
    return _FormRowWidget(
      label: '标签',
      icon: Icons.local_offer_rounded,
      iconColor: Colors.green,
      valueText: _getTagsDisplay(state),
      onTap: () {
        FocusScope.of(context).unfocus();
        _isKeyboardVisible.value = false;
        _showTagSelector(context, state, const Color(0xFF007AFF));
      },
    );
  }

  // ==========================================
  // 组件: 备注与开关 (Secondary)
  // ==========================================
  Widget _buildRemarkInput(EditBillState state) {
    return _FormRowWidget(
      label: '备注',
      icon: Icons.edit_note_rounded,
      iconColor: Colors.grey,
      child: TextField(
        controller: _remarkController,
        focusNode: _remarkFocusNode,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.right,
        maxLines: null,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '添加备注...',
          hintStyle: TextStyle(color: Colors.black26),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) => state.editBill.data?.remark = val,
      ),
    );
  }

  Widget _buildConfirmSwitch(EditBillState state, BillType billType) {
    final isTransfer = billType == BillType.transfer;
    return ValueListenableBuilder<bool?>(
      valueListenable: _confirm,
      builder: (_, confirm, __) => _CompactToggle(
        label: '确认入账',
        icon: Icons.verified_rounded,
        iconColor: Colors.teal,
        value: isTransfer ? true : (confirm ?? true),
        onChanged: isTransfer
            ? null
            : (val) {
          state.editBill.data?.confirm = val;
          _confirm.value = val;
        },
        activeColor: const Color(0xFF007AFF),
      ),
    );
  }

  Widget _buildIncludeSwitch(EditBillState state, BillType billType) {
    final isTransfer = billType == BillType.transfer;
    return ValueListenableBuilder<bool?>(
      valueListenable: _include,
      builder: (_, include, __) => _CompactToggle(
        label: '纳入统计',
        icon: Icons.bar_chart_rounded,
        iconColor: Colors.indigo,
        value: isTransfer ? true : (include ?? true),
        onChanged: isTransfer
            ? null
            : (val) {
          state.editBill.data?.include = val;
          _include.value = val;
        },
        activeColor: const Color(0xFF007AFF),
      ),
    );
  }

  // ==========================================
  // 组件: 底部操作栏
  // ==========================================
  Widget _buildBottomActionBar(EditBillStatus status, EditBillState state) {
    final isLoading = status.isLoadingOrInit;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isLoading
                ? null
                : () {
              FocusScope.of(context).unfocus();
              _isKeyboardVisible.value = false;
              _submitBill(state.editBill, state);
            },
            child: isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text('保存账单', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 底部数字键盘
  // ==========================================
  Widget _buildNumericKeyboard() {
    return Container(
      color: const Color(0xFFD1D5DB),
      child: SafeArea(
        top: false,
        child: Column(
          children:[
            Container(
              height: 40,
              color: const Color(0xFFF2F2F7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  IconButton(
                    icon: const Icon(Icons.keyboard_hide_rounded, color: Colors.black54),
                    onPressed: () => _isKeyboardVisible.value = false,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children:[
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
                        _buildKey('-', Colors.white, Colors.black87, flex: 1),
                        _buildKey('完成', const Color(0xFF007AFF), Colors.white, flex: 3, isBold: true, onTap: () {
                          FocusScope.of(context).unfocus();
                          _isKeyboardVisible.value = false;
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((key) => _buildKey(key, Colors.white, Colors.black87)).toList(),
      ),
    );
  }

  Widget _buildKey(String key, Color bgColor, Color textColor, {int flex = 1, bool isBold = false, VoidCallback? onTap}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap ?? () => _onKeyTap(key),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(top: 1, right: 1),
          color: bgColor,
          alignment: Alignment.center,
          child: key == 'DEL'
              ? Icon(Icons.backspace_rounded, size: 24, color: textColor)
              : Text(
            key,
            style: TextStyle(
              fontSize: key == '完成' ? 20 : 28,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: textColor,
              fontFamily: key == '完成' ? null : 'RobotoMono',
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyTap(String key) {
    final idx = _activeAmountIndex.value;
    final state = context.read<EditBillBloc>().state;

    double currentVal;
    if (idx == -1) {
      currentVal = state.editBill.data?.amount ?? 0;
    } else {
      currentVal = _categoryAmountItems[idx].amount;
    }

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
        if (strVal.isEmpty) {
          strVal = '0.';
        } else if (strVal == '-') {
          strVal = '-0.';
        } else {
          strVal = '$strVal.';
        }
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
    if (strVal == '-0' || strVal == '-0.') {
      newVal = -0.0;
    }

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
  // Category Selector Sheet
  // ==========================================
  void _showCategorySelector(BuildContext context, EditBillState state, int index, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: CategorySelectorSheet(
            categories: state.categoryList,
            activeColor: themeColor,
            selectedId: _categoryAmountItems[index].categoryId,
            onSelected: (id) {
              setState(() => _categoryAmountItems[index].categoryId = id);
              _syncCategoryAmountToState();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Tag Selector Sheet
  // ==========================================
  void _showTagSelector(BuildContext context, EditBillState state, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: TagSelectorSheet(
            tags: state.tagList,
            activeColor: themeColor,
            selectedIds: state.editBill.data?.tagIdList ??[],
            onChanged: (ids) => setState(() => state.editBill.data?.tagIdList = ids),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 业务逻辑: 提交校验
  // ==========================================
  void _submitBill(BillItemAdd billItemAdd, EditBillState state) {
    if (billItemAdd.data?.title?.trim().isEmpty ?? true) {
      _showToast('请填入标题');
      return;
    }

    if (billItemAdd.data?.billType == BillType.transfer.value) {
      if (billItemAdd.data?.amount == null || billItemAdd.data!.amount == 0) {
        _showToast('请填入非零金额');
        return;
      }
      if (billItemAdd.data?.accountId == null || billItemAdd.data?.toAccountId == null) {
        _showToast('请选择转入及转出账户');
        return;
      }
    } else {
      if (_categoryAmountItems.isEmpty) {
        _showToast('请输入金额');
        return;
      }
      if (_categoryAmountItems.any((e) => e.categoryId == null)) {
        _showToast('请选择分类');
        return;
      }
    }
    context.read<EditBillBloc>().add(EditBillSubmitted());
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  // ==========================================
  // 通用 Picker BottomSheet
  // ==========================================
  void _showPickerBottomSheet<T extends BaseSelectItem>({
    required String title,
    required List<DropdownItem<T>> items,
    required int? currentId,
    required Function(T) onSelected,
  }) {
    if (items.isEmpty) {
      _showToast('暂无可选数据');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            _BottomSheetHeader(title: title),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  final isSelected = currentId == item.value.id;
                  return ListTile(
                    title: Text(item.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF007AFF) : Colors.black87,
                        )),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF007AFF)) : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      onSelected(item.value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateTimePicker(BuildContext context, String currentValue, EditBillState state) {
    DateTime initDate;
    try {
      initDate = currentValue.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(currentValue)
          : DateTime.now();
    } catch (_) {
      try {
        initDate = currentValue.isNotEmpty
            ? DateFormat('yyyy-MM-dd HH:mm').parse(currentValue)
            : DateTime.now();
      } catch (_) {
        initDate = DateTime.now();
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: 360,
          child: CustomDateTimePicker(
            initialDate: initDate,
            onDateTimeChanged: (DateTime newDate) {
              _tradeTimeStr.value = DateFormat('yyyy-MM-dd HH:mm:ss').format(newDate);
              state.editBill.data?.tradeTime = _tradeTimeStr.value;
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 辅助 Widget: 表单包裹卡片
// ==========================================
class _SectionGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const _SectionGroup({required this.children, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

// ==========================================
// 辅助 Widget: 表单列表行 (iOS Inset Row)
// ==========================================
class _FormRowWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String? valueText;
  final Widget? child;
  final Widget? rightWidget;
  final VoidCallback? onTap;
  final bool showChevron;

  const _FormRowWidget({
    required this.label,
    required this.icon,
    this.iconColor = Colors.black54,
    this.valueText,
    this.child,
    this.rightWidget,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children:[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(width: 16),
            Expanded(
              child: child ??
                  Text(
                    valueText ?? '',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      color: valueText == null || valueText!.contains('请选择') ? Colors.black38 : Colors.black87,
                    ),
                  ),
            ),
            if (rightWidget != null) ...[
              const SizedBox(width: 8),
              rightWidget!
            ] else if (onTap != null && showChevron) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 辅助 Widget: 紧凑型 Switch 行 (Side-by-side)
// ==========================================
class _CompactToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  const _CompactToggle({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Transform.scale(
            scale: 0.8, // shrink to fit gracefully
            child: CupertinoSwitch(
              activeColor: activeColor,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 辅助 Widget: 底部弹窗 Header
// ==========================================
class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final Widget? rightAction;

  const _BottomSheetHeader({required this.title, this.rightAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children:[
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.black54, fontSize: 16)),
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          if (rightAction != null) Positioned(right: 0, child: rightAction!),
        ],
      ),
    );
  }
}

// ==========================================
// Models & Data Handling Components
// ==========================================

class CategoryAmountItem {
  int? categoryId;
  double amount;
  final UniqueKey key;

  CategoryAmountItem({this.categoryId, required this.amount}) : key = UniqueKey();
}

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
    super.key,
    required this.items,
    required this.isMultiSelect,
    required this.selectedIds,
    required this.onChanged,
    required this.activeColor,
    required this.getId,
    required this.getTitle,
    required this.getChildren,
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

  @override
  void dispose() {
    _expandedKeys.dispose();
    _selectedKeys.dispose();
    super.dispose();
  }

  void _handleToggle(int id) {
    final current = Set<int>.from(_selectedKeys.value);
    if (widget.isMultiSelect) {
      if (current.contains(id)) {
        current.remove(id);
      } else {
        current.add(id);
      }
    } else {
      current.clear();
      current.add(id);
    }
    _selectedKeys.value = current;
    widget.onChanged(current.toList());
  }

  void _handleExpand(int id) {
    final current = Set<int>.from(_expandedKeys.value);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
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
          getChildren: widget.getChildren,
        );
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

  const _TreeNode({
    required this.item,
    required this.depth,
    required this.expandedKeys,
    required this.selectedKeys,
    required this.onToggle,
    required this.onExpand,
    required this.isMultiSelect,
    required this.activeColor,
    required this.getId,
    required this.getTitle,
    required this.getChildren,
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:[
                InkWell(
                  onTap: () => onToggle(id),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20 + depth * 24.0, right: 20, top: 16, bottom: 16),
                    child: Row(
                      children:[
                        if (isMultiSelect)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? activeColor : Colors.black54.withOpacity(0.5),
                              size: 22,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            getTitle(item),
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected && !isMultiSelect ? activeColor : Colors.black87,
                              fontWeight: isSelected && !isMultiSelect ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (!isMultiSelect && isSelected)
                          Icon(Icons.check_rounded, size: 24, color: activeColor),
                        if (hasChildren) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => onExpand(id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(8)),
                              child: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: Colors.black54),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (depth == 0 && !isExpanded) const Divider(height: 1, indent: 20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: isExpanded && hasChildren
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
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
                      getChildren: getChildren,
                    ))
                        .toList(),
                  )
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

class CategorySelectorSheet extends StatelessWidget {
  final List<CategorySelectItem> categories;
  final int? selectedId;
  final Function(int) onSelected;
  final Color activeColor;

  const CategorySelectorSheet({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.center,
          child: Column(
            children:[
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Text('选择分类', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TreeSelectorWidget<CategorySelectItem>(
            items: categories,
            isMultiSelect: false,
            selectedIds: selectedId != null ? [selectedId!] :[],
            onChanged: (ids) {
              if (ids.isNotEmpty) onSelected(ids.first);
            },
            activeColor: activeColor,
            getId: (item) => item.id,
            getTitle: (item) => item.title,
            getChildren: (item) => item.children,
          ),
        ),
      ],
    );
  }
}

class TagSelectorSheet extends StatefulWidget {
  final List<TagSelectItem> tags;
  final List<int> selectedIds;
  final Function(List<int>) onChanged;
  final Color activeColor;

  const TagSelectorSheet({
    super.key,
    required this.tags,
    required this.selectedIds,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<TagSelectorSheet> {
  late List<int> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const SizedBox(width: 40), // Balance
              const Text('选择标签', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {
                  widget.onChanged(_currentSelectedIds);
                  Navigator.pop(context);
                },
                child: Text('确定',
                    style: TextStyle(color: widget.activeColor, fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TreeSelectorWidget<TagSelectItem>(
            items: widget.tags,
            isMultiSelect: true,
            selectedIds: _currentSelectedIds,
            onChanged: (ids) => setState(() => _currentSelectedIds = ids),
            activeColor: widget.activeColor,
            getId: (item) => item.id,
            getTitle: (item) => item.title,
            getChildren: (item) => item.children,
          ),
        ),
      ],
    );
  }
}

class CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateTimeChanged;

  const CustomDateTimePicker({super.key, required this.initialDate, required this.onDateTimeChanged});

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late FixedExtentScrollController _yearController, _monthController, _dayController, _hourController, _minuteController;
  late int selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute;
  final int startYear = 2000;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedHour = widget.initialDate.hour;
    selectedMinute = widget.initialDate.minute;
    _yearController = FixedExtentScrollController(initialItem: selectedYear - startYear);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('取消', style: TextStyle(color: Colors.black54, fontSize: 16))),
              const Text('选择时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              GestureDetector(
                  onTap: () => widget.onDateTimeChanged(
                      DateTime(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute)),
                  child: const Text('确定',
                      style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600, fontSize: 16))),
            ],
          ),
        ),
        Expanded(
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            child: Row(
              children:[
                _buildPicker(_yearController, 50, (i) => setState(() => selectedYear = startYear + i),
                        (i) => '${startYear + i}年'),
                _buildPicker(_monthController, 12, (i) => setState(() => selectedMonth = i + 1), (i) => '${i + 1}月'),
                _buildPicker(_dayController, 31, (i) => setState(() => selectedDay = i + 1), (i) => '${i + 1}日'),
                _buildPicker(_hourController, 24, (i) => setState(() => selectedHour = i), (i) => '${i}时'),
                _buildPicker(_minuteController, 60, (i) => setState(() => selectedMinute = i), (i) => '${i}分'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPicker(
      FixedExtentScrollController controller, int count, ValueChanged<int> onChanged, String Function(int) label) {
    return Expanded(
      child: CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        itemBuilder: (context, index) => Center(child: Text(label(index))),
        childCount: count,
      ),
    );
  }
}