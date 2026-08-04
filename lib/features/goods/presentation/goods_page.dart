import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/data/goods_service.dart';
import 'package:fortuneboot/features/goods/presentation/bloc/goods_bloc.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_card.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_detail_sheet.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 归物列表页（Routes.goods）。顶部统计条 + 卡片网格。
class GoodsPage extends StatefulWidget {
  const GoodsPage({super.key});

  @override
  State<GoodsPage> createState() => _GoodsPageState();
}

class _GoodsPageState extends State<GoodsPage> {
  final GoodsService _service = GoodsService();

  GoodsBloc get _bloc => context.read<GoodsBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;
  String? get _currency => context.read<SessionCubit>().state.defaultCurrency;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({FortuneGoodsKeeperVo? goods}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: goods == null ? '添加物品' : '编辑物品',
      expand: true,
      child: GoodsFormSheet(service: _service, bookId: bookId, goods: goods),
    );
    if (changed == true && mounted) _bloc.add(const GoodsMutated());
  }

  Future<void> _openDetail(FortuneGoodsKeeperVo goods) async {
    await FxSheet.show<void>(
      context,
      title: goods.goodsName ?? '物品详情',
      expand: true,
      child: GoodsDetailSheet(goods: goods, currencyCode: _currency),
    );
  }

  Future<void> _openMenu(FortuneGoodsKeeperVo goods) async {
    HapticFeedback.selectionClick();
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: FxPalette.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: FxRadius.sheetRadius),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(ctx, Icons.info_outline_rounded, '查看详情', 'detail'),
            _menuItem(ctx, Icons.edit_outlined, '编辑', 'edit'),
            _menuItem(
              ctx,
              Icons.delete_outline_rounded,
              '删除',
              'remove',
              danger: true,
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'detail':
        await _openDetail(goods);
      case 'edit':
        await _openForm(goods: goods);
      case 'remove':
        await _remove(goods);
    }
  }

  Widget _menuItem(
    BuildContext ctx,
    IconData icon,
    String label,
    String value, {
    bool danger = false,
  }) {
    final palette = FxPalette.of(ctx);
    final color = danger ? palette.danger : palette.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: FxTypography.body.copyWith(color: color)),
      onTap: () => Navigator.of(ctx).pop(value),
    );
  }

  Future<void> _remove(FortuneGoodsKeeperVo goods) async {
    final bookId = _bookId;
    final keeperId = goods.goodsKeeperId;
    if (bookId == null || keeperId == null) return;
    final ok = await _confirm(
      title: '删除物品',
      message: '确定删除「${goods.goodsName ?? '该物品'}」吗？此操作不可撤销。',
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, keeperId: keeperId);
      if (mounted) _bloc.add(const GoodsMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<bool?> _confirm({required String title, required String message}) {
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
            child: Text(
              '删除',
              style: TextStyle(color: FxPalette.of(ctx).danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    return _BookSync(
      bookId: bookId,
      child: Scaffold(
        backgroundColor: FxPalette.of(context).canvas,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<GoodsBloc, GoodsState>(
            listenWhen: (p, c) =>
                c.toastMessage != null && p.toastMessage != c.toastMessage,
            listener: (context, state) {
              final msg = state.toastMessage;
              if (msg != null) _showToast(msg);
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state, bookId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          _iconButton(
            Icons.chevron_left_rounded,
            () => Navigator.of(context).maybePop(),
          ),
          const Expanded(child: Text('归物', style: FxTypography.title)),
          _iconButton(Icons.add_rounded, () => _openForm()),
        ],
      ),
    );
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

  Widget _buildBody(GoodsState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: '请先选择账本');
    }
    switch (state.status) {
      case GoodsViewStatus.initial:
      case GoodsViewStatus.loading:
        return FxStateView.loading();
      case GoodsViewStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const GoodsLoaded()),
        );
      case GoodsViewStatus.empty:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const GoodsLoaded()),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(FxSpacing.lg),
                child: _StatBar(
                  stats: state.statistics,
                  currencyCode: state.currencyCode,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: FxStateView.empty(
                  message: '暂无物品，点击右上角 + 添加',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
        );
      case GoodsViewStatus.loaded:
        return _buildGrid(state);
    }
  }

  Widget _buildGrid(GoodsState state) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const GoodsLoaded()),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: _StatBar(
                stats: state.statistics,
                currencyCode: state.currencyCode,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.xs,
              FxSpacing.lg,
              FxSpacing.xxxl,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: FxSpacing.md,
                crossAxisSpacing: FxSpacing.md,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                final goods = state.goods[i];
                return GoodsCard(
                  goods: goods,
                  currencyCode: state.currencyCode,
                  onTap: () => _openDetail(goods),
                  onLongPress: () => _openMenu(goods),
                );
              }, childCount: state.goods.length),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部统计条：全部成本 / 在役成本 / 日均。
class _StatBar extends StatelessWidget {
  final GoodsStatistics stats;
  final String? currencyCode;

  const _StatBar({required this.stats, this.currencyCode});

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return FxCard(
      child: Row(
        children: [
          _cell(context, '全部成本', stats.allPrice, palette.textPrimary),
          _divider(context),
          _cell(context, '在役成本', stats.activePrice, palette.primary),
          _divider(context),
          _cell(
            context,
            '日均成本',
            stats.allDailyPrice,
            FxFinanceColors.of(context).income,
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 32, color: FxPalette.of(context).border);

  Widget _cell(BuildContext context, String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: FxTypography.caption),
          const SizedBox(height: FxSpacing.xs),
          FxMoneyText(
            amount: amount,
            currencyCode: currencyCode,
            fontSize: 15,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// 把 SessionCubit 的 bookId 变化派发给 GoodsBloc。
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
      context.read<GoodsBloc>().add(GoodsBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<GoodsBloc>().add(GoodsBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
