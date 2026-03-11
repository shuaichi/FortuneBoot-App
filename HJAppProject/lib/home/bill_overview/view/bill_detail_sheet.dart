import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/bill_overview/view/bill_list_tile.dart';
import 'package:hjproject/home/edit_bill/view/edit_bill_page.dart';
import 'package:hjproject/home/bill_overview/bloc/detail_bloc/bill_detail_bloc.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:intl/intl.dart';

class BillDetailSheet extends StatelessWidget {
  BillDetailSheet({super.key, required this.billItem, this.deleteBk});

  final BillItem billItem;
  final VoidCallback? deleteBk;

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

  final VoidCallback? deleteBk;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillDetailBloc, BillDetailState>(
      builder: (context, state) {
        return _buildModernDetailSheet(context, state);
      },
    );
  }

  Widget _buildModernDetailSheet(BuildContext context, BillDetailState state) {
    BillItem bill = state.initialBill;

    // 🚀 核心优化：接入全新的高级权重匹配引擎
    final matchedConfig = SmartCategoryEngine.match(bill);
    final IconData billIcon = matchedConfig.icon;
    final Color billColor = matchedConfig.color;

    // 金额千分位格式化
    final formatter = NumberFormat('#,##0.00', 'en_US');
    String amountText = formatter.format(bill.convertedAmount ?? 0);
    if (bill.billType == BillType.expenditure) {
      amountText = '-$amountText';
    } else if (bill.billType == BillType.income) {
      amountText = '+$amountText';
    }

    String categoryName = _getCategoryNames(bill);
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(bill.tradeTime ?? DateTime.now());
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
        color: Color(0xFFF2F2F7), // 更柔和的 iOS 系统底灰
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部 Handle 条 与 动作栏
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Color(0xFFF2F2F7), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded,
                              size: 20, color: Color(0xFF8E8E93)),
                        ),
                      ),
                      Row(
                        children: [
                          if (bill.billType != BillType.adjust) ...[
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                                Navigator.of(context).push(EditBillPage.route(
                                    initialBill:
                                        BillItemAdd.fromBillItem(bill)));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: billColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Text('编辑',
                                    style: TextStyle(
                                        color: billColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              deleteBk?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFFF3B30).withOpacity(0.1),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.delete_outline_rounded,
                                  size: 20, color: Color(0xFFFF3B30)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 核心巨型金额区
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: billColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(billIcon, size: 16, color: billColor),
                      const SizedBox(width: 6),
                      Text(
                        categoryName.isNotEmpty
                            ? categoryName
                            : (bill.billType?.title ?? '未知'),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: billColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amountText,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: billColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 详细信息滚动区
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              children: [
                // 卡片组 1：基础信息
                _buildModernCardGroup(
                  children: [
                    if (bill.title != null && bill.title!.isNotEmpty) ...[
                      const _ModernDivider(),
                      _buildModernRow('标题', bill.title!,
                          Icons.edit_note_rounded, const Color(0xFFAF52DE)),
                    ],
                    _buildModernRow(
                        '账户',
                        bill.accountName ?? '未知',
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFF007AFF)),
                    if (bill.billType == BillType.transfer) ...[
                      const _ModernDivider(),
                      _buildModernRow(
                          '转入账户',
                          bill.toAccountName ?? '未知',
                          Icons.arrow_downward_rounded,
                          const Color(0xFF34C759)),
                    ],
                    const _ModernDivider(),
                    _buildModernRow('时间', '$formattedDate  $weekday',
                        Icons.access_time_rounded, const Color(0xFF5856D6)),
                    // 新增：交易对象展示
                    if (bill.payeeName != null &&
                        bill.payeeName!.isNotEmpty) ...[
                      const _ModernDivider(),
                      _buildModernRow('交易对象', bill.payeeName!,
                          Icons.storefront_rounded, const Color(0xFFFF9500)),
                    ],
                    if (bill.remark != null && bill.remark!.isNotEmpty) ...[
                      const _ModernDivider(),
                      _buildModernRow(
                          '备注',
                          bill.remark!,
                          Icons.chat_bubble_outline_rounded,
                          const Color(0xFF8E8E93)),
                    ],
                  ],
                ),

                // 标签与附件区域
                if ((bill.tagList?.isNotEmpty ?? false) ||
                    (bill.fileList?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  _buildModernCardGroup(
                    children: [
                      if (bill.tagList?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.local_offer_rounded,
                                      size: 18, color: Color(0xFF8E8E93)),
                                  SizedBox(width: 8),
                                  Text('标签',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF8E8E93))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: bill.tagList!
                                    .map((tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF2F4F7),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Text(tag.tagName ?? '',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF1C1C1E))),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      if ((bill.tagList?.isNotEmpty ?? false) &&
                          (bill.fileList?.isNotEmpty ?? false))
                        const _ModernDivider(),
                      if (bill.fileList?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.image_rounded,
                                      size: 18, color: Color(0xFF8E8E93)),
                                  SizedBox(width: 8),
                                  Text('附件',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFF8E8E93))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildImageList(bill),
                            ],
                          ),
                        ),
                    ],
                  ),
                ]
              ],
            ),
          ),

          // 底部操作区
          if (bill.billType != BillType.adjust)
            Container(
              color: const Color(0xFFF2F2F7),
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('复制此账单',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1C1C1E),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('已复制，请修改后保存',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF34C759),
                    ),
                  );
                  Navigator.of(context).push(EditBillPage.route(
                      initialBill: BillItemAdd.fromBillItem(bill),
                      isCopyBill: true));
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildModernRow(
      String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF8E8E93), height: 1.4)),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryNames(BillItem bill) {
    if (bill.categoryAmountPair == null || bill.categoryAmountPair!.isEmpty)
      return '';
    return bill.categoryAmountPair!
        .map((cat) => cat.categoryName)
        .where((name) => name != null && name.isNotEmpty)
        .join(', ');
  }

  Widget _buildImageList(BillItem bill) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bill.fileList!.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final element = bill.fileList![index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: element.buildBase64Image(element.fileData!),
          );
        },
      ),
    );
  }

  // 同步概览页的最新色彩体系
  Color _getBillColor(BillType? type) {
    switch (type) {
      case BillType.expenditure:
        return const Color(0xFF34C759); // 绿色 = 支出
      case BillType.income:
        return const Color(0xFFFF3B30); // 红色 = 收入
      case BillType.transfer:
        return const Color(0xFF007AFF); // 蓝色 = 转账
      case BillType.reimburse:
        return const Color(0xFF32ADE6); // 青色 = 报销
      case BillType.advance:
        return const Color(0xFFAF52DE); // 紫色 = 垫付
      case BillType.adjust:
        return const Color(0xFFFF9500); // 橙色 = 余额调整
      default:
        return const Color(0xFF1C1C1E);
    }
  }

  IconData _getBillIcon(BillType? type) {
    switch (type) {
      case BillType.expenditure:
        return Icons.arrow_upward_rounded;
      case BillType.income:
        return Icons.arrow_downward_rounded;
      case BillType.transfer:
        return Icons.swap_horiz_rounded;
      case BillType.adjust:
        return Icons.tune_rounded;
      case BillType.advance:
        return Icons.payment_rounded;
      case BillType.reimburse:
        return Icons.receipt_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class _ModernDivider extends StatelessWidget {
  const _ModernDivider();

  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 0.5,
        indent: 48,
        color: Color(0xFFE5E5EA),
      );
}
