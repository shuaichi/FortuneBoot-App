import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/data/books_service.dart';
import 'package:fortuneboot/features/books/domain/books_manage_capabilities.dart';
import 'package:fortuneboot/features/books/domain/books_manage_guards.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/pages/book_detail_page.dart';
import 'package:fortuneboot/features/books/presentation/pages/books_tab.dart';
import 'package:fortuneboot/features/books/presentation/pages/group_detail_page.dart';
import 'package:fortuneboot/features/books/presentation/pages/groups_tab.dart';
import 'package:fortuneboot/features/books/presentation/widgets/book_form_sheet.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/features/books/presentation/widgets/group_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BooksManageArgs {
  const BooksManageArgs({this.initialTab, this.groupId});

  final BooksTab? initialTab;
  final int? groupId;
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key, this.initialTab = BooksTab.groups, this.groupId});

  final BooksTab initialTab;
  final int? groupId;

  @override
  State<BooksPage> createState() => _BooksPageState();
}

enum BooksTab { groups, books }

class _BooksPageState extends State<BooksPage> {
  static const _lastTabKey = 'books_manage_last_tab';

  final BooksService _service = BooksService();
  late BooksTab _tab = widget.initialTab;

  BooksBloc get _bloc => context.read<BooksBloc>();
  SessionCubit get _session => context.read<SessionCubit>();

  @override
  void initState() {
    super.initState();
    _loadLastTab();
  }

  Future<void> _loadLastTab() async {
    if (widget.groupId != null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastTabKey);
    if (!mounted || raw == null) return;
    final restored = raw == BooksTab.books.name
        ? BooksTab.books
        : BooksTab.groups;
    if (restored == widget.initialTab) return;
    setState(() => _tab = restored);
  }

