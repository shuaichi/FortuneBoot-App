import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/data/goods_service.dart';
import 'package:fortuneboot/features/goods/presentation/bloc/goods_bloc.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_card.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_detail_sheet.dart';
import 'package:fortuneboot/features/goods/presentation/widgets/goods_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_money_text.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

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

  Future<void> _refreshGoods() {
    final completer = Completer<void>();
    _bloc.add(GoodsLoaded(completer: completer));
    return completer.future;
  }

  void _showToast(String message, {FxFeedbackTone tone = FxFeedbackTone.info}) {
    FxFeedback.show(context, message: message, tone: tone);
  }

  Future<void> _openForm({FortuneGoodsKeeperVo? goods}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(
        S.of(context).goodsSelectBookFirst,
        tone: FxFeedbackTone.warning,
      );
      return;
    }
    final formKey = GlobalKey<GoodsFormSheetState>();
    final changed = await FxSheet.show<bool>(
      context,
      title: goods == null
          ? S.of(context).goodsAddTitle
          : S.of(context).goodsEditTitle,
      expand: true,
      submitLabel: goods == null
          ? S.of(context).goodsAddTitle
          : S.of(context).goodsSaveChanges,
      onSubmit: () => formKey.currentState?.submit(),
      child: GoodsFormSheet(
        key: formKey,
        service: _service,
        bookId: bookId,
        goods: goods,
      ),
    );
    if (changed == true && mounted) _bloc.add(const GoodsMutated());
  }

  Future<void> _openDetail(FortuneGoodsKeeperVo goods) async {
    await FxSheet.show<void>(
      context,
      title: goods.goodsName ?? S.of(context).goodsDetailTitle,
      scrollable: true,
      minHeightFactor: FxSheet.hintHeightFactor,
      maxHeightFactor: FxSheet.detailHeightFactor,
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
            _menuItem(
              ctx,
              Icons.info_outline_rounded,
              S.of(ctx).goodsMenuDetail,
              'detail',
            ),
            _menuItem(
              ctx,
              Icons.edit_outlined,
              S.of(ctx).goodsMenuEdit,
              'edit',
            ),
            _menuItem(
              ctx,
              Icons.delete_outline_rounded,
              S.of(ctx).goodsMenuDelete,
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
      title: S.of(context).goodsRemoveTitle,
      message: S
          .of(context)
          .goodsRemoveConfirm(goods.goodsName ?? S.of(context).goodsThisItem),
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, keeperId: keeperId);
      if (mounted) _bloc.add(const GoodsMutated());
    } on Object catch (e) {
      _showToast(
        e is FxApiException ? e.message : e.toString(),
        tone: FxFeedbackTone.error,
      );
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
            child: Text(S.of(ctx).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              S.of(ctx).goodsMenuDelete,
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
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: S.of(context).goodsTitle,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(S.of(context).goodsTitle, style: FxTypography.title),
          ),
          FxIconButton(
            icon: Icons.add_rounded,
            tooltip: S.of(context).goodsAddTitle,
            onPressed: () => _openForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(GoodsState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).goodsSelectBookFirst);
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
          onRefresh: _refreshGoods,
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
                height:
                    MediaQuery.of(context).size.height *
                    FxSheet.mediumHeightFactor,
                child: FxStateView.empty(
                  message: S.of(context).goodsEmptyHint,
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
    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
        ? 3
        : width >= 360
        ? 2
        : 1;
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    return RefreshIndicator(
      onRefresh: _refreshGoods,
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
                  masked: hideAmounts,
                  onTap: () => _openDetail(goods),
                  onMenu: () => _openMenu(goods),
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
    final hideAmounts = context
        .watch<PreferencesCubit>()
        .state
        .dashboard
        .hideAmounts;
    return FxCard(
      child: Row(
        children: [
          _cell(
            context,
            S.of(context).goodsStatAllCost,
            stats.allPrice,
            palette.textPrimary,
            hideAmounts,
          ),
          _divider(context),
          _cell(
            context,
            S.of(context).goodsStatActiveCost,
            stats.activePrice,
            palette.primary,
            hideAmounts,
          ),
          _divider(context),
          _cell(
            context,
            S.of(context).goodsStatDailyCost,
            stats.allDailyPrice,
            FxFinanceColors.of(context).income,
            hideAmounts,
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 32, color: FxPalette.of(context).border);

  Widget _cell(
    BuildContext context,
    String label,
    double amount,
    Color color,
    bool hideAmounts,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: FxTypography.caption.copyWith(
              color: FxPalette.of(context).textTertiary,
            ),
          ),
          const SizedBox(height: FxSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: FxMoneyText(
              amount: amount,
              currencyCode: currencyCode,
              fontSize: 15,
              color: color,
              masked: hideAmounts,
            ),
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
