import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/categories/data/category_models.dart';
import 'package:fortuneboot/features/categories/data/category_service.dart';
import 'package:fortuneboot/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:fortuneboot/features/categories/presentation/widgets/category_form_sheet.dart';
import 'package:fortuneboot/features/categories/presentation/widgets/category_tile.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 分类管理页（树形，支出/收入两大组，Routes.categories）。
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final CategoryService _service = CategoryService();

  CategoriesBloc get _bloc => context.read<CategoriesBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({
    FortuneCategoryVo? category,
    int? presetType,
    int? presetParentId,
  }) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: category == null ? '新增分类' : '编辑分类',
      expand: true,
      child: CategoryFormSheet(
        service: _service,
        bookId: bookId,
        tree: _bloc.state.tree,
        category: category,
        presetType: presetType,
        presetParentId: presetParentId,
      ),
    );
    if (changed == true && mounted) _bloc.add(const CategoriesMutated());
  }

  Future<void> _openMenu(FortuneCategoryVo node) async {
    HapticFeedback.selectionClick();
    final inRecycle = _bloc.state.tab.recycleBin;
    final action = await showManageMenu(context, inRecycleBin: inRecycle);
    if (action == null || !mounted) return;
    switch (action) {
      case ManageMenuAction.edit:
        await _openForm(category: node);
      case ManageMenuAction.moveToRecycleBin:
        await _move(node, toRecycle: true);
      case ManageMenuAction.putBack:
        await _move(node, toRecycle: false);
      case ManageMenuAction.remove:
        await _remove(node);
    }
  }

  Future<void> _move(FortuneCategoryVo node, {required bool toRecycle}) async {
    final bookId = _bookId;
    if (bookId == null || node.categoryId == null) return;
    if (toRecycle) {
      final ok = await confirmManageAction(
        context,
        title: '移入回收站',
        message: '确定将「${node.categoryName ?? '该分类'}」移入回收站吗？',
        confirmLabel: '移入',
      );
      if (ok != true) return;
    }
    try {
      if (toRecycle) {
        await _service.moveToRecycleBin(
          bookId: bookId,
          categoryId: node.categoryId!,
        );
      } else {
        await _service.putBack(bookId: bookId, categoryId: node.categoryId!);
      }
      if (mounted) _bloc.add(const CategoriesMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<void> _remove(FortuneCategoryVo node) async {
    final bookId = _bookId;
    if (bookId == null || node.categoryId == null) return;
    final ok = await confirmManageAction(
      context,
      title: '彻底删除',
      message: '确定彻底删除「${node.categoryName ?? '该分类'}」吗？此操作不可撤销。',
      confirmLabel: '删除',
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, categoryId: node.categoryId!);
      if (mounted) _bloc.add(const CategoriesMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );

    return _BookSync(
      bookId: bookId,
      child: BlocConsumer<CategoriesBloc, CategoriesState>(
        listenWhen: (p, c) =>
            c.toastMessage != null && p.toastMessage != c.toastMessage,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg != null) _showToast(msg);
        },
        builder: (context, state) {
          return ManageScaffold(
            title: '分类管理',
            searchHint: '搜索分类名称',
            onAdd: () => _openForm(),
            onSearch: (kw) => _bloc.add(CategoriesSearchChanged(kw)),
            tab: state.tab,
            onTabChanged: (t) => _bloc.add(CategoriesTabChanged(t)),
            body: _buildBody(state, bookId),
          );
        },
      ),
    );
  }

  Widget _buildBody(CategoriesState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: '请先选择账本');
    }
    switch (state.status) {
      case CategoriesStatus.initial:
      case CategoriesStatus.loading:
        return FxStateView.loading();
      case CategoriesStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const CategoriesLoaded()),
        );
      case CategoriesStatus.empty:
      case CategoriesStatus.loaded:
        return _buildTree(state);
    }
  }

  Widget _buildTree(CategoriesState state) {
    final expense = state.expenseRoots;
    final income = state.incomeRoots;
    if (expense.isEmpty && income.isEmpty) {
      return FxStateView.empty(
        message: '暂无分类，点击右上角 + 新增',
        icon: Icons.category_outlined,
      );
    }
    final inRecycle = state.tab.recycleBin;
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const CategoriesLoaded()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.xs,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        children: [
          if (expense.isNotEmpty)
            _section('支出分类', FxColors.expense, expense, 1, inRecycle),
          if (income.isNotEmpty)
            _section('收入分类', FxColors.income, income, 2, inRecycle),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    Color tint,
    List<FortuneCategoryVo> roots,
    int type,
    bool inRecycle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FxSpacing.xs,
            FxSpacing.md,
            FxSpacing.xs,
            FxSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Text(title, style: FxTypography.label),
            ],
          ),
        ),
        for (final node in roots) ...[
          CategoryTile(
            node: node,
            typeTint: tint,
            onTap: (n) => _openForm(category: n),
            onMenu: _openMenu,
            onAddChild: inRecycle
                ? null
                : (parent) => _openForm(
                    presetType: type,
                    presetParentId: parent.categoryId,
                  ),
          ),
          const SizedBox(height: FxSpacing.sm),
        ],
      ],
    );
  }
}

/// 把 SessionCubit 的 bookId 变化派发给 Bloc。
class _BookSync extends StatefulWidget {
  final int? bookId;
  final Widget child;
  const _BookSync({required this.bookId, required this.child});

  @override
  State<_BookSync> createState() => _BookSyncState();
}

class _BookSyncState extends State<_BookSync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoriesBloc>().add(CategoriesBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<CategoriesBloc>().add(CategoriesBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
