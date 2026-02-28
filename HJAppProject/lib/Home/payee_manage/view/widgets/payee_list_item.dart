import 'package:flutter/material.dart';
import 'package:hjproject/home/payee_manage/model/payee.dart';

class PayeeListItem extends StatelessWidget {
  const PayeeListItem({
    super.key,
    required this.payee,
    required this.onModify,
    required this.onMoveToRecycle,
  });

  final Payee payee;
  final VoidCallback onModify;
  final VoidCallback onMoveToRecycle;

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    const Color surfaceColor = Colors.white;
    const Color primaryText = Colors.black87;
    const Color secondaryText = Colors.grey;
    const double cardRadius = 16.0;

    // 状态标签
    Widget _buildStatusTag() {
      if (!payee.enable) {
        return Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '停用',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // 类型标签（支出/收入/全部）
    Widget _buildTypeTags() {
      final List<Widget> tags = [];
      if (payee.canExpense) {
        tags.add(Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Text(
            '支出',
            style: TextStyle(fontSize: 10, color: Colors.green[700]),
          ),
        ));
      }
      if (payee.canIncome) {
        tags.add(Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red[100]!),
          ),
          child: Text(
            '收入',
            style: TextStyle(fontSize: 10, color: Colors.red[700]),
          ),
        ));
      }
      return Row(mainAxisSize: MainAxisSize.min, children: tags);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onModify, // 点击整个卡片进入编辑
          borderRadius: BorderRadius.circular(cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧图标
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.store_mall_directory_rounded,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                
                // 中间内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              payee.payeeName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusTag(),
                        ],
                      ),
                      if (payee.remark != null && payee.remark!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            payee.remark!,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),

                // 右侧标签和菜单
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTypeTags(),
                  ],
                ),
                
                // 更多菜单
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  tooltip: '更多操作',
                  surfaceTintColor: Colors.transparent,
                  color: surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 0) onModify();
                    else if (value == 1) onMoveToRecycle();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20), 
                          SizedBox(width: 12), 
                          Text('修改')
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: Colors.red), 
                          SizedBox(width: 12), 
                          Text('移入回收站', style: TextStyle(color: Colors.red))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}