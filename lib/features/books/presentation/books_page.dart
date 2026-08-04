import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/widgets/book_form_sheet.dart';
import 'package:fortuneboot/features/books/presentation/widgets/group_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 账本与分组管理页（Routes.books）。
///
/// 顶部分段切换：分组管理 / 账本管理。切换默认分组/账本后联动更新 SessionCubit。
class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

enum _Tab { groups, books }

class _BooksPageState extends State<BooksPage> {
  final BooksService _service = BooksService();
  _Tab _tab = _Tab.groups;

  BooksBloc get _bloc => context.read<BooksBloc>();
  SessionCubit get _session => context.read<SessionCubit>();

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- 分组操作 ----

  Future<void> _editGroup({FortuneGroupVo? group}) async {
    final changed = await FxSheet.show<bool>(
      context,
      title: group == null
          ? S.of(context).booksAddGroup
          : S.of(context).booksEditGroup,
      expand: true,
      child: GroupFormSheet(service: _service, group: group),
    );
    if (changed == true && mounted) {
      _bloc.add(const BooksMutated());
      await _session.load();
    }
  }

  Future<void> _removeGroup(FortuneGroupVo group) async {
    if (group.groupId == null) return;
    final ok = await _confirm(
      S.of(context).booksRemoveGroupTitle,
      S
          .of(context)
          .booksRemoveGroupMessage(
            group.groupName ?? S.of(context).booksThisGroup,
          ),
    );
    if (ok != true) return;
    await _run(() => _service.removeGroup(group.groupId!), reloadSession: true);
  }

  Future<void> _setDefaultGroup(FortuneGroupVo group) async {
    if (group.groupId == null) return;
    await _run(
      () => _service.groupAction(group.groupId!, 'setDefaultGroup'),
      reloadSession: true,
    );
  }

  Future<void> _toggleGroup(FortuneGroupVo group, bool enable) async {
    if (group.groupId == null) return;
    await _run(
      () => _service.groupAction(group.groupId!, enable ? 'enable' : 'disable'),
      reloadSession: true,
    );
  }

  /// 切换当前会话分组（不改默认，仅本地选中查看）。
  void _switchSessionGroup(FortuneGroupVo group) {
    _session.switchGroup(group);
    _showToast(S.of(context).booksSwitchedToGroup(group.groupName ?? ''));
  }

  // ---- 账本操作 ----

  Future<void> _editBook(int groupId, {FortuneBookVo? book}) async {
    final changed = await FxSheet.show<bool>(
      context,
      title: book == null
          ? S.of(context).booksAddBook
          : S.of(context).booksEditBook,
      expand: true,
      child: BookFormSheet(
        service: _service,
        groupId: groupId,
        defaultCurrency: _bloc.state.selectedGroup?.defaultCurrency,
        book: book,
      ),
    );
    if (changed == true && mounted) {
      _bloc.add(const BooksMutated());
      await _session.load();
    }
  }

  Future<void> _bookAction(
    FortuneBookVo book,
    String action, {
    bool reloadSession = false,
  }) async {
    if (book.bookId == null) return;
    await _run(
      () => _service.bookAction(book.bookId!, action),
      reloadSession: reloadSession,
    );
  }

  Future<void> _removeBook(FortuneBookVo book) async {
    if (book.bookId == null) return;
    final ok = await _confirm(
      S.of(context).booksRemoveBookTitle,
      S
          .of(context)
          .booksRemoveBookMessage(book.bookName ?? S.of(context).booksThisBook),
    );
    if (ok != true) return;
    await _run(() => _service.removeBook(book.bookId!), reloadSession: true);
  }

