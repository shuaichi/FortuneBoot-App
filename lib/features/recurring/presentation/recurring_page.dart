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
    final bookId = _bookId;
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
    final bookId = _bookId;
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
    final bookId = _bookId;
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
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<RecurringBloc, RecurringState>(
          listenWhen: (prev, curr) =>
              curr.toastMessage != null && prev.toastSerial != curr.toastSerial,
          listener: (context, state) {
            final msg = state.toastMessage;
            if (msg != null) _showToast(msg);
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildBody(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            child: Text(
              S.of(context).recurringTitle,
              style: FxTypography.title,
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

  Widget _buildBody(RecurringState state) {
    if (_bookId == null) {
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
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: FxStateView.empty(
                  message: S.of(context).recurringEmpty,
                  icon: Icons.autorenew_rounded,
                ),
              ),
            ],
          ),
        );
      case RecurringStatus.loaded:
        return RefreshIndicator(
          onRefresh: () async => _bloc.add(const RecurringLoaded()),
          child: ListView.builder(
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

  /// 调度摘要芯片：优先展示可视化人类可读描述，无法解析时回退原始 cron。
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
