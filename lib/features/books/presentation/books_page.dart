import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/navigation/fx_page_route.dart';
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
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
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
  const BooksPage({
    super.key,
    this.initialTab = BooksTab.groups,
    this.groupId,
    this.restoreLastTab = true,
  });

  final BooksTab initialTab;
  final int? groupId;
  final bool restoreLastTab;

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
    if (!widget.restoreLastTab || widget.groupId != null) return;
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
    FxFeedback.info(context, message: message);
  }

  String _errorMessage(Object error) {
    if (error is FxApiException) return error.message;
    return S.of(context).profileSaveFailedRetry;
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
      _showToast(_errorMessage(e));
    }
  }

  void _showVisitorNotice(String message) {
    _showToast(message);
  }

  Future<void> _openGroupForm({ManagedGroup? group}) async {
    final formKey = GlobalKey<GroupFormSheetState>();
    final changed = await FxSheet.show<bool>(
      context,
      scrollable: false,
      maxHeightFactor: FxSheet.formHeightFactor,
      title: group == null
          ? S.of(context).booksAddGroup
          : S.of(context).booksEditGroup,
      submitLabel: group == null
          ? S.of(context).booksCreateGroup
          : S.of(context).booksSaveChanges,
      onSubmit: () => formKey.currentState?.submit(),
      child: GroupFormSheet(
        key: formKey,
        service: _service,
        group: group?.group,
      ),
    );
    if (changed == true && mounted) {
      _showToast(
        group == null
            ? S.of(context).booksGroupCreated
            : S.of(context).booksGroupSaved,
      );
      await _syncAfterWrite();
    }
  }

  Future<void> _openGroupDetail(ManagedGroup group) async {
    await Navigator.of(context).push<void>(
      buildFxRoute<void>(
        settings: const RouteSettings(name: 'books/group-detail'),
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
      buildFxRoute<void>(
        settings: const RouteSettings(name: 'books/book-detail'),
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
    final formKey = GlobalKey<BookFormSheetState>();
    final changed = await FxSheet.show<bool>(
      context,
      scrollable: false,
      maxHeightFactor: FxSheet.formHeightFactor,
      title: book == null
          ? S.of(context).booksAddBook
          : S.of(context).booksEditBook,
      submitLabel: book == null
          ? S.of(context).booksCreateBook
          : S.of(context).booksSaveChanges,
      onSubmit: () => formKey.currentState?.submit(),
      child: BookFormSheet(
        key: formKey,
        service: _service,
        groupId: groupId,
        defaultCurrency: group?.defaultCurrency,
        book: book,
      ),
    );
    if (changed == true && mounted) {
      _showToast(
        book == null
            ? S.of(context).booksBookCreated
            : S.of(context).booksBookSaved,
      );
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
    final action = await FxSheet.show<_GroupAction>(
      context,
      title: group.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!capabilities.canWrite)
            _menuItem(
              context,
              Icons.visibility_rounded,
              S.of(context).booksVisitorViewGroupOnly,
              _GroupAction.explain,
            ),
          _menuItem(
            context,
            Icons.star_rounded,
            S.of(context).booksSetDefaultGroup,
            _GroupAction.setDefault,
            enabled: GroupGuard.canSetDefault(
              group: group,
              defaultGroupId: state.defaultGroupId,
              enabledActiveBooksCount: enabledBookCount,
              capabilities: capabilities,
            ).allowed,
          ),
          _menuItem(
            context,
            Icons.edit_rounded,
            S.of(context).booksEdit,
            _GroupAction.edit,
            enabled: capabilities.canEdit,
          ),
          _menuItem(
            context,
            Icons.person_add_alt_rounded,
            S.of(context).booksInviteMembers,
            _GroupAction.invite,
            enabled: capabilities.canInvite,
          ),
          _menuItem(
            context,
            group.enable ? Icons.toggle_off_rounded : Icons.toggle_on_rounded,
            group.enable
                ? S.of(context).booksDisable
                : S.of(context).booksEnable,
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
            context,
            Icons.delete_forever_rounded,
            S.of(context).booksDeleteGroupForever,
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
              throw FxApiException(-1, S.current.booksGroupNoAvailableBook);
            }
            await _service.setDefaultGroup(groupId);
          });
        } else {
          await _run(() => _service.setDefaultGroup(groupId));
        }
      case _GroupAction.edit:
        await _openGroupForm(group: group);
      case _GroupAction.explain:
        _showVisitorNotice(S.of(context).booksVisitorViewGroupOnly);
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
    final ok = await DestructiveConfirmSheet.show(
      context,
      title: S.of(context).booksDeleteGroupTitle(name),
      message: S.of(context).booksDeleteGroupWarning,
      nameToMatch: name,
      checkboxLabel: S.of(context).booksDeleteGroupUnderstand,
      confirmLabel: S.of(context).booksPermanentlyDelete,
      cancelLabel: S.of(context).commonCancel,
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
    final action = await FxSheet.show<_BookAction>(
      context,
      title: book.bookName ?? S.of(context).commonMoreActions,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: inRecycleBin
            ? [
                _menuItem(
                  context,
                  Icons.restore_rounded,
                  S.of(context).booksPutBack,
                  _BookAction.restore,
                  enabled: BookGuard.canRestore(
                    capabilities: capabilities,
                  ).allowed,
                ),
                _menuItem(
                  context,
                  Icons.delete_forever_rounded,
                  S.of(context).booksDeleteForever,
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
                  context,
                  Icons.account_balance_wallet_rounded,
                  S.of(context).booksDefaultAccountSettings,
                  _BookAction.accounts,
                  enabled: capabilities.canEdit,
                ),
                _menuItem(
                  context,
                  Icons.star_rounded,
                  S.of(context).booksSetDefaultBook,
                  _BookAction.setDefault,
                  enabled: BookGuard.canSetDefault(
                    book: book,
                    defaultBookId: defaultBookId,
                    inRecycleBin: false,
                    capabilities: capabilities,
                  ).allowed,
                ),
                _menuItem(
                  context,
                  Icons.edit_rounded,
                  S.of(context).booksEdit,
                  _BookAction.edit,
                  enabled: capabilities.canEdit,
                ),
                _menuItem(
                  context,
                  book.enable
                      ? Icons.toggle_off_rounded
                      : Icons.toggle_on_rounded,
                  book.enable
                      ? S.of(context).booksDisable
                      : S.of(context).booksEnable,
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
                  context,
                  Icons.delete_outline_rounded,
                  S.of(context).booksMoveToRecycle,
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
        : S.of(context).booksBookFallbackName;
    final ok = await DestructiveConfirmSheet.show(
      context,
      title: S.of(context).booksDeleteBookForeverTitle(name),
      message: S.of(context).booksDeleteBookWarning,
      nameToMatch: name,
      checkboxLabel: S.of(context).booksDefaultDestructiveCheckbox,
      confirmLabel: S.of(context).booksDeleteForever,
      cancelLabel: S.of(context).commonCancel,
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
                segments: [
                  FxSegment(BooksTab.groups, S.of(context).booksTabGroupShort),
                  FxSegment(BooksTab.books, S.of(context).booksTabBookShort),
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
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).booksManageTitle, style: FxTypography.title),
                const SizedBox(height: 2),
                Text(
                  S
                      .of(context)
                      .booksCurrentAt(
                        tab == BooksTab.groups
                            ? S.of(context).booksTabGroupShort
                            : S.of(context).booksTabBookShort,
                      ),
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
      label = '＋ ${S.of(context).booksAddGroup}';
      onPressed = capabilities.canCreateGroup ? onAddGroup : null;
      if (onPressed == null) hint = S.of(context).booksVisitorCannotCreateGroup;
    } else {
      label = '＋ ${S.of(context).booksAddBook}';
      if (isRecycleBin) {
        onPressed = null;
        hint = S.of(context).booksRecycleCannotCreateBook;
      } else if (group != null && !group.enable) {
        onPressed = null;
        hint = S.of(context).booksEnableGroupBeforeCreateBook;
      } else {
        onPressed = capabilities.canCreateBook ? onAddBook : null;
        if (onPressed == null) {
          hint = S.of(context).booksVisitorCannotCreateBook;
        }
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
