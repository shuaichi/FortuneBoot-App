import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/books/presentation/widgets/destructive_confirm_sheet.dart';
import 'package:fortuneboot/features/recurring/data/cron_builder.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:fortuneboot/features/recurring/presentation/recurring_editor_page.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/cron_schedule_editor.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/recurring_log_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 周期记账规则列表页（Routes.recurring）。
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  final RecurringService _service = RecurringService();
  int? _removingRuleId;

  RecurringBloc get _bloc => context.read<RecurringBloc>();

  int? get _bookId => context.read<SessionCubit>().state.currentBookId;
  int? get _groupId => context.read<SessionCubit>().state.currentGroupId;

  void _showToast(String message) {
    FxFeedback.info(context, message: message);
  }

  Future<void> _openEditor({RecurringRuleVo? rule}) async {
    final bookId = rule?.bookId ?? _bookId;
    final groupId = _groupId;
    if (bookId == null || groupId == null) {
      _showToast(S.of(context).recurringSelectBookFirst);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        pageBuilder: (_, _, _) =>
            RecurringEditorPage(bookId: bookId, groupId: groupId, rule: rule),
      ),
    );
    if (changed == true && mounted) _bloc.add(const RecurringMutated());
  }

  Future<void> _openLogs(RecurringRuleVo rule) async {
    final bookId = rule.bookId ?? _bookId;
    if (bookId == null || rule.ruleId == null) return;
    await FxSheet.show<void>(
      context,
      title: S.of(context).recurringLogsTitle(rule.ruleName ?? ''),
      child: RecurringLogSheet(
        service: _service,
        bookId: bookId,
        ruleId: rule.ruleId!,
      ),
    );
  }

  Future<void> _remove(RecurringRuleVo rule) async {
    final bookId = rule.bookId ?? _bookId;
    if (bookId == null || rule.ruleId == null || _removingRuleId != null) {
      return;
    }
    final ok = await DestructiveConfirmSheet.show(
      context,
      title: S.of(context).recurringRemoveTitle,
      message: S
          .of(context)
          .recurringRemoveMessage(
            rule.ruleName ?? S.of(context).recurringThisRule,
          ),
      subMessage: S.of(context).confirmDestructiveWarning,
      confirmLabel: S.of(context).recurringDelete,
      cancelLabel: S.of(context).commonCancel,
    );
    if (ok != true || !mounted) return;
    setState(() => _removingRuleId = rule.ruleId);
    try {
      await _service.removeRule(bookId: bookId, ruleId: rule.ruleId!);
      if (mounted) _bloc.add(const RecurringMutated());
    } on Object {
      if (mounted) _showToast(S.of(context).profileSaveFailedRetry);
    } finally {
      if (mounted) setState(() => _removingRuleId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    final bookIds = context.select<SessionCubit, List<int>>(
      (c) => [
        for (final b in c.state.books)
          if (b.bookId != null) b.bookId!,
      ],
    );
    final bookName = context.select<SessionCubit, String?>(
      (c) => c.state.currentBook?.bookName,
    );

    return _BookSync(
      bookId: bookId,
      bookIds: bookIds,
      child: Scaffold(
        backgroundColor: FxPalette.of(context).canvas,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<RecurringBloc, RecurringState>(
            listenWhen: (prev, curr) =>
                curr.toastMessage != null &&
                prev.toastSerial != curr.toastSerial,
            listener: (context, state) {
              final msg = state.toastMessage;
              if (msg != null) _showToast(msg);
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, bookName),
                  Expanded(child: _buildBody(state, bookId)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? bookName) {
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
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).recurringTitle, style: FxTypography.title),
                if (bookName != null && bookName.isNotEmpty)
                  Text(
                    bookName,
                    style: FxTypography.caption.copyWith(
                      color: FxPalette.of(context).textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          FxIconButton(
            icon: Icons.add_rounded,
            tooltip: S.of(context).recurringAddRule,
            onPressed: () => _openEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RecurringState state, int? bookId) {
    if (bookId == null) {
      return FxStateView.empty(message: S.of(context).recurringSelectBookFirst);
    }
    switch (state.status) {
      case RecurringStatus.initial:
      case RecurringStatus.loading:
        return FxStateView.loading();
      case RecurringStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
          retryLabel: S.of(context).commonRetry,
          onRetry: () => _bloc.add(const RecurringLoaded()),
        );
      case RecurringStatus.empty:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const RecurringLoaded()),
          child: ListView(
            padding: const EdgeInsets.all(FxSpacing.lg),
            children: [
              FxStateView.empty(
                message: S.of(context).recurringEmpty,
                icon: Icons.autorenew_rounded,
                onRetry: () => _bloc.add(const RecurringLoaded()),
                retryLabel: S.of(context).commonRetry,
              ),
            ],
          ),
        );
      case RecurringStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const RecurringLoaded()),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.lg,
              FxSpacing.xxxl,
            ),
            itemCount: state.rules.length,
            itemBuilder: (context, i) =>
                _ruleCard(context, state.rules[i], state.pendingToggleIds),
          ),
        );
    }
  }

  Widget _ruleCard(
    BuildContext context,
    RecurringRuleVo rule,
    Set<int> pendingToggleIds,
  ) {
    final palette = FxPalette.of(context);
    final pending =
        rule.ruleId != null && pendingToggleIds.contains(rule.ruleId);
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: FxCard(
        accent: rule.enable ? palette.primary : palette.textTertiary,
        onTap: () => _openLogs(rule),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.autorenew_rounded, size: 18, color: palette.primary),
                const SizedBox(width: FxSpacing.xs),
                Expanded(
                  child: Text(
                    rule.ruleName ?? S.of(context).recurringUnnamedRule,
                    style: FxTypography.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch.adaptive(
                  value: rule.enable,
                  activeColor: palette.primary,
                  onChanged: pending
                      ? null
                      : (v) =>
                            _bloc.add(RecurringToggled(rule: rule, enable: v)),
                ),
                _menu(context, rule),
              ],
            ),
            const SizedBox(height: FxSpacing.xs),
            _scheduleChip(context, rule.cronExpression),
            const SizedBox(height: FxSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _meta(
                    context,
                    S.of(context).recurringNextExecution,
                    rule.nextExecutionTime ?? '-',
                  ),
                ),
                Expanded(
                  child: _meta(
                    context,
                    S.of(context).recurringExecutedLabel,
                    S
                        .of(context)
                        .recurringExecutedCount(rule.executedCount ?? 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleChip(BuildContext context, String? cron) {
    final palette = FxPalette.of(context);
    final spec = CronBuilder.tryParse(cron);
    final label = spec != null
        ? CronScheduleEditor.summarize(context, spec)
        : 'cron: ${cron ?? '-'}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FxSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: palette.primaryContainer,
        borderRadius: FxRadius.pillBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: palette.primary),
          const SizedBox(width: FxSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: FxTypography.caption.copyWith(
                color: palette.primary,
                fontFamily: spec == null ? FxTypography.monoFamily : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: FxTypography.label.copyWith(
            color: FxPalette.of(context).textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _menu(BuildContext context, RecurringRuleVo rule) {
    final palette = FxPalette.of(context);
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: palette.textSecondary),
      onSelected: _removingRuleId == null
          ? (v) {
              switch (v) {
                case 'edit':
                  _openEditor(rule: rule);
                case 'logs':
                  _openLogs(rule);
                case 'remove':
                  _remove(rule);
              }
            }
          : null,
      itemBuilder: (context) => [
        PopupMenuItem(value: 'edit', child: Text(S.of(context).recurringEdit)),
        PopupMenuItem(value: 'logs', child: Text(S.of(context).recurringLogs)),
        PopupMenuItem(
          value: 'remove',
          child: Text(
            S.of(context).recurringDelete,
            style: TextStyle(color: palette.danger),
          ),
        ),
      ],
    );
  }
}

/// 跟随 SessionCubit 账本变化重拉列表（与成员页 _BookSync 一致）。
class _BookSync extends StatefulWidget {
  final int? bookId;
  final List<int> bookIds;
  final Widget child;

  const _BookSync({
    required this.bookId,
    required this.bookIds,
    required this.child,
  });

  @override
  State<_BookSync> createState() => _BookSyncState();
}

class _BookSyncState extends State<_BookSync> {
  @override
  void didUpdateWidget(_BookSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookId != widget.bookId ||
        !_sameIds(oldWidget.bookIds, widget.bookIds)) {
      context.read<RecurringBloc>().add(
        RecurringBookChanged(bookId: widget.bookId, bookIds: widget.bookIds),
      );
    }
  }

  static bool _sameIds(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
