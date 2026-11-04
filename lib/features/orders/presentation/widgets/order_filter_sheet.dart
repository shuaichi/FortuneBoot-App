import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/orders/data/orders_models.dart';
import 'package:fortuneboot/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 单据次级筛选：生命周期状态与逾期条件，不长期占用列表首屏。
class OrderFilterSheet extends StatelessWidget {
  const OrderFilterSheet({super.key, required this.state});

  final OrdersState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final strings = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '状态',
            style: FxTypography.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: FxSpacing.sm),
          FxSegmented<int>(
            value: state.statusFilter,
            onChanged: (status) => context.read<OrdersBloc>().add(
              OrdersStatusFilterChanged(status),
            ),
            segments: [
              FxSegment(
                FinanceOrderStatus.using.value,
                strings.ordersStatusUsing,
              ),
              FxSegment(
                FinanceOrderStatus.draft.value,
                strings.ordersStatusDraft,
              ),
              FxSegment(
                FinanceOrderStatus.closed.value,
                strings.ordersStatusClosed,
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.ordersOverdueOnly,
                  style: FxTypography.body.copyWith(color: palette.textPrimary),
                ),
              ),
              Switch(
                key: const ValueKey('orders-overdue-only'),
                value: state.overdueOnly,
                onChanged: (value) => context.read<OrdersBloc>().add(
                  OrdersOverdueOnlyChanged(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
