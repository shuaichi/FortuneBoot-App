import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/request/category_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/util/app_icon.dart';

class CategoryTreeWidget extends StatefulWidget {
  CategoryTreeWidget(
      {super.key,
      required this.categories,
      required this.billType,
      this.onCategorySelected,
      required this.categoryAmountPairs});

  List<CategorySelectItem> categories;
  Function(Map<int, double>)? onCategorySelected;
  Map<int, double> categoryAmountPairs;
  BillType billType;

  @override
  State<CategoryTreeWidget> createState() => CategoryTreeWidgetState();
}

class CategoryTreeWidgetState extends State<CategoryTreeWidget> {
  // 当前选中的分类ID（选中路径的最后一个）
  int? _selectedCategoryId;

  // 选中的路径（从顶层到当前层的分类ID）
  List<int> _selectedPath = [];
  TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 已选择的分类和金额
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分类: ${_getSelectedCategoryPath()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d{0,5}')), // 允许负号、数字和最多5位小数
                        ],
                        decoration: InputDecoration(
                          labelText: '金额',
                          hintText: '请输入金额',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(_amountController.text);
                        if (amount != null && amount != 0) {
                          if (_selectedCategoryId == null) {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('请选择当前费用所属分类')),
                            );
                            return;
                          }
                          setState(() {
                            // 优先使用三级分类，其次二级分类，最后一级分类
                            categorys();
                            _amountController.clear();
                            // 收起键盘
                            FocusScope.of(context).unfocus();
                          });
                        } else {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('请输入非零金额')),
                          );
                        }
                      },
                      child: Text('添加'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (widget.categoryAmountPairs.isNotEmpty) _buildSelectedCategories(),

        // 分类选择器
        _buildCategorySelector(widget.categories),
      ],
    );
  }

  Map<int, double> categorys() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount != 0) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择当前费用所属分类')),
        );
      } else {
        widget.categoryAmountPairs[_selectedCategoryId!] = amount;
      }
    }
    return widget.categoryAmountPairs;
  }

  // 已选择的分类和金额
  Widget _buildSelectedCategories() {
    widget.onCategorySelected?.call(widget.categoryAmountPairs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '已选择的分类',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.categoryAmountPairs.length,
          itemBuilder: (context, index) {
            final categoryId = widget.categoryAmountPairs.keys.elementAt(index);
            final amount = widget.categoryAmountPairs[categoryId];

            // 查找分类名称
            String categoryName = CategorySelectItem.getFullPathById(
                widget.categories, categoryId);

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.category, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '¥${amount?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.billType == BillType.expenditure
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            widget.categoryAmountPairs.remove(categoryId);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Divider(),
      ],
    );
  }

  // 分类选择器（递归实现，每一层均为左右滑动的水平列表）
  Widget _buildCategorySelector(List<CategorySelectItem> categories) {
    final List<Widget> levelWidgets = [];

    // 顶层
    levelWidgets.add(_buildLevelRow(categories, 0));

    // 逐层渲染子级（根据已选择路径）
    int depth = 1;
    List<CategorySelectItem>? currentChildren;
    while (true) {
      final int? parentId =
          depth - 1 < _selectedPath.length ? _selectedPath[depth - 1] : null;
      if (parentId == null) break;
      final CategorySelectItem? parentNode =
          _findByIdInTree(categories, parentId);
      if (parentNode == null ||
          parentNode.children == null ||
          parentNode.children!.isEmpty) {
        break;
      }
      currentChildren = parentNode.children;
      levelWidgets.add(_buildLevelRow(currentChildren!, depth));
      depth++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: levelWidgets,
    );
  }

  // 构建某一层的水平列表（左右滑动）
  Widget _buildLevelRow(List<CategorySelectItem> nodes, int depth) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _levelTitle(depth),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: nodes.map((node) {
                  final bool isSelected = _selectedPath.length > depth &&
                      _selectedPath[depth] == node.id;
                  final bool hasChildren =
                      node.children != null && node.children!.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (AppIcon.resolve(node.icon) != null) ...[
                            Icon(
                              AppIcon.resolve(node.icon),
                              size: 14,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : null,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(node.title,
                              style: TextStyle(fontSize: depth == 0 ? 14 : 12)),
                          if (hasChildren)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.chevron_right, size: 16),
                            ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          // 截断到当前深度
                          _selectedPath = _selectedPath.take(depth).toList();
                          if (selected) {
                            _selectedPath.add(node.id);
                          }
                          // 更新当前选中的分类ID为路径末尾
                          _selectedCategoryId = _selectedPath.isNotEmpty
                              ? _selectedPath.last
                              : null;
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                      backgroundColor: Colors.transparent,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 获取当前选择的分类路径
  String _getSelectedCategoryPath() {
    if (_selectedCategoryId == null) return '';
    return CategorySelectItem.getFullPathById(
        widget.categories, _selectedCategoryId!);
  }

  // 在整棵分类树中查找指定ID的节点
  CategorySelectItem? _findByIdInTree(List<CategorySelectItem> roots, int id) {
    for (final root in roots) {
      final found = root.findById(id);
      if (found != null) return found;
    }
    return null;
  }

  // 根据层级生成标题
  String _levelTitle(int depth) {
    final level = depth + 1;
    return '${level}级分类';
  }
}
