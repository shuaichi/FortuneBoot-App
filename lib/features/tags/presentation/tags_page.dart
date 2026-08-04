import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/tags/data/tag_models.dart';
import 'package:fortuneboot/features/tags/data/tag_service.dart';
import 'package:fortuneboot/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:fortuneboot/features/tags/presentation/widgets/tag_form_sheet.dart';
import 'package:fortuneboot/features/tags/presentation/widgets/tag_tile.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';

/// 标签管理页（树形，Routes.tags）。
class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  final TagService _service = TagService();

  TagsBloc get _bloc => context.read<TagsBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 展平树以供父级选择。
  List<FortuneTagVo> _flatten(List<FortuneTagVo> nodes) {
    final result = <FortuneTagVo>[];
    for (final n in nodes) {
      result.add(n);
      result.addAll(_flatten(n.children));
    }
    return result;
  }

  Future<void> _openForm({FortuneTagVo? tag, int? presetParentId}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: tag == null ? '新增标签' : '编辑标签',
      expand: true,
      child: TagFormSheet(
        service: _service,
        bookId: bookId,
        flatTags: _flatten(_bloc.state.tree),
        tag: tag,
        presetParentId: presetParentId,
        onToggle: tag == null
            ? null
            : (field, value) => _bloc.add(
                TagToggleChanged(tag: tag, field: field, value: value),
              ),
      ),
    );
    if (changed == true && mounted) _bloc.add(const TagsMutated());
  }

  Future<void> _openMenu(FortuneTagVo node) async {
    HapticFeedback.selectionClick();
    final inRecycle = _bloc.state.tab.recycleBin;
    final action = await showManageMenu(context, inRecycleBin: inRecycle);
    if (action == null || !mounted) return;
    switch (action) {
      case ManageMenuAction.edit:
        await _openForm(tag: node);
      case ManageMenuAction.moveToRecycleBin:
        await _move(node, toRecycle: true);
      case ManageMenuAction.putBack:
        await _move(node, toRecycle: false);
      case ManageMenuAction.remove:
        await _remove(node);
    }
  }

  Future<void> _move(FortuneTagVo node, {required bool toRecycle}) async {
    final bookId = _bookId;
    if (bookId == null || node.tagId == null) return;
    if (toRecycle) {
      final ok = await confirmManageAction(
        context,
        title: '移入回收站',
        message: '确定将「${node.tagName ?? '该标签'}」移入回收站吗？',
        confirmLabel: '移入',
      );
      if (ok != true) return;
    }
    try {
      if (toRecycle) {
        await _service.moveToRecycleBin(bookId: bookId, tagId: node.tagId!);
      } else {
        await _service.putBack(bookId: bookId, tagId: node.tagId!);
      }
      if (mounted) _bloc.add(const TagsMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<void> _remove(FortuneTagVo node) async {
    final bookId = _bookId;
    if (bookId == null || node.tagId == null) return;
    final ok = await confirmManageAction(
      context,
      title: '彻底删除',
      message: '确定彻底删除「${node.tagName ?? '该标签'}」吗？此操作不可撤销。',
      confirmLabel: '删除',
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, tagId: node.tagId!);
      if (mounted) _bloc.add(const TagsMutated());
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
      child: BlocConsumer<TagsBloc, TagsState>(
        listenWhen: (p, c) =>
            c.toastMessage != null && p.toastMessage != c.toastMessage,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg != null) _showToast(msg);
        },
        builder: (context, state) {
          return ManageScaffold(
            title: '标签管理',
            searchHint: '搜索标签名称',
            onAdd: () => _openForm(),
            onSearch: (kw) => _bloc.add(TagsSearchChanged(kw)),
            tab: state.tab,
            onTabChanged: (t) => _bloc.add(TagsTabChanged(t)),
            body: _buildBody(state, bookId),
          );
        },
      ),
    );
  }

  Widget _buildBody(TagsState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: '请先选择账本');
    }
    switch (state.status) {
      case TagsStatus.initial:
      case TagsStatus.loading:
        return FxStateView.loading();
      case TagsStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const TagsLoaded()),
        );
      case TagsStatus.empty:
      case TagsStatus.loaded:
        return _buildTree(state);
    }
  }

  Widget _buildTree(TagsState state) {
    final roots = state.filtered;
    if (roots.isEmpty) {
      return FxStateView.empty(
        message: '暂无标签，点击右上角 + 新增',
        icon: Icons.sell_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const TagsLoaded()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.sm,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        itemCount: roots.length,
        separatorBuilder: (_, i) => const SizedBox(height: FxSpacing.sm),
        itemBuilder: (context, i) => TagTile(
          node: roots[i],
          onTap: (n) => _openForm(tag: n),
          onMenu: _openMenu,
        ),
      ),
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
      context.read<TagsBloc>().add(TagsBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<TagsBloc>().add(TagsBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
