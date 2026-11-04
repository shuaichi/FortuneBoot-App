import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/recurring/data/recurring_models.dart';
import 'package:fortuneboot/features/recurring/data/recurring_service.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 规则执行日志（在 FxSheet 内展示）。
class RecurringLogSheet extends StatefulWidget {
  final RecurringService service;
  final int bookId;
  final int ruleId;

  const RecurringLogSheet({
    super.key,
    required this.service,
    required this.bookId,
    required this.ruleId,
  });

  @override
  State<RecurringLogSheet> createState() => _RecurringLogSheetState();
}

class _RecurringLogSheetState extends State<RecurringLogSheet> {
  bool _loading = true;
  String? _error;
  List<RecurringLogVo> _logs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final logs = await widget.service.getLogs(
        bookId: widget.bookId,
        ruleId: widget.ruleId,
      );
      if (mounted) {
        setState(() {
          _logs = logs;
          _loading = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_loading) return FxStateView.loading();
    if (_error != null) {
      return FxStateView.error(message: _error, onRetry: _load);
    }
    if (_logs.isEmpty) {
      return FxStateView.empty(
        message: S.of(context).recurringNoLogs,
        icon: Icons.history_rounded,
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      itemCount: _logs.length,
      itemBuilder: (context, i) => _tile(context, _logs[i]),
    );
  }

  Widget _tile(BuildContext context, RecurringLogVo log) {
    final palette = FxPalette.of(context);
    final isError =
        (log.errorMsg != null && log.errorMsg!.isNotEmpty) ||
        (log.status != null &&
            (log.status!.toLowerCase().contains('fail') ||
                log.status!.contains('失败')));
    final statusColor = isError ? palette.danger : palette.success;
    return Container(
      margin: const EdgeInsets.only(bottom: FxSpacing.sm),
      padding: const EdgeInsets.all(FxSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: FxRadius.tileBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Text(
                  log.executionTime ?? '-',
                  style: FxTypography.bodyStrong,
                ),
              ),
              if (log.status != null)
                Text(
                  log.status!,
                  style: FxTypography.caption.copyWith(color: statusColor),
                ),
            ],
          ),
          const SizedBox(height: FxSpacing.xs),
          Wrap(
            spacing: FxSpacing.md,
            children: [
              if (log.billId != null)
                Text(
                  S.of(context).recurringLogBillId(log.billId!),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
              if (log.executionDuration != null)
                Text(
                  S.of(context).recurringLogDuration(log.executionDuration!),
                  style: FxTypography.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
            ],
          ),
          if (log.errorMsg != null && log.errorMsg!.isNotEmpty) ...[
            const SizedBox(height: FxSpacing.xs),
            Text(
              log.errorMsg!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
        ],
      ),
    );
  }
}
