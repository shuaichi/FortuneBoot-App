import 'package:flutter/material.dart';
import 'package:fortuneboot/core/preferences/finance_color_preferences.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

/// 账单颜色自定义编辑器：为每个语义色提供预设色板选择 + 恢复默认。
class FinanceColorEditor extends StatefulWidget {
  final PreferencesCubit cubit;
  const FinanceColorEditor({super.key, required this.cubit});

  @override
  State<FinanceColorEditor> createState() => _FinanceColorEditorState();
}

class _FinanceColorEditorState extends State<FinanceColorEditor> {
  late FinanceColorPreferences _draft = widget.cubit.state.financeColors;
  bool _saving = false;

  /// 预设色板，覆盖亮暗两色都有足够对比度的常用色。
  static const List<int> _swatches = [
    0xFF16A34A, // green
    0xFF059669, // emerald
    0xFF0EA5E9, // sky
    0xFF0066FF, // blue
    0xFF7C3AED, // violet
    0xFFDB2777, // pink
    0xFFEF4444, // red
    0xFFF97316, // orange
    0xFFF59E0B, // amber
    0xFF64748B, // slate
  ];

  void _update(FinanceColorPreferences next) {
    setState(() => _draft = next);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.cubit.setFinanceColors(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('保存失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('收入', _draft.income, (c) => _update(_draft.copyWith(income: c))),
          _row(
            '支出',
            _draft.expense,
            (c) => _update(_draft.copyWith(expense: c)),
          ),
          _row(
            '转账',
            _draft.transfer,
            (c) => _update(_draft.copyWith(transfer: c)),
          ),
          _row('调整', _draft.adjust, (c) => _update(_draft.copyWith(adjust: c))),
          _row(
            '垫付',
            _draft.advance,
            (c) => _update(_draft.copyWith(advance: c)),
          ),
          _row(
            '报销',
            _draft.reimburse,
            (c) => _update(_draft.copyWith(reimburse: c)),
          ),
          const SizedBox(height: FxSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FxButton.text(
                  label: '恢复默认',
                  expand: true,
                  onPressed: _saving
                      ? null
                      : () => _update(FinanceColorPreferences.defaults()),
                ),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: FxButton(
                  label: '保存',
                  expand: true,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int current, ValueChanged<int> onPick) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FxSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Color(current),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: FxSpacing.sm),
              Text(
                label,
                style: FxTypography.label.copyWith(color: palette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Wrap(
            spacing: FxSpacing.sm,
            runSpacing: FxSpacing.sm,
            children: [
              for (final s in _swatches)
                GestureDetector(
                  onTap: () => onPick(Color(s).toARGB32()),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(s),
                      borderRadius: FxRadius.tileBorder,
                      border: Border.all(
                        color: current == Color(s).toARGB32()
                            ? palette.textPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: current == Color(s).toARGB32()
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
