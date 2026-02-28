import 'package:flutter/material.dart';
import 'package:hjproject/Home/account_manage/constants/design_system.dart' as ds;
import 'package:intl/intl.dart';

/// 金额显示组件
/// 用于配合 NumberKeyboard 显示输入的金额
/// 支持光标闪烁动画
class AmountDisplay extends StatefulWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.currencySymbol = '¥',
    this.isExpense = false,
  });

  final String amount;
  final String currencySymbol;
  final bool isExpense;

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 处理金额显示格式
    String displayAmount = widget.amount;
    if (displayAmount.isEmpty) {
      displayAmount = '0.00';
    } else {
      // 如果输入为空，显示0.00；否则按输入显示
      // 这里简单处理，实际逻辑由外部控制输入的字符串格式
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ds.Spacing.xl,
        horizontal: ds.Spacing.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.currencySymbol,
                style: TextStyle(
                  fontSize: ds.FontSizes.headline,
                  height: ds.LineHeights.normal,
                  color: theme.colorScheme.onSurface,
                  fontWeight: ds.FontWeights.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayAmount,
                style: TextStyle(
                  fontSize: 48,
                  height: ds.LineHeights.tight,
                  color: widget.isExpense
                      ? ds.FinanceColors.expense
                      : ds.FinanceColors.income,
                  fontWeight: ds.FontWeights.bold,
                  letterSpacing: -1,
                ),
              ),
              // 光标
              FadeTransition(
                opacity: _cursorController,
                child: Container(
                  width: 3,
                  height: 40,
                  color: theme.colorScheme.primary,
                  margin: const EdgeInsets.only(left: 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 自定义数字键盘
/// 符合设计规范：大字体、无系统键盘
class NumberKeyboard extends StatelessWidget {
  const NumberKeyboard({
    super.key,
    required this.onTap,
    required this.onDelete,
    required this.onDone,
    this.showDone = true,
  });

  final ValueChanged<String> onTap;
  final VoidCallback onDelete;
  final VoidCallback onDone;
  final bool showDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surface;

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          _buildRow(['4', '5', '6']),
          _buildRow(['7', '8', '9']),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        _buildKey('.'),
        _buildKey('0'),
        _buildDeleteKey(context),
      ],
    );
  }

  Widget _buildKey(String text) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(text),
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDelete,
          onLongPress: onDelete, // 长按也可以连续删除，这里简单处理为单次
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}