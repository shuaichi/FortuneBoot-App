import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/Request/account_request.dart';
import 'package:hjproject/request/group_request.dart';
import 'package:hjproject/Home/setting_page/view/widgets/selection_bottom_sheet.dart';
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart' as ds;

/// 增强版新增账户页面
/// 基于原有Sheet功能，改为Page形式展现，使用统一设计系统，提升UI/UX体验
class EnhancedAccountAddPage extends StatefulWidget {
  const EnhancedAccountAddPage({
    super.key,
    required this.groupId,
    required this.accountType,
  });

  final int groupId;
  final int accountType;

  @override
  State<EnhancedAccountAddPage> createState() => _EnhancedAccountAddPageState();
}

class _EnhancedAccountAddPageState extends State<EnhancedAccountAddPage>
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
  late TextEditingController _creditLimitCtl;
  late TextEditingController _aprCtl;

  DateTime? _billDay;
  DateTime? _repayDay;

  // 六个状态（默认选中/启用）
  bool _include = true;
  bool _canExpense = true;
  bool _canIncome = true;
  bool _enable = true;
  bool _canTransferOut = true;
  bool _canTransferIn = true;

  // 币种模板
  List<CurrencyOption> _currencyOptions = const <CurrencyOption>[];
  String? _selectedCurrencyCode;
  bool _loadingCurrency = true;
  String? _currencyLoadError;

  // 分组名称
  String _groupName = '未知分组';

  bool _busy = false;
  String? _errorText;
  bool _isNavigating = false;

  // 表单验证错误
  String? _nameError;
  String? _currencyError;

  // 自定义图标名（为空表示按账户类型使用默认图标）
  String? _icon;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _loadData();
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

  void _loadData() {
    _loadGroupName();
    _loadCurrencies();
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

  Future<void> _loadGroupName() async {
    try {
      final resp = await GroupService().getByGroupId(widget.groupId);
      if (resp.code == 0) {
        final data = (resp.data as Map?) ?? {};
        final name = (data['groupName'] ?? '').toString();
        if (name.isNotEmpty && mounted) {
          setState(() {
            _groupName = name;
          });
        }
      }
    } catch (_) {
      // 保持默认"未知分组"
    }
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _loadingCurrency = true;
      _currencyLoadError = null;
    });
    try {
      final list = await _service.getCurrencyTemplate();
      if (mounted) {
        setState(() {
          _currencyOptions = list;
          _loadingCurrency = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currencyLoadError = e.toString();
          _loadingCurrency = false;
        });
      }
    }
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
          color: hasError
              ? theme.colorScheme.error
              : theme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
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
    // DEBUG: 添加调试日志验证卡片宽度
    return LayoutBuilder(
      builder: (context, constraints) {
        print('DEBUG: SectionCard "$title" available width: ${constraints
            .maxWidth}');
        return Container(
          // 使用设计系统统一卡片间距，保证与页面其他卡片左右对齐
          margin: ds.Paddings.cardMargin,
          width: double.infinity, // 强制占满可用宽度
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
      },
    );
  }

  Widget _buildSectionTitle(String title, String ? subtitle) {
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

  String _typeLabel(int t) {
    switch (t) {
      case 1:
        return '活期账户';
      case 2:
        return '信用账户';
      case 3:
        return '资产账户';
      case 4:
        return '贷款账户';
      default:
        return '账户';
    }
  }

  double? _tryDouble(String s) {
    if (s
        .trim()
        .isEmpty) return null;
    return double.tryParse(s.trim());
  }

  bool get _valid {
    _errorText = null;
    _nameError = null;
    _currencyError = null;

    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      _nameError = '账户名称不能为空';
      return false;
    }
    if (name.length > 64) {
      _nameError = '账户名称长度不能超过64';
      return false;
    }

    if (_selectedCurrencyCode == null ||
        _selectedCurrencyCode!.trim().isEmpty) {
      _currencyError = '请选择币种';
      return false;
    }

    final sortText = _sortCtl.text.trim();
    if (sortText.isNotEmpty) {
      final n = int.tryParse(sortText);
      if (n == null || n < 0) {
        _errorText = '顺序必须为非负整数';
        return false;
      }
    }

    final balText = _balanceCtl.text.trim();
    if (balText.isNotEmpty && _tryDouble(balText) == null) {
      _errorText = '余额必须为数值';
      return false;
    }

    return true;
  }

  Future<void> _openCurrencySelector() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Future.delayed(Duration.zero);

    final options = _currencyOptions
        .map((e) =>
        SelectionOption<String>(
          label: e.label,
          value: e.label,
          selected: e.label == _selectedCurrencyCode,
        ))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .colorScheme
                .surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ds.BorderRadiusValues.xl),
            ),
          ),
          child: SelectionBottomSheet<String>(
            title: '选择币种',
            options: options,
            onSelected: (opt) {
              setState(() {
                _selectedCurrencyCode = opt.value;
                _currencyError = null;
              });
            },
          ),
        );
      },
    );

    _isNavigating = false;
  }

  Future<void> _submit() async {
    if (!_valid) {
      setState(() {});
      return;
    }

    setState(() {
      _busy = true;
    });

    final String? cardNo =
    _cardNoCtl.text
        .trim()
        .isEmpty ? null : _cardNoCtl.text.trim();
    final int? sort =
    _sortCtl.text
        .trim()
        .isEmpty ? null : int.tryParse(_sortCtl.text.trim());
    final double? balance = _tryDouble(_balanceCtl.text.trim());
    final String? remark =
    _remarkCtl.text
        .trim()
        .isEmpty ? null : _remarkCtl.text.trim();

    try {
      final ok = await _service.addAccount(
        groupId: widget.groupId,
        accountName: _nameCtl.text.trim(),
        accountType: widget.accountType,
        currencyCode: _selectedCurrencyCode!.trim(),
        cardNo: cardNo,
        sort: sort,
        balance: balance,
        remark: remark,
        canExpense: _canExpense,
        canIncome: _canIncome,
        canTransferOut: _canTransferOut,
        canTransferIn: _canTransferIn,
        include: _include,
        enable: _enable,
        creditLimit: (widget.accountType == 2 || widget.accountType == 4) &&
            _creditLimitCtl.text
                .trim()
                .isNotEmpty
            ? double.tryParse(_creditLimitCtl.text.trim())
            : null,
        apr: widget.accountType == 4 && _aprCtl.text
            .trim()
            .isNotEmpty
            ? double.tryParse(_aprCtl.text.trim())
            : null,
        billDay: widget.accountType == 2 ? _billDay : null,
        repayDay: (widget.accountType == 2 || widget.accountType == 4)
            ? _repayDay
            : null,
        icon: _icon,
      );
      if (ok && mounted) {
        // 添加成功动画
        await _fadeController.reverse();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
            ),
          ),
        );
      }
    }
  }

  // 使用范围与状态选项芯片（统一样式，去除双勾并避免文字遮挡）
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

  /**
      Widget _buildStatusChips() {
      // DEBUG: 添加调试日志验证卡片宽度问题
      return LayoutBuilder(
      builder: (context, constraints) {
      return Container(
      width: double.infinity, // 强制占满父容器宽度
      child: Wrap(
      spacing: ds.Spacing.sm,
      runSpacing: ds.Spacing.sm,
      children: [
   */
  Widget _buildStatusChips() {
    return Container(
      width: double.infinity, // 强制占满父容器宽度
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          '新增账户',
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
                title: '账户类型信息',
                subtitle: '当前分组和账户类型（只读）',
                child: Column(
                  children: [
                    _buildReadonlyRow('分组', _groupName, Icons.group),
                    SizedBox(height: ds.Spacing.sm),
                    _buildReadonlyRow(
                      '账户类型',
                      _typeLabel(widget.accountType),
                      Icons.category,
                    ),
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
                        hint: '最长64字符',
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
                          AppIcon.accountTypeFallback(widget.accountType),
                      onChanged: (v) => setState(() => _icon = v),
                    ),
                    SizedBox(height: ds.Spacing.md),

                    // 币种选择
                    InkWell(
                      onTap: _openCurrencySelector,
                      borderRadius: BorderRadius.circular(
                          ds.BorderRadiusValues.md),
                      child: Container(
                        padding: EdgeInsets.all(ds.Spacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currencyError != null
                                ? theme.colorScheme.error
                                : theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(
                              ds.BorderRadiusValues.md),
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_exchange,
                              color: _currencyError != null
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: ds.Spacing.md),
                            Expanded(
                              child: Text(
                                _selectedCurrencyCode ?? '请选择币种',
                                style: ds.TextStyles.bodyMedium.copyWith(
                                  color: _selectedCurrencyCode == null
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_currencyError != null) ...[
                      SizedBox(height: ds.Spacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _currencyError!,
                          style: ds.TextStyles.caption.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: ds.Spacing.md),

                    TextFormField(
                      controller: _cardNoCtl,
                      decoration: _buildInputDecoration(
                        label: '卡号',
                        hint: '可选',
                        icon: Icons.credit_card,
                      ),
                      maxLength: 32,
                    ),
                    SizedBox(height: ds.Spacing.md),
                    TextFormField(
                      controller: _balanceCtl,
                      decoration: _buildInputDecoration(
                        label: '余额',
                        hint: '可留空',
                        icon: Icons.account_balance,
                        hasError: _errorText?.contains('余额') == true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
                      ],
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),

              // 信用卡特有信息
              if (widget.accountType == 2)
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
                          FilteringTextInputFormatter.allow(RegExp(
                              r'[0-9.\-]'))
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
              if (widget.accountType == 4)
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
                          FilteringTextInputFormatter.allow(RegExp(
                              r'[0-9.\-]'))
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

              // 顺序与备注卡片
              _buildSectionCard(
                title: '顺序与备注',
                subtitle: '顺序为数值（可空），备注可多行',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sortCtl,
                      decoration: _buildInputDecoration(
                        label: '顺序',
                        hint: '非负整数，可留空',
                        icon: Icons.sort,
                        hasError: _errorText?.contains('顺序') == true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.end,
                      maxLength: 9,
                    ),
                    SizedBox(height: ds.Spacing.md),
                    TextFormField(
                      controller: _remarkCtl,
                      maxLines: 4,
                      decoration: _buildInputDecoration(
                        label: '备注',
                        hint: '可留空',
                        icon: Icons.notes,
                      ),
                    ),
                  ],
                ),
              ),

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
                    borderRadius: BorderRadius.circular(
                        ds.BorderRadiusValues.sm),
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
      ),

      // 底部操作按钮
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ds.Spacing.lg).copyWith(
          bottom: ds.Spacing.lg + MediaQuery
              .of(context)
              .padding
              .bottom,
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
                  padding: const EdgeInsets.symmetric(
                    vertical: ds.Spacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ds.BorderRadiusValues.md),
                  ),
                ),
                child: const Text(
                  '取消',
                  style: ds.TextStyles.buttonText,
                ),
              ),
            ),
            const SizedBox(width: ds.Spacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: ds.Spacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        ds.BorderRadiusValues.md),
                  ),
                ),
                icon: _busy
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                    : const Icon(Icons.add),
                label: Text(
                  '新增',
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
                          : theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.6),
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

  Widget _buildCurrencySelector() {
    final theme = Theme.of(context);

    if (_loadingCurrency) {
      return Container(
        padding: EdgeInsets.all(ds.Spacing.md),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: ds.Spacing.md),
            Text(
              '正在加载币种模板...',
              style: ds.TextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_currencyLoadError != null) {
      return Container(
        padding: EdgeInsets.all(ds.Spacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(ds.BorderRadiusValues.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            SizedBox(width: ds.Spacing.sm),
            Expanded(
              child: Text(
                _currencyLoadError!,
                style: ds.TextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: _loadCurrencies,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _openCurrencySelector,
      borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
      child: Container(
        padding: EdgeInsets.all(ds.Spacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: _currencyError != null
                ? theme.colorScheme.error
                : theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(ds.BorderRadiusValues.md),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Row(
          children: [
            Icon(
              Icons.currency_exchange,
              color: _currencyError != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ds.Spacing.md),
            Expanded(
              child: Text(
                _selectedCurrencyCode ?? '请选择币种',
                style: ds.TextStyles.bodyMedium.copyWith(
                  color: _selectedCurrencyCode == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}