import 'package:flutter/material.dart';
import 'package:hjproject/home/theme/theme.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/util/app_icon.dart';
import 'package:intl/intl.dart';

class BillListTile extends StatelessWidget {
  const BillListTile({
    required this.bill,
    super.key,
    this.onToggleCompleted,
    this.onDismissed,
    this.onCopy,
    this.onTap,
  });

  final BillItem bill;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final Function? onCopy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 获取分类名称
    String categoryName = '';
    if (bill.categoryAmountPair != null &&
        bill.categoryAmountPair!.isNotEmpty) {
      categoryName = bill.categoryAmountPair!
          .map((cat) => cat.categoryName ?? '')
          .where((name) => name.isNotEmpty)
          .join(', ');
    }

    // 构建标题
    String title = bill.title ?? '';
    if (title.isEmpty && categoryName.isNotEmpty) {
      title = categoryName;
    } else if (categoryName.isNotEmpty) {
      title = '$categoryName - $title';
    }

    // 格式化时间（只显示小时和分钟，更符合中国用户习惯）
    DateFormat formatter = DateFormat('HH:mm');
    String formattedTime = formatter.format(bill.tradeTime ?? DateTime.now());

    // 根据账单类型设置颜色和图标
    Color? billColor;
    IconData? billIcon;
    Map<String, dynamic>? categoryIcon;

    // 设置账单类型颜色和图标
    switch (bill.billType) {
      case BillType.expenditure:
        billColor =
            Theme.of(context).extension<CustomColors>()!.expenseTextColor ??
                Colors.red;
        billIcon = Icons.arrow_upward;
        break;
      case BillType.income:
        billColor =
            Theme.of(context).extension<CustomColors>()!.incomeTextColor ??
                Colors.green;
        billIcon = Icons.arrow_downward;
        break;
      case BillType.transfer:
        billColor =
            Theme.of(context).extension<CustomColors>()!.transferTextColor ??
                Colors.blue;
        billIcon = Icons.swap_horiz;
        break;
      case BillType.adjust:
        billColor =
            Theme.of(context).extension<CustomColors>()!.adjustTextColor ??
                Colors.orange;
        billIcon = Icons.settings;
        break;
      case BillType.advance:
        billColor = Colors.purple;
        billIcon = Icons.payment;
        break;
      case BillType.reimburse:
        billColor = Colors.teal;
        billIcon = Icons.receipt;
        break;

      case null:
        billColor = Colors.grey;
        billIcon = Icons.help_outline;
        break;
    }

    // 根据分类设置图标（优先使用用户自定义图标，未设置时回退到内置关键字猜测）
    IconData? customCategoryIcon;
    if (bill.categoryAmountPair != null && bill.categoryAmountPair!.isNotEmpty) {
      for (final pair in bill.categoryAmountPair!) {
        final resolved = AppIcon.resolve(pair.icon);
        if (resolved != null) {
          customCategoryIcon = resolved;
          break;
        }
      }
    }

    if (categoryName.isNotEmpty) {
      if (categoryName.contains('餐饮') ||
          categoryName.contains('吃') ||
          categoryName.contains('食品')) {
        categoryIcon = {'icon': Icons.restaurant, 'color': Colors.orange};
      } else if (categoryName.contains('交通') || categoryName.contains('车')) {
        categoryIcon = {'icon': Icons.directions_car, 'color': Colors.blue};
      } else if (categoryName.contains('购物') || categoryName.contains('服装')) {
        categoryIcon = {'icon': Icons.shopping_bag, 'color': Colors.purple};
      } else if (categoryName.contains('娱乐') || categoryName.contains('电影')) {
        categoryIcon = {'icon': Icons.movie, 'color': Colors.pink};
      } else if (categoryName.contains('住房') || categoryName.contains('房租')) {
        categoryIcon = {'icon': Icons.home, 'color': Colors.brown};
      } else if (categoryName.contains('工资') || categoryName.contains('收入')) {
        categoryIcon = {
          'icon': Icons.account_balance_wallet,
          'color': Colors.green
        };
      } else if (categoryName.contains('医疗') || categoryName.contains('药')) {
        categoryIcon = {'icon': Icons.local_hospital, 'color': Colors.red};
      } else if (categoryName.contains('教育') || categoryName.contains('学习')) {
        categoryIcon = {'icon': Icons.school, 'color': Colors.indigo};
      }
    }

    // 格式化金额，确保显示两位小数
    String amountText = '¥${(bill.convertedAmount ?? 0).toStringAsFixed(2)}';
    // if (bill.billType == BillType.expenditure) {
    //   amountText = '-$amountText';
    // } else if (bill.billType == BillType.income) {
    //   amountText = '+$amountText';
    // }

    // 构建卡片
    var card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 左侧图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (categoryIcon?['color'] as Color? ?? billColor)
                      ?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  customCategoryIcon ??
                      (categoryIcon?['icon'] as IconData?) ??
                      billIcon,
                  color: customCategoryIcon != null
                      ? billColor
                      : (categoryIcon?['color'] as Color? ?? billColor),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 中间内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 账户名称
                        if (bill.accountName != null &&
                            bill.accountName!.isNotEmpty) ...[
                          Icon(
                            AppIcon.resolve(bill.accountIcon) ??
                                Icons.account_balance,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bill.accountName!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // 账单类型
                        Text(
                          bill.billType?.title ?? '',
                          style: TextStyle(
                            color: billColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 时间
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        // 备注图标
                        if (bill.remark != null && bill.remark!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.comment,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 右侧金额
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: billColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );

    // 启用左滑删除功能
    return Dismissible(
      key: Key('billListTile_dismissible_${bill.billId}'),
      onDismissed: onDismissed,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        // 添加确认对话框，防止误删
        if (direction == DismissDirection.endToStart) {
          if (onDismissed != null) {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text('确定要删除这条账单记录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('删除',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ) ??
                false;
          }
        } else if (direction == DismissDirection.startToEnd) {
          // 余额调整账单不允许复制：直接提示并阻断
          if (bill.billType == BillType.adjust) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('余额调整账单不支持复制或编辑')),
            );
            return false;
          }
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('是否复制'),
              content: const Text('确定要复制这条账单记录吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    onCopy?.call();
                  },
                  child: const Text('复制', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          );
          return false;
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        color: theme.colorScheme.inversePrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.copy,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: card,
    );
  }
}