  Future<void> _setTab(BooksTab tab) async {
    setState(() => _tab = tab);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTabKey, tab.name);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _syncAfterWrite() async {
    _bloc.add(const BooksMutated());
    await _session.load();
    BillMutations.bump();
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool syncSession = true,
  }) async {
    try {
      await action();
      if (!mounted) return;
      if (syncSession) {
        await _syncAfterWrite();
      } else {
        _bloc.add(const BooksMutated());
        BillMutations.bump();
      }
    } on Object catch (e) {
      if (!mounted) return;
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  void _showVisitorNotice(String message) {
    _showToast(message);
  }

  Future<void> _openGroupForm({ManagedGroup? group}) async {
    final changed = await FxSheet.show<bool>(
      context,
      title: group == null
          ? S.of(context).booksAddGroup
          : S.of(context).booksEditGroup,
      expand: true,
      child: GroupFormSheet(service: _service, group: group?.group),
    );
    if (changed == true && mounted) {
      _showToast(group == null ? '分组已创建' : '分组已保存');
      await _syncAfterWrite();
    }
  }

  Future<void> _openGroupDetail(ManagedGroup group) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(
          group: group,
          service: _service,
          capabilities: _bloc.state.capabilitiesFor(group.groupId),
          currentUsername: _bloc.state.currentUsername,
          onChanged: () async {
            await _openGroupForm(group: group);
          },
          onManageBooks: () {
            final targetGroupId = group.groupId;
            Navigator.of(context).maybePop();
            if (targetGroupId != null) {
              _bloc.add(BooksGroupSelected(targetGroupId));
            }
            _setTab(BooksTab.books);
          },
        ),
      ),
    );
  }

  Future<void> _openBookDetail(FortuneBookVo book) async {
    final state = _bloc.state;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BookDetailPage(
          book: book,
          group: state.selectedManagedGroup,
          service: _service,
          capabilities: state.capabilitiesFor(state.selectedGroupId),
          inRecycleBin: state.bookSegment == BooksSegment.recycleBin,
          onChanged: () async {
            await _openBookForm(book: book);
          },
        ),
      ),
    );
  }

  Future<void> _openBookForm({FortuneBookVo? book}) async {
    final state = _bloc.state;
    final group = state.selectedManagedGroup;
    final groupId = group?.groupId;
    if (groupId == null) {
      _showToast(S.of(context).booksSelectGroupFirst);
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: book == null
          ? S.of(context).booksAddBook
          : S.of(context).booksEditBook,
      expand: true,
      child: BookFormSheet(
        service: _service,
        groupId: groupId,
        defaultCurrency: group?.defaultCurrency,
        book: book,
      ),
    );
    if (changed == true && mounted) {
      _showToast(book == null ? '账本已创建' : '账本已保存');
      await _syncAfterWrite();
    }
  }

  Future<void> _openGroupMenu(ManagedGroup group) async {
    final groupId = group.groupId;
    if (groupId == null) return;
    _bloc.add(BooksCapabilitiesRequested(groupId));
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    var state = _bloc.state;
    var capabilities = state.capabilitiesFor(groupId);
    if (!capabilities.resolved) {
      final members = await _service.getGroupUsers(groupId);
      if (!mounted) return;
      final current = members.where(
        (m) => m.matchesAccount(state.currentUsername),
      );
      capabilities = CapabilityResolver.fromGroup(
        group,
        fallbackMember: current.isEmpty ? null : current.first,
      );
      _bloc.add(BooksCapabilitiesRequested(groupId));
      state = _bloc.state;
    }
    final enabledBookCount = group.groupId == state.selectedGroupId
        ? state.enabledActiveBooks.length
        : group.defaultBookId == null
        ? 0
        : 1;
    final action = await showModalBottomSheet<_GroupAction>(
      context: context,
      backgroundColor: FxPalette.of(context).surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!capabilities.canWrite)
              _menuItem(
                ctx,
                Icons.visibility_rounded,
                '你是访客，仅可查看分组信息',
                _GroupAction.explain,
              ),
            _menuItem(
              ctx,
              Icons.star_rounded,
              '设为默认分组',
              _GroupAction.setDefault,
              enabled: GroupGuard.canSetDefault(
                group: group,
                defaultGroupId: state.defaultGroupId,
                enabledActiveBooksCount: enabledBookCount,
                capabilities: capabilities,
              ).allowed,
            ),
            _menuItem(
              ctx,
              Icons.edit_rounded,
              S.of(ctx).booksEdit,
              _GroupAction.edit,
              enabled: capabilities.canEdit,
            ),
            _menuItem(
              ctx,
              Icons.person_add_alt_rounded,
              '邀请成员',
              _GroupAction.invite,
              enabled: capabilities.canInvite,
            ),
            _menuItem(
              ctx,
              group.enable ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
              group.enable ? S.of(ctx).booksDisable : S.of(ctx).booksEnable,
              _GroupAction.toggle,
              enabled: GroupGuard.canToggle(
                group: group,
                targetEnable: !group.enable,
                defaultGroupId: state.defaultGroupId,
                enabledGroupCount: state.enabledGroups.length,
                capabilities: capabilities,
              ).allowed,
            ),
            _menuItem(
              ctx,
              Icons.delete_forever_rounded,
              '永久删除分组',
              _GroupAction.delete,
              enabled: GroupGuard.canDelete(
                group: group,
                defaultGroupId: state.defaultGroupId,
                enabledGroupCount: state.enabledGroups.length,
                capabilities: capabilities,
              ).allowed,
              danger: true,
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _GroupAction.setDefault:
        if (group.groupId != state.selectedGroupId) {
          await _run(() async {
            final enabled = await _service.getBookPage(
              groupId: groupId,
              enable: true,
            );
            if (enabled.rows.isEmpty) {
              throw FxApiException(-1, '该分组暂无可用账本，请先新建或启用账本');
            }
            await _service.setDefaultGroup(groupId);
          });
        } else {
          await _run(() => _service.setDefaultGroup(groupId));
        }
      case _GroupAction.edit:
        await _openGroupForm(group: group);
      case _GroupAction.explain:
        _showVisitorNotice('你是访客，仅可查看分组信息');
      case _GroupAction.invite:
        await _openGroupDetail(group);
      case _GroupAction.toggle:
        await _run(
          () => group.enable
              ? _service.disableGroup(groupId)
              : _service.enableGroup(groupId),
        );
      case _GroupAction.delete:
        await _confirmDeleteGroup(group);
    }
  }

  Future<void> _confirmDeleteGroup(ManagedGroup group) async {
    final name = group.name;
    final ok = await FxSheet.show<bool>(
      context,
      title: '永久删除分组「$name」?',
      child: DestructiveConfirmSheet(
        title: '永久删除分组「$name」?',
        objectName: name,
        warning: '此操作不可恢复，会删除账本、账户、分类、标签、交易对象、成员关系、全部账单记录与照片。当前版本无法预览具体数量。',
        checkboxLabel: '我理解无法预览数量，仍要删除',
      ),
    );
    if (ok == true && group.groupId != null) {
      await _run(() => _service.removeGroup(group.groupId!));
    }
  }

  Future<void> _openBookMenu(FortuneBookVo book) async {
    final state = _bloc.state;
    final group = state.selectedManagedGroup;
    final groupId = group?.groupId;
    if (groupId == null || book.bookId == null) return;
    final capabilities = state.capabilitiesFor(groupId);
    final inRecycleBin = state.bookSegment == BooksSegment.recycleBin;
    final defaultBookId = group?.defaultBookId;
    final enabledCount = state.enabledActiveBooks.length;
    final action = await showModalBottomSheet<_BookAction>(
      context: context,
      backgroundColor: FxPalette.of(context).surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: inRecycleBin
              ? [
                  _menuItem(
                    ctx,
                    Icons.restore_rounded,
                    S.of(ctx).booksPutBack,
                    _BookAction.restore,
                    enabled: BookGuard.canRestore(
                      capabilities: capabilities,
                    ).allowed,
                  ),
                  _menuItem(
                    ctx,
                    Icons.delete_forever_rounded,
                    '彻底删除',
                    _BookAction.delete,
                    enabled: BookGuard.canDeleteForever(
                      book: book,
                      defaultBookId: defaultBookId,
                      enabledActiveBookCount: enabledCount,
                      capabilities: capabilities,
                      inRecycleBin: true,
                    ).allowed,
                    danger: true,
                  ),
                ]
              : [
                  _menuItem(
                    ctx,
                    Icons.account_balance_wallet_rounded,
                    '默认账户设置',
                    _BookAction.accounts,
                    enabled: capabilities.canEdit,
                  ),
                  _menuItem(
                    ctx,
                    Icons.star_rounded,
                    S.of(ctx).booksSetDefaultBook,
                    _BookAction.setDefault,
                    enabled: BookGuard.canSetDefault(
                      book: book,
                      defaultBookId: defaultBookId,
                      inRecycleBin: false,
                      capabilities: capabilities,
                    ).allowed,
                  ),
                  _menuItem(
                    ctx,
                    Icons.edit_rounded,
                    S.of(ctx).booksEdit,
                    _BookAction.edit,
                    enabled: capabilities.canEdit,
                  ),
                  _menuItem(
                    ctx,
                    book.enable
                        ? Icons.toggle_off_rounded
                        : Icons.toggle_on_rounded,
                    book.enable
                        ? S.of(ctx).booksDisable
                        : S.of(ctx).booksEnable,
                    _BookAction.toggle,
                    enabled: BookGuard.canToggle(
                      book: book,
                      targetEnable: !book.enable,
                      defaultBookId: defaultBookId,
                      enabledActiveBookCount: enabledCount,
                      capabilities: capabilities,
                    ).allowed,
                  ),
                  _menuItem(
                    ctx,
                    Icons.delete_outline_rounded,
                    S.of(ctx).booksMoveToRecycle,
                    _BookAction.recycle,
                    enabled: BookGuard.canMoveToRecycle(
                      book: book,
                      defaultBookId: defaultBookId,
                      enabledActiveBookCount: enabledCount,
                      capabilities: capabilities,
                    ).allowed,
                  ),
                ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _BookAction.accounts:
        await _openBookDetail(book);
      case _BookAction.setDefault:
        await _run(() => _service.setDefaultBook(book.bookId!));
      case _BookAction.edit:
        await _openBookForm(book: book);
      case _BookAction.toggle:
        await _run(
          () => book.enable
              ? _service.disableBook(book.bookId!)
              : _service.enableBook(book.bookId!),
        );
      case _BookAction.recycle:
        await _run(() => _service.moveBookToRecycleBin(book.bookId!));
      case _BookAction.restore:
        await _run(() => _service.putBackBook(book.bookId!));
      case _BookAction.delete:
        await _confirmDeleteBook(book);
    }
  }

  Future<void> _confirmDeleteBook(FortuneBookVo book) async {
    final name = book.bookName?.trim().isNotEmpty == true
        ? book.bookName!.trim()
        : '该账本';
    final ok = await FxSheet.show<bool>(
      context,
      title: '彻底删除账本「$name」?',
      child: DestructiveConfirmSheet(
        title: '彻底删除账本「$name」?',
        objectName: name,
        warning: '此操作不可恢复。删除前请确认当前分组仍保留至少一个在用启用账本。',
        confirmLabel: '彻底删除',
      ),
    );
    if (ok == true && book.bookId != null) {
      await _run(() => _service.removeBook(book.bookId!));
    }
  }

  Widget _menuItem<T>(
    BuildContext context,
    IconData icon,
    String label,
    T value, {
    bool enabled = true,
    bool danger = false,
  }) {
    final palette = FxPalette.of(context);
    final color = !enabled
        ? palette.textTertiary
        : danger
        ? palette.danger
        : palette.textPrimary;
    return ListTile(
      enabled: enabled,
      leading: Icon(icon, color: color),
      title: Text(label, style: FxTypography.body.copyWith(color: color)),
      onTap: enabled ? () => Navigator.of(context).pop(value) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(tab: _tab, onBack: () => Navigator.of(context).maybePop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: FxSegmented<BooksTab>(
                value: _tab,
                onChanged: _setTab,
                segments: const [
                  FxSegment(BooksTab.groups, '分组'),
                  FxSegment(BooksTab.books, '账本'),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: [
                  GroupsTab(
                    currentGroupId: session.currentGroupId,
                    onOpenDetail: _openGroupDetail,
                    onOpenMenu: _openGroupMenu,
                  ),
                  BooksTabView(
                    currentBookId: session.currentBookId,
                    onOpenDetail: _openBookDetail,
                    onOpenMenu: _openBookMenu,
                    onMissingAccountTap: _openBookDetail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BlocBuilder<BooksBloc, BooksState>(
          builder: (context, state) => _BottomAction(
            tab: _tab,
            state: state,
            onAddGroup: () => _openGroupForm(),
            onAddBook: () => _openBookForm(),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tab, required this.onBack});

  final BooksTab tab;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: onBack,
            radius: 24,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.chevron_left_rounded, size: 30),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('分组与账本', style: FxTypography.title),
                const SizedBox(height: 2),
                Text(
                  '当前在：${tab == BooksTab.groups ? '分组' : '账本'}',
                  style: FxTypography.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.tab,
    required this.state,
    required this.onAddGroup,
    required this.onAddBook,
  });

  final BooksTab tab;
  final BooksState state;
  final VoidCallback onAddGroup;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    final group = state.selectedManagedGroup;
    final capabilities = state.capabilitiesFor(group?.groupId);
    final isRecycleBin = state.bookSegment == BooksSegment.recycleBin;
    String label;
    VoidCallback? onPressed;
    String? hint;
    if (tab == BooksTab.groups) {
      label = '＋ 新建分组';
      onPressed = capabilities.canCreateGroup ? onAddGroup : null;
      if (onPressed == null) hint = '访客无法新建分组';
    } else {
      label = '＋ 新建账本';
      if (isRecycleBin) {
        onPressed = null;
        hint = '回收站中不可新建账本';
      } else if (group != null && !group.enable) {
        onPressed = null;
        hint = '启用分组后可新建账本';
      } else {
        onPressed = capabilities.canCreateBook ? onAddBook : null;
        if (onPressed == null) hint = '访客无法新建账本';
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hint != null) ...[
            Text(
              hint,
              style: FxTypography.caption.copyWith(
                color: FxPalette.of(context).textSecondary,
              ),
            ),
            const SizedBox(height: FxSpacing.xs),
          ],
          FxButton(label: label, expand: true, onPressed: onPressed),
        ],
      ),
    );
  }
}

enum _GroupAction { setDefault, edit, explain, invite, toggle, delete }

enum _BookAction {
  accounts,
  setDefault,
  edit,
  toggle,
  recycle,
  restore,
  delete,
}
