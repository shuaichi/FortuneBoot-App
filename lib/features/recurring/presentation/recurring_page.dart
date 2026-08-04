import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:fortuneboot/features/recurring/presentation/recurring_editor_page.dart';
import 'package:fortuneboot/features/recurring/presentation/widgets/recurring_log_sheet.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 周期记账规则列表页（Routes.recurring）。
class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  final RecurringService _service = RecurringService();

  RecurringBloc get _bloc => context.read<RecurringBloc>();

  int? get _bookId => context.read<SessionCubit>().state.currentBookId;
  int? get _groupId => context.read<SessionCubit>().state.currentGroupId;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditor({RecurringRuleVo? rule}) async {
    final bookId = _bookId;
    final groupId = _groupId;
    if (bookId == null || groupId == null) {
      _showToast('请先选择账本');
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecurringEditorPage(
          bookId: bookId,
          groupId: groupId,
          rule: rule,
        ),
      ),
    );
    if (changed == true && mounted) _bloc.add(const RecurringMutated());
  }

  Future<void> _openLogs(RecurringRuleVo rule) async {
    final bookId = _bookId;
    if (bookId == null || rule.ruleId == null) return;
    await FxSheet.show<void>(
      context,
      title: '执行日志 · ${rule.ruleName ?? ''}',
      child: RecurringLogSheet(
        service: _service,
        bookId: bookId,
        ruleId: rule.ruleId!,
      ),
    );
  }

  Future<void> _remove(RecurringRuleVo rule) async {
    final bookId = _bookId;
    if (bookId == null || rule.ruleId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除规则'),
        content: Text('确定删除「${rule.ruleName ?? '该规则'}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: FxColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _service.removeRule(bookId: bookId, ruleId: rule.ruleId!);
      if (mounted) _bloc.add(const RecurringMutated());
    } on Object catch (e) {
      _showToast(e is FxApiException ? e.message : e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FxColors.canvas,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<RecurringBloc, RecurringState>(
          listenWhen: (prev, curr) =>
              curr.toastMessage != null &&
              prev.toastMessage != curr.toastMessage,
          listener: (context, state) {
            final msg = state.toastMessage;
            if (msg != null) _showToast(msg);
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody(state)),
              ],
            );
          },
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
          InkResponse(
            onTap: () => Navigator.of(context).maybePop(),
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(FxSpacing.xs),
              child: Icon(Icons.chevron_left_rounded,
                  size: 26, color: FxColors.textPrimary),
            ),
          ),
          const Expanded(child: Text('周期记账', style: FxTypography.title)),
          InkResponse(
            onTap: () => _openEditor(),
            radius: 22,
            child: const Padding(
              padding: EdgeInsets.all(FxSpacing.xs),
              child: Icon(Icons.add_rounded, size: 26, color: FxColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RecurringState state) {
    if (_bookId == null) {
      return FxStateView.empty(message: '请先选择账本');
    }
    switch (state.status) {
      case RecurringStatus.initial:
      case RecurringStatus.loading:
        return FxStateView.loading();
      case RecurringStatus.error:
        return FxStateView.error(
          message: state.errorMessage,
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
                  message: '暂无周期规则，点击右上角 + 新增',
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
            itemBuilder: (context, i) => _ruleCard(state.rules[i]),
          ),
        );
    }
  }

  Widget _ruleCard(RecurringRuleVo rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: FxCard(
        accent: rule.enable ? FxColors.primary : FxColors.textTertiary,
        onTap: () => _openLogs(rule),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.autorenew_rounded,
                    size: 18, color: FxColors.primary),
                const SizedBox(width: FxSpacing.xs),
                Expanded(
                  child: Text(
                    rule.ruleName ?? '未命名规则',
                    style: FxTypography.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch.adaptive(
                  value: rule.enable,
                  activeColor: FxColors.primary,
                  onChanged: (v) =>
                      _bloc.add(RecurringToggled(rule: rule, enable: v)),
                ),
                _menu(rule),
              ],
            ),
            const SizedBox(height: FxSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FxSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: FxColors.surfaceMuted,
                borderRadius: FxRadius.pillBorder,
              ),
              child: Text(
                'cron: ${rule.cronExpression ?? '-'}',
                style: FxTypography.caption.copyWith(
                  fontFamily: FxTypography.monoFamily,
                ),
              ),
            ),
            const SizedBox(height: FxSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _meta(
                    '下次执行',
                    rule.nextExecutionTime ?? '-',
                  ),
                ),
                Expanded(
                  child: _meta(
                    '已执行',
                    '${rule.executedCount ?? 0} 次',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FxTypography.caption),
        const SizedBox(height: 2),
        Text(
          value,
          style: FxTypography.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _menu(RecurringRuleVo rule) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: FxColors.textSecondary),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            _openEditor(rule: rule);
          case 'logs':
            _openLogs(rule);
          case 'remove':
            _remove(rule);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('编辑')),
        PopupMenuItem(value: 'logs', child: Text('执行日志')),
        PopupMenuItem(
          value: 'remove',
          child: Text('删除', style: TextStyle(color: FxColors.danger)),
        ),
      ],
    );
  }
}
