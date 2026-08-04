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
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

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
      title: group == null ? '新增分组' : '编辑分组',
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
    final ok = await _confirm('删除分组', '确定删除「${group.groupName ?? '该分组'}」吗？'
        '该分组下账本也将无法访问。');
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
    _showToast('已切换到「${group.groupName ?? ''}」');
  }

  // ---- 账本操作 ----

  Future<void> _editBook(int groupId, {FortuneBookVo? book}) async {
    final changed = await FxSheet.show<bool>(
      context,
      title: book == null ? '新增账本' : '编辑账本',
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

  Future<void> _bookAction(FortuneBookVo book, String action, {
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
    final ok = await _confirm('彻底删除账本', '确定彻底删除「${book.bookName ?? '该账本'}」吗？'
        '此操作不可撤销。');
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
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: FxColors.danger),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.canvas,
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
                segments: const [
                  FxSegment(_Tab.groups, '分组管理'),
                  FxSegment(_Tab.books, '账本管理'),
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
    final title = _tab == _Tab.groups ? '分组管理' : '账本管理';
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
        _showToast('请先创建分组');
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
        child: Icon(icon, size: 26, color: FxColors.textPrimary),
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
        return _tab == _Tab.groups
            ? _buildGroups(state)
            : _buildBooks(state);
    }
  }

  // ---- 分组管理 ----

  Widget _buildGroups(BooksState state) {
    if (state.groups.isEmpty) {
      return FxStateView.empty(
        message: '暂无分组，点击右上角 + 新增',
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
              accent: isCurrent ? FxColors.primary : null,
              onTap: () => _switchSessionGroup(g),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.groupName ?? '未命名分组',
                          style: FxTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent)
                        const FxTagChip(label: '当前', dotColor: FxColors.primary),
                      _menu(
                        onEdit: () => _editGroup(group: g),
                        onDefault: () => _setDefaultGroup(g),
                        defaultLabel: '设为默认分组',
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
                        _pill(g.roleTypeDesc!, tint: FxColors.info),
                      if (!g.enable) _pill('已停用', tint: FxColors.textTertiary),
                      if (g.defaultBookName != null)
                        Text(
                          '默认账本：${g.defaultBookName}',
                          style: FxTypography.caption,
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
      return FxStateView.empty(message: '请先选择分组');
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
                          message: '该分组暂无账本，点击右上角 + 新增',
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
                        const Text('回收站', style: FxTypography.label),
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
        accent: isCurrent ? FxColors.primary : null,
        background: recycled ? FxColors.surfaceMuted : null,
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
                          b.bookName ?? '未命名账本',
                          style: FxTypography.bodyStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: FxSpacing.sm),
                        const FxTagChip(
                          label: '当前',
                          dotColor: FxColors.primary,
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
                      if (!b.enable) _pill('已停用', tint: FxColors.textTertiary),
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
                    child: const Text('移出'),
                  ),
                  IconButton(
                    onPressed: () => _removeBook(b),
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: FxColors.danger,
                    ),
                  ),
                ],
              )
            else
              _menu(
                onEdit: () => _editBook(groupId, book: b),
                onDefault: () => _setDefaultBook(b),
                defaultLabel: '设为默认账本',
                onToggle: () => _bookAction(
                  b,
                  b.enable ? 'disable' : 'enable',
                  reloadSession: true,
                ),
                enabled: b.enable,
                onRecycle: () => _bookAction(b, 'moveToRecycleBin',
                    reloadSession: true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, {Color? tint}) {
    final c = tint ?? FxColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: FxRadius.pillBorder,
      ),
      child: Text(
        text,
        style: FxTypography.caption.copyWith(color: c),
      ),
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
      icon: const Icon(Icons.more_vert_rounded, color: FxColors.textSecondary),
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
        const PopupMenuItem(value: 'edit', child: Text('编辑')),
        PopupMenuItem(value: 'default', child: Text(defaultLabel)),
        PopupMenuItem(value: 'toggle', child: Text(enabled ? '停用' : '启用')),
        if (onRecycle != null)
          const PopupMenuItem(value: 'recycle', child: Text('移入回收站')),
        if (onRemove != null)
          const PopupMenuItem(
            value: 'remove',
            child: Text('删除', style: TextStyle(color: FxColors.danger)),
          ),
      ],
    );
  }
}
