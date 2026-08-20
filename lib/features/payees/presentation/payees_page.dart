import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/payees/data/payee_models.dart';
import 'package:fortuneboot/features/payees/data/payee_service.dart';
import 'package:fortuneboot/features/payees/presentation/bloc/payees_bloc.dart';
import 'package:fortuneboot/features/payees/presentation/widgets/payee_card.dart';
import 'package:fortuneboot/features/payees/presentation/widgets/payee_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 交易对象管理页（扁平列表，Routes.payees）。
class PayeesPage extends StatefulWidget {
  const PayeesPage({super.key});

  @override
  State<PayeesPage> createState() => _PayeesPageState();
}

class _PayeesPageState extends State<PayeesPage> {
  final PayeeService _service = PayeeService();

  PayeesBloc get _bloc => context.read<PayeesBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  void _showToast(String message) {
    FxFeedback.info(context, message: message);
  }

  Future<void> _openForm({FortunePayeeVo? payee}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).payeesSelectBookFirst);
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: payee == null ? S.of(context).payeesAdd : S.of(context).payeesEdit,
      expand: true,
      child: PayeeFormSheet(
        service: _service,
        bookId: bookId,
        payee: payee,
        onToggle: payee == null
            ? null
            : (field, value) => _bloc.add(
                PayeeToggleChanged(payee: payee, field: field, value: value),
              ),
      ),
    );
    if (changed == true && mounted) _bloc.add(const PayeesMutated());
  }

  Future<void> _openMenu(FortunePayeeVo payee) async {
    HapticFeedback.selectionClick();
    final inRecycle = _bloc.state.tab.recycleBin;
    final action = await showManageMenu(context, inRecycleBin: inRecycle);
    if (action == null || !mounted) return;
    switch (action) {
      case ManageMenuAction.edit:
        await _openForm(payee: payee);
      case ManageMenuAction.moveToRecycleBin:
        await _move(payee, toRecycle: true);
      case ManageMenuAction.putBack:
        await _move(payee, toRecycle: false);
      case ManageMenuAction.remove:
        await _remove(payee);
    }
  }

  Future<void> _move(FortunePayeeVo payee, {required bool toRecycle}) async {
    final bookId = _bookId;
    if (bookId == null || payee.payeeId == null) return;
    if (toRecycle) {
      final ok = await confirmManageAction(
        context,
        title: S.of(context).payeesMoveToRecycleBin,
        message: S
            .of(context)
            .payeesMoveToRecycleBinConfirm(
              payee.payeeName ?? S.of(context).payeesThisPayee,
            ),
        confirmLabel: S.of(context).payeesMove,
        objectName: payee.payeeName ?? S.of(context).payeesThisPayee,
      );
      if (ok != true) return;
    }
    try {
      if (toRecycle) {
        await _service.moveToRecycleBin(
          bookId: bookId,
          payeeId: payee.payeeId!,
        );
      } else {
        await _service.putBack(bookId: bookId, payeeId: payee.payeeId!);
      }
      if (mounted) _bloc.add(const PayeesMutated());
    } on Object catch (e) {
      if (!mounted) return;
      _showToast(
        e is FxApiException ? e.message : S.of(context).profileSaveFailedRetry,
      );
    }
  }

  Future<void> _remove(FortunePayeeVo payee) async {
    final bookId = _bookId;
    if (bookId == null || payee.payeeId == null) return;
    final ok = await confirmManageAction(
      context,
      title: S.of(context).payeesDeletePermanently,
      message: S
          .of(context)
          .payeesDeletePermanentlyConfirm(
            payee.payeeName ?? S.of(context).payeesThisPayee,
          ),
      confirmLabel: S.of(context).payeesDelete,
      objectName: payee.payeeName ?? S.of(context).payeesThisPayee,
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, payeeId: payee.payeeId!);
      if (mounted) _bloc.add(const PayeesMutated());
    } on Object catch (e) {
      if (!mounted) return;
      _showToast(
        e is FxApiException ? e.message : S.of(context).profileSaveFailedRetry,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );

    return _BookSync(
      bookId: bookId,
      child: BlocConsumer<PayeesBloc, PayeesState>(
        listenWhen: (p, c) =>
            c.toastMessage != null && p.toastMessage != c.toastMessage,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg != null) _showToast(msg);
        },
        builder: (context, state) {
          return ManageScaffold(
            title: S.of(context).payeesTitle,
            searchHint: S.of(context).payeesSearchHint,
            addTooltip: S.of(context).payeesAdd,
            onAdd: () => _openForm(),
            onSearch: (kw) => _bloc.add(PayeesSearchChanged(kw)),
            tab: state.tab,
            onTabChanged: (t) => _bloc.add(PayeesTabChanged(t)),
            body: _buildBody(state, bookId),
          );
        },
      ),
    );
  }

  Widget _buildBody(PayeesState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).payeesSelectBookFirst);
    }
    switch (state.status) {
      case PayeesStatus.initial:
      case PayeesStatus.loading:
        return FxStateView.loading();
      case PayeesStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          retryLabel: S.of(context).commonRetry,
          onRetry: () => _bloc.add(const PayeesLoaded()),
        );
      case PayeesStatus.empty:
      case PayeesStatus.loaded:
        return _buildList(state);
    }
  }

  Widget _buildList(PayeesState state) {
    final list = state.filtered;
    if (list.isEmpty) {
      return FxStateView.empty(
        message: S.of(context).payeesEmpty,
        icon: Icons.storefront_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const PayeesLoaded()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.lg,
          FxSpacing.sm,
          FxSpacing.lg,
          FxSpacing.xxxl,
        ),
        itemCount: list.length,
        separatorBuilder: (_, i) => const SizedBox(height: FxSpacing.sm),
        itemBuilder: (context, i) => PayeeCard(
          payee: list[i],
          onTap: () => _openForm(payee: list[i]),
          onMenu: () => _openMenu(list[i]),
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
      context.read<PayeesBloc>().add(PayeesBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<PayeesBloc>().add(PayeesBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
