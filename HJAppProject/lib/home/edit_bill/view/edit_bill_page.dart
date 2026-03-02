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

// ==========================================
// 🎨 Design System Constants
// ==========================================
class AppColors {
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color divider = Color(0xFFE5E5EA);

  static const Color expense = Color(0xFF34C759);
  static const Color income = Color(0xFFFF3B30);
  static const Color transfer = Color(0xFF007AFF);
}

// ==========================================
// 🚀 Page Entry
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

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: isError ? AppColors.income : const Color(0xFF323232),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}

// ==========================================
// 📦 Main View
// ==========================================
class EditBillView extends StatefulWidget {
  const EditBillView({super.key});

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  final ValueNotifier<int> _activeAmountIndex = ValueNotifier(0);
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(true);
  final ValueNotifier<bool> _isSecondaryExpanded = ValueNotifier(false);

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _remarkFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  late List<CategoryAmountItem> _categoryAmountItems;
  String? _tempAmountString;

  Color _getThemeColor(BillType type) {
    switch (type) {
      case BillType.expenditure: return AppColors.expense;
      case BillType.income: return AppColors.income;
      case BillType.transfer: return AppColors.transfer;
      default: return AppColors.expense;
    }
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<EditBillBloc>().state;
    _initCategoryAmountItems(state);

    if (state.editBill.data?.remark != null) _remarkController.text = state.editBill.data!.remark!;
    if (state.editBill.data?.title != null) _titleController.text = state.editBill.data!.title!;

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildCustomAppBar(state, billType, themeColor),
      body: Column(
        children:[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismissAllKeyboards,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children:[
                  // 1. 金额录入核心区
                  _buildSectionContainer(
                    child: isTransfer
                        ? _buildTransferAmountSection(state, themeColor)
                        : _buildCategoryAmountList(state, themeColor),
                  ),
                  const SizedBox(height: 20),

                  // 2. 基础表单区
                  _buildSectionContainer(
                    child: _buildMainInfoSection(state, isTransfer, themeColor),
                  ),
                  const SizedBox(height: 20),

                  // 3. 高级选项折叠区
                  _buildSectionContainer(
                    child: _buildSecondaryInfoSection(state, isTransfer, themeColor),
                  ),
                  const SizedBox(height: 100), // 为键盘留出安全呼吸空间
                ],
              ),
            ),
          ),
          // 4. 定制数字键盘
          ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisible,
            builder: (context, visible, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: visible ? 280 + MediaQuery.of(context).padding.bottom : 0,
                child: visible ? _buildNumericKeyboard(themeColor) : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(EditBillState state, BillType billType, Color themeColor) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _buildSegmentedControl(billType, state.status == EditBillStatus.loading),
      centerTitle: true,
      actions:[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: state.status.isLoadingOrInit ? null : () {
              _dismissAllKeyboards();
              _submit(state);
            },
            style: TextButton.styleFrom(
              foregroundColor: themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: state.status.isLoadingOrInit
                ? const CupertinoActivityIndicator()
                : const Text('完成', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        )
      ],
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  // --- Type Switcher (iOS Segmented Style) ---
  Widget _buildSegmentedControl(BillType currentType, bool isLoading) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E8), // iOS segmented background
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:[
          _segmentButton(BillType.expenditure, '支出', currentType, isLoading),
          _segmentButton(BillType.income, '收入', currentType, isLoading),
          _segmentButton(BillType.transfer, '转账', currentType, isLoading),
        ],
      ),
    );
  }

  Widget _segmentButton(BillType type, String label, BillType currentType, bool isLoading) {
    final isSelected = type == currentType;
    return GestureDetector(
      onTap: isLoading ? null : () {
        FocusScope.of(context).unfocus();
        if (!isSelected) {
          context.read<EditBillBloc>().add(EditBillTypeChange(type));
          setState(() {
            _activeAmountIndex.value = type == BillType.transfer ? -1 : 0;
            _categoryAmountItems =[CategoryAmountItem(amount: 0.0)];
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ?[
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 1))
          ] :[],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- Transfer Amount ---
  Widget _buildTransferAmountSection(EditBillState state, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children:[
          Text('转账金额', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
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
                String displayText = _formatAmountString(isActive, amount);

                return AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: isActive ? themeColor : AppColors.textPrimary,
                    fontFamily: 'RobotoMono',
                    letterSpacing: -1,
                  ),
                  child: Text(displayText),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Category Amount List ---
  Widget _buildCategoryAmountList(EditBillState state, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categoryAmountItems.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider, indent: 16),
          itemBuilder: (context, index) => _buildCategoryAmountItem(state, index, themeColor),
        ),
        if (_categoryAmountItems.length < 5)
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
              child: Text('+ 添加明细', style: TextStyle(color: themeColor, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryAmountItem(EditBillState state, int index, Color themeColor) {
    final item = _categoryAmountItems[index];
    final categoryName = _getCategoryName(state.categoryList, item.categoryId);

    return Dismissible(
      key: item.key,
      direction: _categoryAmountItems.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
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
        color: AppColors.income,
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _activeAmountIndex,
        builder: (_, activeIndex, __) {
          final isActive = activeIndex == index;
          return Container(
            color: isActive ? themeColor.withOpacity(0.04) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children:[
                // Category Pill
                InkWell(
                  onTap: () => _showCategorySelector(context, state, index, themeColor),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Icon(Icons.grid_view_rounded, size: 18, color: categoryName.isEmpty ? AppColors.textSecondary : themeColor),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            categoryName.isEmpty ? '选择分类' : categoryName.split(' > ').last,
                            style: TextStyle(
                              color: categoryName.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Amount Area
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _activeAmountIndex.value = index;
                    _isKeyboardVisible.value = true;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(
                      _formatAmountString(isActive, item.amount),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isActive ? themeColor : AppColors.textPrimary,
                        fontFamily: 'RobotoMono',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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

  // --- Main Form Area ---
  Widget _buildMainInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return Column(
      children:[
        _buildTextFieldRow(
          icon: Icons.title_rounded,
          controller: _titleController,
          focusNode: _titleFocusNode,
          hintText: '请输入标题（必填）',
          onChanged: (v) => state.editBill.data?.title = v,
        ),
        const Divider(height: 1, color: AppColors.divider, indent: 48),
        _buildActionRow(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: AppColors.textSecondary,
          label: isTransfer ? '转出账户' : '账户',
          value: _getAccountName(state, state.editBill.data?.accountId),
          placeholder: '选择账户',
          onTap: () => _showAccountSelector(context, state, isSource: true),
        ),
        if (isTransfer) ...[
          const Divider(height: 1, color: AppColors.divider, indent: 48),
          _buildActionRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppColors.transfer,
            label: '转入账户',
            value: _getAccountName(state, state.editBill.data?.toAccountId),
            placeholder: '选择账户',
            onTap: () => _showAccountSelector(context, state, isSource: false),
          ),
        ],
        const Divider(height: 1, color: AppColors.divider, indent: 48),
        _buildActionRow(
          icon: Icons.access_time_filled_rounded,
          iconColor: AppColors.textSecondary,
          label: '时间',
          value: state.editBill.data?.tradeTime ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          placeholder: '选择时间',
          onTap: () => _showTimeSelector(context, state),
        ),
        if (!isTransfer) ...[
          const Divider(height: 1, color: AppColors.divider, indent: 48),
          _buildActionRow(
            icon: Icons.person_rounded,
            iconColor: AppColors.textSecondary,
            label: '交易对象',
            value: _getPayeeName(state, state.editBill.data?.payeeId),
            placeholder: '无',
            onTap: () => _showPayeeSelector(context, state),
          ),
        ],
      ],
    );
  }

  // --- Advanced Options Area ---
  Widget _buildSecondaryInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSecondaryExpanded,
      builder: (_, isExpanded, __) {
        return Column(
          children:[
            InkWell(
              onTap: () {
                _dismissAllKeyboards();
                _isSecondaryExpanded.value = !isExpanded;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children:[
                    Text('更多信息', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 15)),
                    const Spacer(),
                    if (!isExpanded) ...[
                      if (state.editBill.data?.tagIdList?.isNotEmpty == true)
                        Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.local_offer_rounded, size: 16, color: themeColor)),
                      if (state.editBill.data?.remark?.isNotEmpty == true)
                        Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.notes_rounded, size: 16, color: themeColor)),
                      if (state.attachments.isNotEmpty)
                        Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.attach_file_rounded, size: 16, color: themeColor)),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                children:[
                  const Divider(height: 1, color: AppColors.divider),
                  _buildActionRow(
                    icon: Icons.local_offer_rounded,
                    iconColor: AppColors.textSecondary,
                    label: '标签',
                    value: _getTagsDisplay(state),
                    placeholder: '无',
                    onTap: () => _showTagSelector(context, state, themeColor),
                    isMultiline: true,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 48),
                  _buildTextFieldRow(
                    icon: Icons.notes_rounded,
                    controller: _remarkController,
                    focusNode: _remarkFocusNode,
                    hintText: '写点备注...',
                    onChanged: (v) => state.editBill.data?.remark = v,
                  ),
                  const Divider(height: 1, color: AppColors.divider, indent: 48),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AttachmentUploadWidget(
                      initialAttachments: state.attachments,
                      onAttachmentsChanged: (list) => context.read<EditBillBloc>().add(EditBillAttachmentsChanged(list)),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children:[
                        Expanded(
                          child: _buildSwitchTile('确认', state.editBill.data?.confirm ?? true, isTransfer ? null : (v) {
                            setState(() => state.editBill.data?.confirm = v);
                          }, themeColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSwitchTile('统计', state.editBill.data?.include ?? true, isTransfer ? null : (v) {
                            setState(() => state.editBill.data?.include = v);
                          }, themeColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        );
      },
    );
  }

  // --- Form Helpers ---
  Widget _buildTextFieldRow({
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children:[
          Icon(icon, size: 22, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Icon(Icons.cancel, size: 18, color: AppColors.divider),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String placeholder,
    required VoidCallback onTap,
    bool isMultiline = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: isMultiline && value.isNotEmpty ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children:[
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value.isEmpty ? placeholder : value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  color: value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool)? onChanged, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Transform.scale(
          scale: 0.85,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ),
      ],
    );
  }

  String _getTagsDisplay(EditBillState state) {
    final ids = state.editBill.data?.tagIdList ??[];
    if (ids.isEmpty) return '';
    return ids.map((id) => TagSelectItem.getFullPathById(state.tagList, id)).join(', ');
  }

  // --- Keyboard (iOS Style) ---
  Widget _buildNumericKeyboard(Color themeColor) {
    return Container(
      color: const Color(0xFFD1D5DB), // Keyboard border/divider color
      child: SafeArea(
        top: false,
        child: Column(
          children:[
            Container(
              height: 40,
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  IconButton(
                    icon: const Icon(Icons.keyboard_hide_rounded, color: AppColors.textSecondary),
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
                        _buildKey('-', AppColors.surface, AppColors.textPrimary, flex: 1),
                        _buildKey('完成', themeColor, Colors.white, flex: 3, isBold: true, onTap: _dismissAllKeyboards),
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
        children: keys.map((key) => _buildKey(key, AppColors.surface, AppColors.textPrimary)).toList(),
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
          margin: const EdgeInsets.only(top: 1, right: 1), // Creates crisp 1px borders
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

  // --- Strict Logic Keeping from Original ---
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

  // --- Bottom Sheets ---
  void _showBottomSheet({required BuildContext context, required Widget child}) {
    _dismissAllKeyboards();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: child),
    );
  }

  void _showCategorySelector(BuildContext context, EditBillState state, int index, Color themeColor) {
    _showBottomSheet(
      context: context,
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
    );
  }

  void _showTagSelector(BuildContext context, EditBillState state, Color themeColor) {
    _showBottomSheet(
      context: context,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: TagSelectorSheet(
          tags: state.tagList,
          activeColor: themeColor,
          selectedIds: state.editBill.data?.tagIdList ??[],
          onChanged: (ids) => setState(() => state.editBill.data?.tagIdList = ids),
        ),
      ),
    );
  }

  void _showAccountSelector(BuildContext context, EditBillState state, {required bool isSource}) {
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
    List<DropdownItem<AccountSelectItem>> list =[];

    if (billType == BillType.transfer) {
      list = isSource ? state.transferOutAccountList : state.transferAccountList;
    } else if (billType == BillType.income) {
      list = state.incomeAccountList;
    } else {
      list = state.expenseAccountList;
    }

    _showBottomSheet(
      context: context,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text('选择账户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(list[i].label, style: const TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    setState(() {
                      if (billType == BillType.transfer) {
                        if (isSource) {
                          state.editBill.data?.accountId = list[i].value.id;
                        } else {
                          state.editBill.data?.toAccountId = list[i].value.id;
                        }
                      } else {
                        state.editBill.data?.accountId = list[i].value.id;
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeSelector(BuildContext context, EditBillState state) {
    DateTime initialDate = DateTime.now();
    try {
      initialDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(state.editBill.data?.tradeTime ?? '');
    } catch(e) {}

    _showBottomSheet(
      context: context,
      child: SizedBox(
        height: 360,
        child: CustomDateTimePicker(
          initialDate: initialDate,
          onDateTimeChanged: (dt) {
            setState(() => state.editBill.data?.tradeTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showPayeeSelector(BuildContext context, EditBillState state) {
    _showBottomSheet(
      context: context,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const Text('选择交易对象', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.payeeList.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) => ListTile(
                  title: Text(state.payeeList[i].label, style: const TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    setState(() => state.editBill.data?.payeeId = state.payeeList[i].value.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(EditBillState state) {
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);

    if (billType == BillType.transfer) {
      if ((state.editBill.data?.amount ?? 0) <= 0) {
        _showToast(context, '请输入转账金额', isError: true); return;
      }
      if (state.editBill.data?.accountId == null || state.editBill.data?.toAccountId == null) {
        _showToast(context, '请完善转账账户', isError: true); return;
      }
    } else {
      if (_categoryAmountItems.isEmpty) {
        _showToast(context, '请输入金额', isError: true); return;
      }
      if (_categoryAmountItems.any((e) => e.categoryId == null)) {
        _showToast(context, '请选择分类', isError: true); return;
      }
      if (state.editBill.data?.title == null || state.editBill.data!.title!.isEmpty) {
        _showToast(context, '请输入标题', isError: true); return;
      }
    }

    context.read<EditBillBloc>().add(EditBillSubmitted());
  }

  void _showToast(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: isError ? AppColors.income : const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
  }
}

class CategoryAmountItem {
  int? categoryId;
  double amount;
  final UniqueKey key;
  CategoryAmountItem({this.categoryId, required this.amount}) : key = UniqueKey();
}

// ==========================================
// 🌲 Clean Tree Selector Components
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
      if (current.contains(id)) current.remove(id);
      else current.add(id);
    } else {
      current.clear();
      current.add(id);
    }
    _selectedKeys.value = current;
    widget.onChanged(current.toList());
  }

  void _handleExpand(int id) {
    final current = Set<int>.from(_expandedKeys.value);
    if (current.contains(id)) current.remove(id);
    else current.add(id);
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
    required this.item, required this.depth,
    required this.expandedKeys, required this.selectedKeys,
    required this.onToggle, required this.onExpand,
    required this.isMultiSelect, required this.activeColor,
    required this.getId, required this.getTitle, required this.getChildren,
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
                    padding: EdgeInsets.only(left: 20 + depth * 24.0, right: 20, top: 16, bottom: 16),
                    child: Row(
                      children:[
                        if (isMultiSelect)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? activeColor : AppColors.textSecondary.withOpacity(0.5),
                              size: 22,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            getTitle(item),
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected && !isMultiSelect ? activeColor : AppColors.textPrimary,
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
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                              child: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  size: 20, color: AppColors.textSecondary),
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
                    children: children!.map((child) => _TreeNode<T>(
                      item: child, depth: depth + 1, expandedKeys: expandedKeys, selectedKeys: selectedKeys,
                      onToggle: onToggle, onExpand: onExpand, isMultiSelect: isMultiSelect,
                      activeColor: activeColor, getId: getId, getTitle: getTitle, getChildren: getChildren,
                    )).toList(),
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

  const CategorySelectorSheet({super.key, required this.categories, this.selectedId, required this.onSelected, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.center,
          child: Column(
            children:[
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
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
            selectedIds: selectedId != null ?[selectedId!] :[],
            onChanged: (ids) { if (ids.isNotEmpty) onSelected(ids.first); },
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

  const TagSelectorSheet({super.key, required this.tags, required this.selectedIds, required this.onChanged, required this.activeColor});

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
                child: Text('确定', style: TextStyle(color: widget.activeColor, fontWeight: FontWeight.w600, fontSize: 16)),
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
    selectedYear = widget.initialDate.year; selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day; selectedHour = widget.initialDate.hour;
    selectedMinute = widget.initialDate.minute;
    _yearController = FixedExtentScrollController(initialItem: selectedYear - startYear);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    _yearController.dispose(); _monthController.dispose(); _dayController.dispose();
    _hourController.dispose(); _minuteController.dispose();
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
              GestureDetector(onTap: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
              const Text('选择时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              GestureDetector(
                  onTap: () => widget.onDateTimeChanged(DateTime(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute)),
                  child: const Text('确定', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600, fontSize: 16))
              ),
            ],
          ),
        ),
        Expanded(
          child: DefaultTextStyle(
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            child: Row(
              children:[
                _buildPicker(_yearController, 50, (i) => setState(() => selectedYear = startYear + i), (i) => '${startYear + i}年'),
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

  Widget _buildPicker(FixedExtentScrollController controller, int count, ValueChanged<int> onChanged, String Function(int) label) {
    return Expanded(
      child: CupertinoPicker.builder(
        scrollController: controller, itemExtent: 40, onSelectedItemChanged: onChanged,
        itemBuilder: (context, index) => Center(child: Text(label(index))), childCount: count,
      ),
    );
  }
}