import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/features/books/domain/books_manage_guards.dart';
import 'package:fortuneboot/features/books/presentation/widgets/default_account_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({
    super.key,
    required this.book,
    required this.group,
    required this.service,
    required this.capabilities,
    required this.inRecycleBin,
    this.onChanged,
  });

  final FortuneBookVo book;
  final ManagedGroup? group;
  final BooksService service;
  final ManageCapabilities capabilities;
  final bool inRecycleBin;
  final VoidCallback? onChanged;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _loading = true;
  String? _error;
  FortuneBookVo? _book;
  List<AccountOptionVo> _accounts = const [];

  FortuneBookVo get book => _book ?? widget.book;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookId = widget.book.bookId;
    final groupId = widget.group?.groupId ?? widget.book.groupId;
    if (bookId == null || groupId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        widget.service.getBookById(bookId),
        widget.service.getEnabledAccounts(groupId),
      ]);
      if (!mounted) return;
      setState(() {
        _book = results[0] as FortuneBookVo?;
        _accounts = results[1] as List<AccountOptionVo>;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is FxApiException ? e.message : e.toString();
      });
    }
  }

  Future<void> _setAccount(DefaultAccountKind kind) async {
    if (!widget.capabilities.canEdit) return;
    final selected = await FxSheet.show<int?>(
      context,
      title: kind.label,
      child: DefaultAccountSheet(
        kind: kind,
        accounts: _accounts,
        selectedAccountId: _selectedAccountId(kind),
      ),
      expand: true,
    );
    if (!mounted) return;
    final body = <String, dynamic>{
      'bookId': book.bookId,
      'groupId': book.groupId ?? widget.group?.groupId,
      'bookName': book.bookName,
      'defaultCurrency': book.defaultCurrency,
      'enable': book.enable,
      'sort': book.sort,
      'remark': book.remark,
      'defaultExpenseAccountId': book.defaultExpenseAccountId,
      'defaultIncomeAccountId': book.defaultIncomeAccountId,
      'defaultTransferOutAccountId': book.defaultTransferOutAccountId,
      'defaultTransferInAccountId': book.defaultTransferInAccountId,
      kind.fieldId: selected,
    };
    try {
      await widget.service.modifyBook(body);
      if (!mounted) return;
      widget.onChanged?.call();
      await _load();
    } on Object catch (e) {
      _toast(e is FxApiException ? e.message : e.toString());
    }
  }

  int? _selectedAccountId(DefaultAccountKind kind) {
    return switch (kind) {
      DefaultAccountKind.expense => book.defaultExpenseAccountId,
      DefaultAccountKind.income => book.defaultIncomeAccountId,
      DefaultAccountKind.transferOut => book.defaultTransferOutAccountId,
      DefaultAccountKind.transferIn => book.defaultTransferInAccountId,
    };
  }

  String? _selectedAccountName(DefaultAccountKind kind) {
    return switch (kind) {
      DefaultAccountKind.expense => book.defaultExpenseAccountName,
      DefaultAccountKind.income => book.defaultIncomeAccountName,
      DefaultAccountKind.transferOut => book.defaultTransferOutAccountName,
      DefaultAccountKind.transferIn => book.defaultTransferInAccountName,
    };
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: FxStateView.loading());
    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: FxStateView.error(message: _error, onRetry: _load),
        ),
      );
    }
    final palette = FxPalette.of(context);
    final defaultDecision = BookGuard.canSetDefault(
      book: book,
      defaultBookId: widget.group?.defaultBookId,
      inRecycleBin: widget.inRecycleBin,
      capabilities: widget.capabilities,
    );
    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        backgroundColor: palette.canvas,
        title: const Text('账本详情'),
        actions: [
          if (widget.capabilities.canEdit && !widget.inRecycleBin)
            IconButton(
              onPressed: widget.onChanged,
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.md,
          FxSpacing.lg,
          120,
        ),
        children: [
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.bookName ?? '未命名账本', style: FxTypography.display),
                const SizedBox(height: FxSpacing.sm),
                Wrap(
                  spacing: FxSpacing.xs,
                  children: [
                    FxTagChip(label: book.defaultCurrency ?? 'CNY'),
                    if (book.bookId == widget.group?.defaultBookId)
                      const FxTagChip(label: '默认账本', selected: true),
                    if (!book.enable)
                      FxTagChip(label: '已停用', dotColor: palette.warning),
                    if (widget.inRecycleBin)
                      FxTagChip(label: '回收站', dotColor: palette.danger),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          FxCard(
            child: Column(
              children: DefaultAccountKind.values
                  .map(
                    (kind) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(kind.label),
                      subtitle: Text(_selectedAccountName(kind) ?? '未设置'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: widget.inRecycleBin
                          ? null
                          : () => _setAccount(kind),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('信息', style: FxTypography.title),
                const SizedBox(height: FxSpacing.sm),
                Text('显示顺序：${book.sort ?? 0}', style: FxTypography.body),
                const SizedBox(height: FxSpacing.xs),
                Text(
                  '备注：${book.remark?.trim().isNotEmpty == true ? book.remark : '无'}',
                ),
              ],
            ),
          ),
          if (!widget.inRecycleBin) ...[
            const SizedBox(height: FxSpacing.md),
            if (!defaultDecision.allowed && defaultDecision.reason != null) ...[
              Text(
                defaultDecision.reason!,
                style: FxTypography.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: FxSpacing.sm),
            ],
            FxButton.tonal(
              label: '设为默认账本',
              expand: true,
              onPressed: defaultDecision.allowed
                  ? () async {
                      if (book.bookId == null) return;
                      await widget.service.setDefaultBook(book.bookId!);
                      if (!mounted) return;
                      widget.onChanged?.call();
                      _toast('默认账本已更新');
                    }
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