  /// 设为默认账本 + 更新会话当前账本。
  ///
  /// 不走 reloadSession（那会按“默认分组”重载 session，若该账本属于非默认分组会与
  /// currentGroup 错配）；改为原子定位到该账本所属分组（books 管理页当前查看的分组）。
  Future<void> _setDefaultBook(FortuneBookVo book) async {
    if (book.bookId == null) return;
    final group = _bloc.state.selectedGroup;
    try {
      await _service.bookAction(book.bookId!, 'setDefaultBook');
      if (!mounted) return;
      _bloc.add(const BooksMutated());
      if (group != null) {
        await _session.selectGroupAndBook(group, book);
      }
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool reloadSession = false,
  }) async {
    try {
      await action();
      if (!mounted) return;
      _bloc.add(const BooksMutated());
      if (reloadSession) await _session.load();
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<bool?> _confirm(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(S.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: FxPalette.of(context).danger,
            ),
            child: Text(S.of(context).commonConfirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: FxSegmented<_Tab>(
                value: _tab,
                onChanged: (v) => setState(() => _tab = v),
                segments: [
                  FxSegment(_Tab.groups, S.of(context).booksTabGroups),
                  FxSegment(_Tab.books, S.of(context).booksTabBooks),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<BooksBloc, BooksState>(
                builder: (context, state) => _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final title = _tab == _Tab.groups
        ? S.of(context).booksTabGroups
        : S.of(context).booksTabBooks;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          _iconButton(Icons.chevron_left_rounded, () {
            Navigator.of(context).maybePop();
          }),
          Expanded(child: Text(title, style: FxTypography.title)),
          _iconButton(Icons.add_rounded, _onAdd),
        ],
      ),
    );
  }

  void _onAdd() {
    if (_tab == _Tab.groups) {
      _editGroup();
    } else {
      final groupId = _bloc.state.selectedGroupId;
      if (groupId == null) {
        _showToast(S.of(context).booksCreateGroupFirst);
        return;
      }
      _editBook(groupId);
    }
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xs),
        child: Icon(icon, size: 26, color: FxPalette.of(context).textPrimary),
      ),
    );
  }

