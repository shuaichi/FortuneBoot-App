import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hjproject/Home/account_manage/models/fortune_account.dart';
import 'package:hjproject/Request/account_request.dart';
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart'
    as ds;

/// 增强版修改账户页面
/// 基于原有Sheet功能，改为Page形式展现，使用统一设计系统，提升UI/UX体验
class EnhancedAccountEditPage extends StatefulWidget {
  const EnhancedAccountEditPage({
    super.key,
    required this.account,
    required this.groupName,
  });

  final FortuneAccount account;
  final String groupName;

  @override
  State<EnhancedAccountEditPage> createState() =>
      _EnhancedAccountEditPageState();
}

class _EnhancedAccountEditPageState extends State<EnhancedAccountEditPage>
    with TickerProviderStateMixin {
  final AccountQueryService _service = AccountQueryService();

  // 动画控制器
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late TextEditingController _nameCtl;
  late TextEditingController _cardNoCtl;
  late TextEditingController _sortCtl;
  late TextEditingController _balanceCtl;
  late TextEditingController _remarkCtl;

  // 类型特有
  late TextEditingController _creditLimitCtl;
  late TextEditingController _aprCtl;
  DateTime? _billDay;
  DateTime? _repayDay;

  // 共同布尔参数
  late bool _include;
  late bool _canExpense;
  late bool _canIncome;
  late bool _enable;
  late bool _canTransferOut;
  late bool _canTransferIn;

  // 不可修改字段
  late int _accountType;
  late String _currencyCode;

  bool _busy = false;
  String? _errorText;

  // 表单验证错误
  String? _nameError;

  // 自定义图标名（为空表示按账户类型使用默认图标）
  String? _icon;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _loadAccountData();
  }

  void _initControllers() {
    _nameCtl = TextEditingController();
    _cardNoCtl = TextEditingController();
    _sortCtl = TextEditingController();
    _balanceCtl = TextEditingController();
    _remarkCtl = TextEditingController();
    _creditLimitCtl = TextEditingController();
    _aprCtl = TextEditingController();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: ds.AnimationDurations.fast,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ds.AnimationCurves.easeOut,
    ));

    // 启动动画
    _fadeController.forward();
  }

  void _loadAccountData() {
    final account = widget.account;

    _nameCtl.text = account.accountName ?? '';
    _cardNoCtl.text = account.cardNo ?? '';
    _sortCtl.text = account.sort?.toString() ?? '';
    _balanceCtl.text = account.balance?.toString() ?? '';
    _remarkCtl.text = account.remark ?? '';

    _include = account.include == 1;
    _canExpense = account.canExpense == 1;
    _canIncome = account.canIncome == 1;
    _enable = account.enable == 1;
    _canTransferOut = account.canTransferOut == 1;
    _canTransferIn = account.canTransferIn == 1;

    _accountType = account.accountType ?? 1;
    _currencyCode = account.currencyCode ?? 'CNY';
    _icon = account.icon;

    // 信用卡特有字段
    if (_accountType == 2) {
      _creditLimitCtl.text = account.creditLimit?.toString() ?? '';
      _billDay = account.billDay;
      _repayDay = account.repayDay;
    }

    if (_accountType == 4) {
      _aprCtl.text = account.apr?.toString() ?? '';
      _creditLimitCtl.text = account.creditLimit?.toString() ?? '';
      _repayDay = account.repayDay;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameCtl.dispose();
    _cardNoCtl.dispose();
    _sortCtl.dispose();
    _balanceCtl.dispose();
    _remarkCtl.dispose();
    _creditLimitCtl.dispose();
    _aprCtl.dispose();
    super.dispose();
  }

  // 增强版输入框装饰
  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    required IconData icon,
    bool hasError = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: ds.TextStyles.inputLabel,
      hintStyle: ds.TextStyles.inputHint,
      prefixIcon: Icon(
        icon,
        color: hasError
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError ? theme.colorScheme.error : theme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError ? theme.colorScheme.error : theme.colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.md,
        vertical: ds.Spacing.md,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      // 使用设计系统统一卡片间距，保证与页面其他卡片左右对齐
      margin: ds.Paddings.cardMargin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ds.Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title, subtitle),
            SizedBox(height: ds.Spacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ds.TextStyles.sectionTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: ds.Spacing.xs),
          Text(
            subtitle,
            style: ds.TextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadonlyRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(ds.Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ds.Spacing.sm),
          Text(
            label,
            style: ds.TextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: ds.Spacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: ds.TextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeName(int accountType) {
    switch (accountType) {
      case 1:
        return '活期账户';
      case 2:
        return '信用卡';
      case 3:
        return '资产账户';
      case 4:
        return '贷款账户';
      default:
        return '未知类型';
    }
  }

  IconData _getAccountTypeIcon(int accountType) {
    switch (accountType) {
      case 1:
        return Icons.account_balance_wallet;
      case 2:
        return Icons.credit_card;
      case 3:
        return Icons.savings;
      case 4:
        return Icons.account_balance;
      default:
        return Icons.account_balance_wallet;
    }
  }

  // 使用范围与状态选项芯片（统一样式，避免双勾与文本遮挡）
  Widget _buildStatusChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: ds.Spacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: ds.TextStyles.caption.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      labelPadding: EdgeInsets.symmetric(horizontal: ds.Spacing.sm),
      selected: selected,
      onSelected: onChanged,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      showCheckmark: false,
      // 关闭内置勾选，保留自定义前缀图标，避免“双勾”
      shape: RoundedRectangleBorder(
        borderRadius: ds.BorderRadii.chip,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusChips() {
    return Container(
      width: double.infinity, // 强制占满父容器宽度，确保卡片宽度一致
      child: Wrap(
        spacing: ds.Spacing.sm,
        runSpacing: ds.Spacing.sm,
        children: [
          _buildStatusChip(
            label: '计入资产',
            selected: _include,
            onChanged: (v) => setState(() => _include = v),
            icon: Icons.account_balance_wallet,
          ),
          _buildStatusChip(
            label: '支出允许',
            selected: _canExpense,
            onChanged: (v) => setState(() => _canExpense = v),
            icon: Icons.remove_circle_outline,
          ),
          _buildStatusChip(
            label: '收入允许',
            selected: _canIncome,
            onChanged: (v) => setState(() => _canIncome = v),
            icon: Icons.add_circle_outline,
          ),
          _buildStatusChip(
            label: '启用账户',
            selected: _enable,
            onChanged: (v) => setState(() => _enable = v),
            icon: Icons.toggle_on,
          ),
          _buildStatusChip(
            label: '转出允许',
            selected: _canTransferOut,
            onChanged: (v) => setState(() => _canTransferOut = v),
            icon: Icons.call_made,
          ),
          _buildStatusChip(
            label: '转入允许',
            selected: _canTransferIn,
            onChanged: (v) => setState(() => _canTransferIn = v),
            icon: Icons.call_received,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ds.TextStyles.inputLabel.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ds.Spacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
          child: Container(
            padding: EdgeInsets.all(ds.Spacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
              border: Border.all(
                color: theme.colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: ds.Spacing.sm),
                Expanded(
                  child: Text(
                    date != null ? '${date.day}日' : '选择日期',
                    style: ds.TextStyles.bodyMedium.copyWith(
                      color: date != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectBillDay(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _billDay ?? DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 1, 31),
    );
    if (selected != null) {
      setState(() {
        _billDay = selected;
      });
    }
  }

  Future<void> _selectRepayDay(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _repayDay ?? DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2024, 1, 31),
    );
    if (selected != null) {
      setState(() {
        _repayDay = selected;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_nameCtl.text.trim().isEmpty) {
      setState(() {
        _nameError = '请输入账户名称';
      });
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
      _nameError = null;
    });

    try {
      final updatedAccount = FortuneAccount(
        accountId: widget.account.accountId,
        accountName: _nameCtl.text.trim(),
        cardNo: _cardNoCtl.text.trim().isEmpty ? null : _cardNoCtl.text.trim(),
        sort: _sortCtl.text.trim().isEmpty
            ? null
            : int.tryParse(_sortCtl.text.trim()),
        balance: _balanceCtl.text.trim().isEmpty
            ? null
            : double.tryParse(_balanceCtl.text.trim()),
        remark: _remarkCtl.text.trim().isEmpty ? null : _remarkCtl.text.trim(),
        include: _include,
        canExpense: _canExpense,
        canIncome: _canIncome,
        enable: _enable,
        canTransferOut: _canTransferOut,
        canTransferIn: _canTransferIn,
        accountType: _accountType,
        currencyCode: _currencyCode,
        groupId: widget.account.groupId,
        creditLimit: (_accountType == 2 || _accountType == 4) &&
                _creditLimitCtl.text.trim().isNotEmpty
            ? double.tryParse(_creditLimitCtl.text.trim())
            : null,
        apr: _accountType == 4 && _aprCtl.text.trim().isNotEmpty
            ? double.tryParse(_aprCtl.text.trim())
            : null,
        billDay: _accountType == 2 ? _billDay : null,
        repayDay: (_accountType == 2 || _accountType == 4) ? _repayDay : null,
        icon: _icon,
      );

      final success = await _service.modifyAccount(updatedAccount);

      if (success && mounted) {
        // 成功动画
        await _fadeController.reverse();
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorText = '修改失败，请重试';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '修改失败：${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          '修改账户',
          style: ds.TextStyles.pageTitle,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_busy)
            Container(
              margin: EdgeInsets.only(right: ds.Spacing.md),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: ds.Spacing.sm),

              // 账户类型信息卡片
              _buildSectionCard(
                title: '账户信息',
                subtitle: '分组、类型和币种（只读）',
                child: Column(
                  children: [
                    _buildReadonlyRow('分组', widget.groupName, Icons.group),
                    SizedBox(height: ds.Spacing.sm),
                    _buildReadonlyRow(
                      '账户类型',
                      _getAccountTypeName(_accountType),
                      _getAccountTypeIcon(_accountType),
                    ),
                    SizedBox(height: ds.Spacing.sm),
                    _buildReadonlyRow(
                        '币种', _currencyCode, Icons.currency_exchange),
                  ],
                ),
              ),

              // 基本信息卡片
              _buildSectionCard(
                title: '基本信息',
                subtitle: '账户名称必填，其他信息可选',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtl,
                      decoration: _buildInputDecoration(
                        label: '账户名称',
                        hint: '请输入账户名称',
                        icon: Icons.badge,
                        hasError: _nameError != null,
                      ),
                      maxLength: 64,
                      onChanged: (_) => setState(() => _nameError = null),
                    ),
                    if (_nameError != null) ...[
                      SizedBox(height: ds.Spacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _nameError!,
                          style: ds.TextStyles.caption.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: ds.Spacing.md),

                    IconFormField(
                      title: '账户图标',
                      subtitle: '未设置时按账户类型显示默认图标',
                      value: _icon,
                      defaultIconName:
                          AppIcon.accountTypeFallback(_accountType),
                      onChanged: (v) => setState(() => _icon = v),
                    ),
                    SizedBox(height: ds.Spacing.md),

                    TextFormField(
                      controller: _cardNoCtl,
                      decoration: _buildInputDecoration(
                        label: '卡号/账号',
                        hint: '请输入卡号或账号',
                        icon: Icons.credit_card,
                      ),
                      maxLength: 32,
                    ),
                    SizedBox(height: ds.Spacing.md),
                    TextFormField(
                      controller: _balanceCtl,
                      decoration: _buildInputDecoration(
                        label: '当前余额',
                        hint: '请输入当前余额',
                        icon: Icons.account_balance,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
                      ],
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(height: ds.Spacing.md),

                    // 错误提示
                    if (_errorText != null)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: ds.Spacing.md,
                          vertical: ds.Spacing.sm,
                        ),
                        padding: EdgeInsets.all(ds.Spacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius:
                              BorderRadius.circular(ds.BorderRadiusValues.sm),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                            ),
                            SizedBox(width: ds.Spacing.sm),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: ds.TextStyles.bodyMedium.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: ds.Spacing.xl),
                  ],
                ),
              ),

              // 信用卡特有信息
              if (_accountType == 2)
                _buildSectionCard(
                  title: '信用账户信息',
                  subtitle: '信用额度、账单日、还款日',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _creditLimitCtl,
                        decoration: _buildInputDecoration(
                          label: '信用额度',
                          hint: '请输入信用额度',
                          icon: Icons.credit_score,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
                        ],
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: ds.Spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: '账单日',
                              date: _billDay,
                              onTap: () => _selectBillDay(context),
                            ),
                          ),
                          SizedBox(width: ds.Spacing.md),
                          Expanded(
                            child: _buildDateField(
                              label: '还款日',
                              date: _repayDay,
                              onTap: () => _selectRepayDay(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // 贷款账户特有信息
              if (_accountType == 4)
                _buildSectionCard(
                  title: '贷款账户信息',
                  subtitle: '信用额度、利率和还款日',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _creditLimitCtl,
                        decoration: _buildInputDecoration(
                          label: '信用额度',
                          hint: '请输入信用额度',
                          icon: Icons.credit_score,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
                        ],
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: ds.Spacing.md),
                      TextFormField(
                        controller: _aprCtl,
                        decoration: _buildInputDecoration(
                          label: '年化利率 (%)',
                          hint: '请输入年化利率',
                          icon: Icons.percent,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        textAlign: TextAlign.end,
                      ),
                      SizedBox(height: ds.Spacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: '还款日',
                              date: _repayDay,
                              onTap: () => _selectRepayDay(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // 使用范围与状态卡片
              _buildSectionCard(
                title: '使用范围与状态',
                subtitle: '设置账户的使用权限和状态',
                child: _buildStatusChips(),
              ),
              // 余额信息卡片
              _buildSectionCard(
                title: '顺序与备注',
                subtitle: '顺序为数值（可空），备注可多行。',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sortCtl,
                      decoration: _buildInputDecoration(
                        label: '排序',
                        hint: '请输入排序数字',
                        icon: Icons.sort,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.end,
                      maxLength: 9,
                    ),
                    SizedBox(height: ds.Spacing.md),
                    TextFormField(
                      controller: _remarkCtl,
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                        label: '备注',
                        hint: '请输入备注信息',
                        icon: Icons.notes,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 底部操作按钮
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ds.Spacing.lg).copyWith(
          bottom: ds.Spacing.lg + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ds.Spacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ds.BorderRadiusValues.md),
                  ),
                ),
                child: Text(
                  '取消',
                  style: ds.TextStyles.buttonText,
                ),
              ),
            ),
            SizedBox(width: ds.Spacing.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _busy ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ds.Spacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ds.BorderRadiusValues.md),
                  ),
                ),
                child: _busy
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        '保存修改',
                        style: ds.TextStyles.buttonText.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
