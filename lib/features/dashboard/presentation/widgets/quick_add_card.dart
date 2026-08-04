import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fortuneboot/core/navigation/app_router.dart';
import 'package:fortuneboot/core/navigation/routes.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// ⑥ 快捷记账卡：大 "+"，点击跳记账表单。[enlarged] 时用于空态引导放大。
class QuickAddCard extends StatelessWidget {
  final bool enlarged;
  const QuickAddCard({super.key, this.enlarged = false});

  @override
  Widget build(BuildContext context) {
    return FxCard(
      background: FxPalette.of(context).primary,
      onTap: () {
        HapticFeedback.selectionClick();
        AppRouter.push<void>(context, Routes.billEditor);
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: enlarged ? 44 : 34,
            ),
            const SizedBox(height: FxSpacing.xs),
            Text(
              S.of(context).dashboardQuickAdd,
              style: FxTypography.bodyStrong.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
