import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/manage_shared/manage_menu.dart';
import 'package:fortuneboot/features/manage_shared/manage_scaffold.dart';
import 'package:fortuneboot/features/members/data/member_models.dart';
import 'package:fortuneboot/features/members/data/member_service.dart';
import 'package:fortuneboot/features/members/presentation/bloc/members_bloc.dart';
import 'package:fortuneboot/features/members/presentation/widgets/member_card.dart';
import 'package:fortuneboot/features/members/presentation/widgets/member_form_sheet.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 成员管理页（扁平列表，Routes.members）。
class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final MemberService _service = MemberService();

  MembersBloc get _bloc => context.read<MembersBloc>();
  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm({FortuneMemberVo? member}) async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).membersSelectBookFirst);
      return;
    }
    final changed = await FxSheet.show<bool>(
      context,
      title: member == null
          ? S.of(context).membersAdd
          : S.of(context).membersEdit,
      expand: true,
      child: MemberFormSheet(service: _service, bookId: bookId, member: member),
    );
    if (changed == true && mounted) _bloc.add(const MembersMutated());
  }

  Future<void> _openMenu(FortuneMemberVo member) async {
    HapticFeedback.selectionClick();
    final inRecycle = _bloc.state.tab.recycleBin;
    final action = await showManageMenu(context, inRecycleBin: inRecycle);
    if (action == null || !mounted) return;
    switch (action) {
      case ManageMenuAction.edit:
        await _openForm(member: member);
      case ManageMenuAction.moveToRecycleBin:
        await _move(member, toRecycle: true);
      case ManageMenuAction.putBack:
        await _move(member, toRecycle: false);
      case ManageMenuAction.remove:
        await _remove(member);
    }
  }

  Future<void> _move(FortuneMemberVo member, {required bool toRecycle}) async {
    final bookId = _bookId;
    if (bookId == null || member.memberId == null) return;
    if (toRecycle) {
      final ok = await confirmManageAction(
        context,
        title: S.of(context).membersMoveToRecycleBin,
        message: S.of(context).membersMoveToRecycleBinConfirm(
          member.memberName ?? S.of(context).membersThisMember,
        ),
        confirmLabel: S.of(context).membersMove,
      );
      if (ok != true) return;
    }
    try {
      if (toRecycle) {
        await _service.moveToRecycleBin(
          bookId: bookId,
          memberId: member.memberId!,
        );
      } else {
        await _service.putBack(bookId: bookId, memberId: member.memberId!);
      }
      if (mounted) _bloc.add(const MembersMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  Future<void> _remove(FortuneMemberVo member) async {
    final bookId = _bookId;
    if (bookId == null || member.memberId == null) return;
    final ok = await confirmManageAction(
      context,
      title: S.of(context).membersDeletePermanently,
      message: S.of(context).membersDeletePermanentlyConfirm(
        member.memberName ?? S.of(context).membersThisMember,
      ),
      confirmLabel: S.of(context).membersDelete,
    );
    if (ok != true) return;
    try {
      await _service.remove(bookId: bookId, memberId: member.memberId!);
      if (mounted) _bloc.add(const MembersMutated());
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
      child: BlocConsumer<MembersBloc, MembersState>(
        listenWhen: (p, c) =>
            c.toastMessage != null && p.toastMessage != c.toastMessage,
        listener: (context, state) {
          final msg = state.toastMessage;
          if (msg != null) _showToast(msg);
        },
        builder: (context, state) {
          return ManageScaffold(
            title: S.of(context).membersTitle,
            searchHint: S.of(context).membersSearchHint,
            onAdd: () => _openForm(),
            onSearch: (kw) => _bloc.add(MembersSearchChanged(kw)),
            tab: state.tab,
            onTabChanged: (t) => _bloc.add(MembersTabChanged(t)),
            body: _buildBody(state, bookId),
          );
        },
      ),
    );
  }

  Widget _buildBody(MembersState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).membersSelectBookFirst);
    }
    switch (state.status) {
      case MembersStatus.initial:
      case MembersStatus.loading:
        return FxStateView.loading();
      case MembersStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          onRetry: () => _bloc.add(const MembersLoaded()),
        );
      case MembersStatus.empty:
      case MembersStatus.loaded:
        return _buildList(state);
    }
  }

  Widget _buildList(MembersState state) {
    final list = state.filtered;
    if (list.isEmpty) {
      return FxStateView.empty(
        message: S.of(context).membersEmpty,
        icon: Icons.people_outline_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _bloc.add(const MembersLoaded()),
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
        itemBuilder: (context, i) => MemberCard(
          member: list[i],
          onTap: () => _openForm(member: list[i]),
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
      context.read<MembersBloc>().add(MembersBookChanged(widget.bookId));
    });
  }

  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId) {
      context.read<MembersBloc>().add(MembersBookChanged(widget.bookId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