  Widget _buildBody(BooksState state) {
    switch (state.status) {
      case BooksStatus.initial:
      case BooksStatus.loading:
        return FxStateView.loading();
      case BooksStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const BooksLoaded()),
        );
      case BooksStatus.loaded:
        return _tab == _Tab.groups ? _buildGroups(state) : _buildBooks(state);
    }
  }

  // ---- 分组管理 ----

  Widget _buildGroups(BooksState state) {
    if (state.groups.isEmpty) {
      return FxStateView.empty(
        message: S.of(context).booksEmptyGroups,
        icon: Icons.folder_outlined,
      );
    }
    final currentGroupId = _session.state.currentGroupId;
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const BooksLoaded()),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.xs,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        itemCount: state.groups.length,
        itemBuilder: (context, i) {
          final g = state.groups[i];
          final isCurrent = g.groupId == currentGroupId;
          return Padding(
            padding: const EdgeInsets.only(bottom: FxSpacing.md),
            child: FxCard(
              accent: isCurrent ? FxPalette.of(context).primary : null,
              onTap: () => _switchSessionGroup(g),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.groupName ?? S.of(context).booksUnnamedGroup,
                          style: FxTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        FxTagChip(
                          label: S.of(context).booksCurrent,
                          dotColor: FxPalette.of(context).primary,
                        ),
                      _menu(
                        onEdit: () => _editGroup(group: g),
                        onDefault: () => _setDefaultGroup(g),
                        defaultLabel: S.of(context).booksSetDefaultGroup,
                        onToggle: () => _toggleGroup(g, !g.enable),
                        enabled: g.enable,
                        onRemove: () => _removeGroup(g),
                      ),
                    ],
                  ),
                  const SizedBox(height: FxSpacing.xs),
                  Wrap(
                    spacing: FxSpacing.sm,
                    runSpacing: FxSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _pill(g.defaultCurrency ?? '-'),
                      if (g.roleTypeDesc != null)
                        _pill(
                          g.roleTypeDesc!,
                          tint: FxPalette.of(context).info,
                        ),
                      if (!g.enable)
                        _pill(
                          S.of(context).booksDisabled,
                          tint: FxPalette.of(context).textTertiary,
                        ),
                      if (g.defaultBookName != null)
                        Text(
                          S.of(context).booksDefaultBook(g.defaultBookName!),
                          style: FxTypography.caption.copyWith(
                            color: FxPalette.of(context).textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- 账本管理 ----

  Widget _buildBooks(BooksState state) {
    final groupId = state.selectedGroupId;
    final currentBookId = _session.state.currentBookId;
    if (groupId == null) {
      return FxStateView.empty(message: S.of(context).booksSelectGroupFirst);
    }
    return Column(
      children: [
        // 分组选择条
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
            children: [
              for (final g in state.groups)
                Padding(
                  padding: const EdgeInsets.only(right: FxSpacing.sm),
                  child: FxTagChip(
                    label: g.groupName ?? '-',
                    selected: g.groupId == groupId,
                    onTap: () => _bloc.add(BooksGroupSelected(g.groupId!)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _bloc.add(const BooksLoaded()),
            child: (state.books.isEmpty && state.recycledBooks.isEmpty)
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: FxStateView.empty(
                          message: S.of(context).booksEmptyBooks,
                          icon: Icons.menu_book_outlined,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      FxSpacing.lg,
                      FxSpacing.sm,
                      FxSpacing.lg,
                      FxSpacing.xxxl,
                    ),
                    children: [
                      for (final b in state.books)
                        _bookTile(b, groupId, currentBookId, recycled: false),
                      if (state.recycledBooks.isNotEmpty) ...[
                        const SizedBox(height: FxSpacing.md),
                        Text(
                          S.of(context).booksRecycleBin,
                          style: FxTypography.label.copyWith(
                            color: FxPalette.of(context).textSecondary,
                          ),
                        ),
                        const SizedBox(height: FxSpacing.xs),
                        for (final b in state.recycledBooks)
                          _bookTile(b, groupId, currentBookId, recycled: true),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _bookTile(
    FortuneBookVo b,
    int groupId,
    int? currentBookId, {
    required bool recycled,
  }) {
    final isCurrent = b.bookId == currentBookId;
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: FxCard(
        accent: isCurrent ? FxPalette.of(context).primary : null,
        background: recycled ? FxPalette.of(context).surfaceMuted : null,
        onTap: recycled ? null : () => _setDefaultBook(b),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          b.bookName ?? S.of(context).booksUnnamedBook,
                          style: FxTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: FxSpacing.sm),
                        FxTagChip(
                          label: S.of(context).booksCurrent,
                          dotColor: FxPalette.of(context).primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: FxSpacing.xs),
                  Wrap(
                    spacing: FxSpacing.sm,
                    runSpacing: FxSpacing.xs,
                    children: [
                      _pill(b.defaultCurrency ?? '-'),
                      if (!b.enable)
                        _pill(
                          S.of(context).booksDisabled,
                          tint: FxPalette.of(context).textTertiary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (recycled)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _bookAction(b, 'putBack'),
                    child: Text(S.of(context).booksPutBack),
                  ),
                  IconButton(
                    onPressed: () => _removeBook(b),
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      color: FxPalette.of(context).danger,
                    ),
                  ),
                ],
              )
            else
              _menu(
                onEdit: () => _editBook(groupId, book: b),
                onDefault: () => _setDefaultBook(b),
                defaultLabel: S.of(context).booksSetDefaultBook,
                onToggle: () => _bookAction(
                  b,
                  b.enable ? 'disable' : 'enable',
                  reloadSession: true,
                ),
                enabled: b.enable,
                onRecycle: () =>
                    _bookAction(b, 'moveToRecycleBin', reloadSession: true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, {Color? tint}) {
    final c = tint ?? FxPalette.of(context).textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(text, style: FxTypography.caption.copyWith(color: c)),
    );
  }

  Widget _menu({
    required VoidCallback onEdit,
    required VoidCallback onDefault,
    required String defaultLabel,
    required VoidCallback onToggle,
    required bool enabled,
    VoidCallback? onRecycle,
    VoidCallback? onRemove,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: FxPalette.of(context).textSecondary,
      ),
      onSelected: (v) {
        HapticFeedback.selectionClick();
        switch (v) {
          case 'edit':
            onEdit();
          case 'default':
            onDefault();
          case 'toggle':
            onToggle();
          case 'recycle':
            onRecycle?.call();
          case 'remove':
            onRemove?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(S.of(context).booksEdit)),
        PopupMenuItem(value: 'default', child: Text(defaultLabel)),
        PopupMenuItem(
          value: 'toggle',
          child: Text(
            enabled ? S.of(context).booksDisable : S.of(context).booksEnable,
          ),
        ),
        if (onRecycle != null)
          PopupMenuItem(
            value: 'recycle',
            child: Text(S.of(context).booksMoveToRecycle),
          ),
        if (onRemove != null)
          PopupMenuItem(
            value: 'remove',
            child: Text(
              S.of(context).booksDelete,
              style: TextStyle(color: FxPalette.of(context).danger),
            ),
          ),
      ],
    );
  }
}
