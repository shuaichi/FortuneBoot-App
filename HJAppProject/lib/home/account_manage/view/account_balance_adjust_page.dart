import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hjproject/Home/account_manage/models/fortune_account.dart';
import 'package:hjproject/Request/account_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/request/book_request.dart';
import 'package:hjproject/Home/setting_page/view/widgets/selection_bottom_sheet.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart' as ds;
import 'package:hjproject/Home/account_manage/view/widgets/number_keyboard.dart';

/// 增强版余额调整页面
/// 遵循设计规范：大号金额输入、自定义数字键盘、清晰的资金流向反馈
class AccountBalanceAdjustPage extends StatefulWidget {
  const AccountBalanceAdjustPage({
    super.key,
    required this.account,
  });

  final FortuneAccount account;

  @override
  State<AccountBalanceAdjustPage> createState() =>
      _AccountBalanceAdjustPageState();
}

class _AccountBalanceAdjustPageState
    extends State<AccountBalanceAdjustPage>
    with TickerProviderStateMixin {
  final AccountQueryService _service = AccountQueryService();

  // 动画控制器
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 状态数据
  String _amountStr = ''; // 目标余额字符串
  
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _remarkCtl = TextEditingController();
  
  // 焦点控制
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _remarkFocus = FocusNode();

  DateTime _tradeTime = DateTime.now();
  int? _bookId;
  String? _bookName;
  bool _isNavigating = false;
  bool _submitting = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initData();
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

    _fadeController.forward();
  }

  void _initData() {
    final repo = context.read<BillsRepository>();
    _bookId = repo.bookId() ?? 1;
    
    // 初始金额为当前余额
    if (widget.account.balance != null) {
      // 格式化为不带千分位的字符串，保留两位小数
      final fmt = NumberFormat('0.##');
      _amountStr = fmt.format(widget.account.balance);
    }
    
    _loadBookName();
  }

  Future<void> _loadBookName() async {
    try {
      final repo = context.read<BillsRepository>();
      final groupId = repo.groupId() ?? 1;
      final bookService = BookService();
      final response = await bookService.getEnableList(groupId);
      if (response.code == 0) {
        final list = (response.data as List? ?? []);
        String? foundName;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          final id = (m['bookId'] as num?)?.toInt();
          if (id == _bookId) {
            foundName = (m['bookName'] ?? '').toString();
            break;
          }
        }
        if (mounted) {
          setState(() {
            _bookName = foundName ?? '默认账本';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bookName = '未知账本';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleCtl.dispose();
    _remarkCtl.dispose();
    _titleFocus.dispose();
    _remarkFocus.dispose();
    super.dispose();
  }

  // 键盘事件处理
  void _onKeyboardTap(String value) {
    setState(() {
      if (value == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = _amountStr.isEmpty ? '0.' : '$_amountStr.';
        }
      } else {
        // 限制小数位数
        if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          if (parts.length > 1 && parts[1].length >= 2) return;
        }
        // 限制最大长度
        if (_amountStr.replaceAll('.', '').length >= 12) return;
        
        if (_amountStr == '0') {
          _amountStr = value;
        } else {
          _amountStr += value;
        }
      }
      _errorMessage = null;
    });
  }

  void _onKeyboardDelete() {
    setState(() {
      if (_amountStr.isNotEmpty) {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  // 计算差额
  double get _currentBalance => widget.account.balance ?? 0.0;
  double get _targetBalance => double.tryParse(_amountStr) ?? 0.0;
  double get _difference => _targetBalance - _currentBalance;

  Future<void> _handleSubmit() async {
    if (_submitting) return;

    if (_amountStr.isEmpty) {
      setState(() => _errorMessage = '请输入有效金额');
      return;
    }

    if (_bookId == null) {
      setState(() => _errorMessage = '请选择账本');
      return;
    }

    setState(() => _submitting = true);

    try {
      final success = await _service.balanceAdjust(
        accountId: widget.account.accountId!,
        balance: _targetBalance,
        tradeTime: _tradeTime,
        bookId: _bookId!,
        title: _titleCtl.text.trim().isEmpty ? null : _titleCtl.text.trim(),
        remark: _remarkCtl.text.trim().isEmpty ? null : _remarkCtl.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        setState(() {
          _errorMessage = '调整失败，请重试';
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _submitting = false;
        });
      }
    }
  }

  Future<void> _selectBook(BuildContext context) async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Future.delayed(Duration.zero);

    final groupId = context.read<BillsRepository>().groupId() ?? 1;
    final resp = await BookService().getEnableList(groupId);
    
    if (!mounted) {
      _isNavigating = false;
      return;
    }

    if (resp.code != 0) {
      _isNavigating = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(resp.msg ?? '获取账本失败'),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    final list = (resp.data as List? ?? []);
    final options = <SelectionOption<Map>>[];
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = (m['bookId'] as num?)?.toInt() ?? 0;
      final name = (m['bookName'] ?? '').toString();
      final enable = (m['enable'] is bool) ? (m['enable'] as bool) : true;
      if (!enable) continue;
      options.add(SelectionOption<Map>(
        label: name.isEmpty ? '账本$id' : name,
        value: {'id': id, 'name': name},
        selected: id == _bookId,
      ));
    }

    if (!mounted) {
      _isNavigating = false;
      return;
    }

    final selected = await showModalBottomSheet<SelectionOption<Map>>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(ds.BorderRadiusValues.lg)),
      ),
      builder: (ctx) => SelectionBottomSheet<Map>(
        title: '选择账本',
        options: options,
        onSelected: (opt) {
          if (!mounted) return;
          setState(() {
            _bookId = (opt.value['id'] as int?) ?? _bookId;
            _bookName = (opt.value['name'] as String?) ?? _bookName;
            _errorMessage = null;
          });
        },
      ),
    );
    
    _isNavigating = false;
    
    if (selected != null && mounted) {
      setState(() {
        _bookId = (selected.value['id'] as int?) ?? _bookId;
        _bookName = (selected.value['name'] as String?) ?? _bookName;
        _errorMessage = null;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tradeTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_tradeTime),
      );

      if (time != null && mounted) {
        setState(() {
          _tradeTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('余额调整', style: ds.TextStyles.pageTitle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: Text(
              '完成',
              style: ds.TextStyles.buttonText.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: ds.FontWeights.semiBold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 上部滚动区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. 金额显示区
                  _buildAmountSection(theme),
                  
                  // 2. 差额提示
                  _buildDifferenceIndicator(theme),
                  
                  // 3. 辅助信息表单
                  Padding(
                    padding: ds.Paddings.pageHorizontal(MediaQuery.of(context).size.width),
                    child: Column(
                      children: [
                        SizedBox(height: ds.Spacing.lg),
                        _buildInfoRow(
                          context,
                          icon: Icons.access_time,
                          label: DateFormat('yyyy-MM-dd HH:mm').format(_tradeTime),
                          onTap: () => _selectDateTime(context),
                        ),
                        SizedBox(height: ds.Spacing.md),
                        _buildInfoRow(
                          context,
                          icon: Icons.book_outlined,
                          label: _bookName ?? '选择账本',
                          onTap: () => _selectBook(context),
                        ),
                        SizedBox(height: ds.Spacing.md),
                        _buildInputRow(
                          context,
                          controller: _titleCtl,
                          focusNode: _titleFocus,
                          icon: Icons.title,
                          hint: '添加标题（可选）',
                        ),
                        SizedBox(height: ds.Spacing.md),
                        _buildInputRow(
                          context,
                          controller: _remarkCtl,
                          focusNode: _remarkFocus,
                          icon: Icons.note_outlined,
                          hint: '添加备注（可选）',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ds.Spacing.xl),
                ],
              ),
            ),
          ),
          
          // 底部键盘区（当输入框获取焦点时隐藏）
          if (!_titleFocus.hasFocus && !_remarkFocus.hasFocus)
            SafeArea(
              top: false,
              child: Container(
                color: theme.colorScheme.surface,
                child: NumberKeyboard(
                  onTap: _onKeyboardTap,
                  onDelete: _onKeyboardDelete,
                  onDone: _handleSubmit,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ds.Spacing.lg),
      child: Column(
        children: [
          Text(
            '调整后余额',
            style: ds.TextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AmountDisplay(
            amount: _amountStr,
            currencySymbol: widget.account.currencySymbol,
            isExpense: _targetBalance < 0,
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: ds.Spacing.sm),
              child: Text(
                _errorMessage!,
                style: ds.TextStyles.caption.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDifferenceIndicator(ThemeData theme) {
    final diff = _difference;
    if (diff == 0) return const SizedBox.shrink();

    final isPositive = diff > 0;
    final color = isPositive ? ds.FinanceColors.income : ds.FinanceColors.expense;
    final bgColor = isPositive ? ds.FinanceColors.incomeLight : ds.FinanceColors.expenseLight;
    final prefix = isPositive ? '+' : '';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.md,
        vertical: ds.Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ds.BorderRadiusValues.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: color,
          ),
          SizedBox(width: ds.Spacing.xs),
          Text(
            '$prefix${NumberFormat('#,##0.##').format(diff)}',
            style: ds.TextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: ds.FontWeights.semiBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: ds.BorderRadii.button,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ds.Spacing.md,
          vertical: ds.Spacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: ds.BorderRadii.button,
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(width: ds.Spacing.md),
            Expanded(
              child: Text(
                label,
                style: ds.TextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: ds.BorderRadii.button,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: ds.Spacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: ds.TextStyles.inputHint.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: ds.Spacing.md),
              ),
              style: ds.TextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}