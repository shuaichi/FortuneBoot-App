import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/view/edit_bill_page.dart';
import 'package:hjproject/home/theme/theme.dart';
import 'package:hjproject/home/bill_overview/bloc/bills_overview_bloc.dart';
import 'package:hjproject/home/bill_overview/bloc/detail_bloc/bill_detail_bloc.dart';
import 'package:hjproject/util/app_icon.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:intl/intl.dart';

class BillDetailSheet extends StatelessWidget {
  BillDetailSheet({super.key, required this.billItem, this.deleteBk});
  BillItem billItem;
  VoidCallback? deleteBk;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillDetailBloc(
        initialBill: billItem,
      )..add(BillLoadFile(billItem.billId!)),
      child: _BillDetailContent(deleteBk),
    );
  }
}

class _BillDetailContent extends StatelessWidget {
  _BillDetailContent(this.deleteBk);
  VoidCallback? deleteBk;
  @override
  Widget build(BuildContext context) {
    // ✅ 正确监听状态变化
    return BlocBuilder<BillDetailBloc, BillDetailState>(
      builder: (context, state) {
        return detailBillSheet(context, state);
      },
    );
  }

  Container detailBillSheet(BuildContext context, BillDetailState state) {
    // 根据账单类型设置颜色和图标
    Color billColor;
    IconData billIcon;
    BillItem bill = state.initialBill;

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

      default:
        billColor = Colors.grey;
        billIcon = Icons.help_outline;
        break;
    }

    // 格式化金额，确保显示两位小数
    String amountText = '¥${(bill.convertedAmount ?? 0).toStringAsFixed(2)}';
    if (bill.billType == BillType.expenditure) {
      amountText = '-$amountText';
    } else if (bill.billType == BillType.income) {
      amountText = '+$amountText';
    }

    // 获取分类名称
    String categoryName = _getCategoryNames(bill);

    // 分类自定义图标（取第一个已设置的图标）
    IconData? categoryIconData;
    if (bill.categoryAmountPair != null) {
      for (final pair in bill.categoryAmountPair!) {
        final resolved = AppIcon.resolve(pair.icon);
        if (resolved != null) {
          categoryIconData = resolved;
          break;
        }
      }
    }

    // 格式化时间
    String formattedDate = DateFormat('yyyy年MM月dd日 HH:mm')
        .format(bill.tradeTime ?? DateTime.now());
    String weekday = [
      '周日',
      '周一',
      '周二',
      '周三',
      '周四',
      '周五',
      '周六'
    ][(bill.tradeTime?.weekday ?? 7) % 7];
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部拖动条
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 金额和类型区域
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: billColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 关闭按钮和更多操作
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Row(
                      children: [
                        if (bill.billType != BillType.adjust) ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(EditBillPage.route(
                                  initialBill: BillItemAdd.fromBillItem(bill)));
                              // 跳转到编辑页面
                            },
                            tooltip: '编辑',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                        ],
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            if (deleteBk != null) {
                              deleteBk?.call();
                            }
                          },
                          tooltip: '删除',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 金额
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: billColor,
                  ),
                ),

                const SizedBox(height: 16),

                // 类型和分类
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: billColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(billIcon, size: 14, color: billColor),
                          const SizedBox(width: 4),
                          Text(
                            bill.billType?.title ?? '未知',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: billColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (categoryName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (categoryIconData != null) ...[
                              Icon(
                                categoryIconData,
                                size: 12,
                                color: Colors.grey[800],
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 详细信息
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDetailItem(
                  context,
                  bill.billType == BillType.transfer ? '转出账户' : '账户',
                  bill.accountName ?? '未知',
                  icon: AppIcon.resolve(bill.accountIcon) ??
                      Icons.account_balance_wallet,
                ),
                if (bill.billType == BillType.transfer)
                  _buildDetailItem(
                    context,
                    '转入账户',
                    bill.toAccountName ?? '未知',
                    icon: AppIcon.resolve(bill.toAccountIcon) ??
                        Icons.arrow_forward,
                  ),
                _buildDetailItem(
                  context,
                  '时间',
                  '$formattedDate $weekday',
                  icon: Icons.access_time,
                ),
                if (bill.title != null && bill.title!.isNotEmpty)
                  _buildDetailItem(
                    context,
                    '标题',
                    bill.title!,
                    icon: Icons.title,
                  ),
                if (bill.remark != null && bill.remark!.isNotEmpty)
                  _buildDetailItem(
                    context,
                    '备注',
                    bill.remark!,
                    icon: Icons.comment,
                  ),
                // 展示图片
                if (bill.fileList?.isNotEmpty == true)
                  _buildDetailItem(context, '附件', '',
                      icon: Icons.image, customWidget: _buildImageList(bill)),
                // 添加更多详情项...
                const SizedBox(height: 20),

                // 标签区域
                if (bill.tagList != null && bill.tagList!.isNotEmpty) ...[
                  const Text(
                    '标签',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bill.tagList!
                        .map((tag) => Chip(
                              avatar: Icon(
                                AppIcon.resolve(tag.icon) ??
                                    Icons.label_outline,
                                size: 14,
                                color: Colors.grey[700],
                              ),
                              label: Text(
                                tag.tagName ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey[200],
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // 底部按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (bill.billType != BillType.adjust)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 复制账单
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('账单已复制，请编辑后保存')),
                          );
                          Navigator.of(context).push(EditBillPage.route(
                              initialBill: BillItemAdd.fromBillItem(bill),
                              isCopyBill: true));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('复制账单'),
                      ),
                  ),
                  // const SizedBox(width: 16),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       // 添加相似账单
                  //       Navigator.pop(context);
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Theme.of(context).primaryColor,
                  //       foregroundColor: Colors.white,
                  //       padding: const EdgeInsets.symmetric(vertical: 12),
                  //     ),
                  //     child: const Text('添加相似'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建详情项
  Widget _buildDetailItem(BuildContext context, String label, String value,
      {IconData? icon, Widget? customWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: customWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // 获取分类名称
  String _getCategoryNames(BillItem bill) {
    if (bill.categoryAmountPair == null || bill.categoryAmountPair!.isEmpty) {
      return '未分类';
    }
    return bill.categoryAmountPair!
        .map((cat) => cat.categoryName)
        .where((name) => name != null && name.isNotEmpty)
        .join(', ');
  }

  Widget _buildImageList(BillItem bill) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: bill.fileList!.map((element) {
          return element.buildBase64Image(element.fileData!);
        }).toList(),
      ),
    );
  }
}
