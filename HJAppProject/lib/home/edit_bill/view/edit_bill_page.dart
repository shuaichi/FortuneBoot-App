import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

/// 重构后的记账页面
/// 采用现代移动端设计：
/// 1. 顶部类型切换 (分段控制)
/// 2. 沉浸式金额显示与分类图标
/// 3. 中部区域：分类选择 (支出/收入) 或 账户选择 (转账)
/// 4. 底部区域：工具栏 + 数字键盘
class EditBillPage extends StatelessWidget {
  const EditBillPage({super.key});

  static Route<void> route({BillItemAdd? initialBill, bool isCopyBill = false}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditBillBloc(
          billRepository: context.read<BillsRepository>(),
          initialBill: initialBill,
          isCopyBill: isCopyBill,
        )..add(EditBillInitialized(
            BillType.fromValue(initialBill?.data?.billType ?? 1) ??
                BillType.expenditure)),
        child: const EditBillPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditBillBloc, EditBillState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == EditBillStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(S.current.todosOverviewErrorSnackbarText)));
            } else if (state.status == EditBillStatus.closed) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.isNewBill ? '添加成功' : '修改成功')));
              Navigator.of(context).pop();
            } else if (state.status == EditBillStatus.submitFailed) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('提交失败，请检查网络或必填项')));
            }
          },
        ),
      ],
      child: const _EditBillView(),
    );
  }
}

class _EditBillView extends StatefulWidget {
  const _EditBillView();

  @override
  State<_EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<_EditBillView> {
  // 金额输入逻辑
  String _amountStr = '0.00';

  // 备注控制器
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化数据回显
    final state = context.read<EditBillBloc>().state;
    if (state.initialBill != null && _amountStr == '0.00') {
      // 如果是编辑模式，初始化金额
      // 注意：这里简化处理，如果是编辑模式，需要处理多分类金额求和或者单分类金额
      // 这里的逻辑假设单分类或者取总金额
      double initAmount = 0.0;
      if (state.editBill.data?.billType == BillType.transfer.value) {
        initAmount = state.editBill.data?.amount ?? 0.0;
      } else {
        // 支出/收入：累加分类金额
        final pairs = state.editBill.data?.categoryAmountPair;
        if (pairs != null && pairs.isNotEmpty) {
          for (var p in pairs) {
            initAmount += (p['amount'] as num).toDouble();
          }
        }
      }
      if (initAmount > 0) {
        _amountStr = initAmount.toStringAsFixed(2);
        // 去除末尾的0
        if (_amountStr.endsWith('.00')) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 3);
        } else if (_amountStr.contains('.') && _amountStr.endsWith('0')) {
           _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      }
    }
    
    if (state.editBill.data?.remark != null) {
      _remarkController.text = state.editBill.data!.remark!;
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  // --- 逻辑处理 ---

  void _onKeypadTap(String value) {
    setState(() {
      if (value == 'DEL') {
        if (_amountStr.isNotEmpty && _amountStr != '0') {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
          if (_amountStr.isEmpty) _amountStr = '0';
        }
      } else if (value == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else if (value == 'OK') {
        _submit();
      } else {
        // 数字
        if (_amountStr == '0' || _amountStr == '0.00') {
          _amountStr = value;
        } else {
          // 限制小数位数
          if (_amountStr.contains('.')) {
            final parts = _amountStr.split('.');
            if (parts.length > 1 && parts[1].length >= 2) {
              return; // 最多2位小数
            }
          }
           // 限制总长度
          if (_amountStr.replaceAll('.', '').length < 9) {
             _amountStr += value;
          }
        }
      }
      _updateBlocAmount();
    });
  }

  void _updateBlocAmount() {
    // 实时更新 Bloc 中的金额数据
    // 注意：这里需要根据当前选中的分类去分配金额。
    // 简化逻辑：如果是单选分类模式，直接更新该分类金额。
    // 如果是转账，直接更新 amount 字段。
    final amount = double.tryParse(_amountStr) ?? 0.0;
    final bloc = context.read<EditBillBloc>();
    final state = bloc.state;
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);

    if (billType == BillType.transfer) {
      state.editBill.data?.amount = amount;
    } else {
      // 支出/收入：更新当前选中分类的金额
      // 获取当前选中的分类ID
      // 这里假设UI上只支持单选分类（现代App常用模式）
      // 如果有多分类需求，需要在Model层做更复杂的处理，这里简化为单分类更新
      // 查找当前选中的分类
      final pairs = state.editBill.data?.categoryAmountPair;
      if (pairs != null && pairs.isNotEmpty) {
        // 更新第一个（也是当前选中的）
        pairs.first['amount'] = amount;
      }
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }
    
    // 触发Bloc提交
    // 确保数据已同步
    _updateBlocAmount();
    
    // 额外校验
    final state = context.read<EditBillBloc>().state;
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);
    
    if (billType != BillType.transfer) {
       final pairs = state.editBill.data?.categoryAmountPair;
       if (pairs == null || pairs.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('请选择分类')),
         );
         return;
       }
    } else {
       if (state.editBill.data?.accountId == null || state.editBill.data?.toAccountId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('请完善转账账户信息')),
         );
         return;
       }
    }

    context.read<EditBillBloc>().add(EditBillSubmitted());
  }

  void _onCategorySelected(int categoryId, double amount) {
    // 更新 Bloc
    final bloc = context.read<EditBillBloc>();
    // 清空旧的，添加新的（单选模式）
    bloc.state.editBill.data?.categoryAmountPair = [
      {'categoryId': categoryId, 'amount': amount}
    ];
    // 强制刷新UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 拦截余额调整
    final state = context.watch<EditBillBloc>().state;
    final isAdjust = state.initialBill != null &&
        (BillType.fromValue(state.editBill.data?.billType ?? 1) == BillType.adjust);
    if (isAdjust) return const SizedBox();

    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
    final primaryColor = _getBillTypeColor(billType);

    return Scaffold(
      backgroundColor: Colors.grey[50], // 浅灰背景
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _BillTypeSegmentedControl(
          currentType: billType,
          onTypeChanged: (type) {
            context.read<EditBillBloc>().add(EditBillTypeChange(type));
            // 切换类型时可能需要重置部分状态
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 顶部金额展示区域 (Hero)
          _buildAmountDisplay(billType, primaryColor),

          // 2. 中间内容区域 (分类/账户选择)
          Expanded(
            child: Container(
              color: Colors.white,
              child: billType == BillType.transfer
                  ? _TransferSelector(state: state)
                  : _CategorySelector(
                      billType: billType,
                      state: state,
                      onSelect: (id) => _onCategorySelected(id, double.tryParse(_amountStr) ?? 0.0),
                    ),
            ),
          ),

          // 3. 底部操作区域 (工具栏 + 键盘)
          _buildBottomPanel(state, primaryColor),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay(BillType type, Color color) {
    final state = context.read<EditBillBloc>().state;
    String categoryName = '未分类';
    IconData categoryIcon = Icons.category_outlined;
    
    if (type == BillType.transfer) {
      categoryName = '转账';
      categoryIcon = Icons.swap_horiz;
    } else {
      // 获取当前分类名称
      final pairs = state.editBill.data?.categoryAmountPair;
      if (pairs != null && pairs.isNotEmpty) {
        final catId = pairs.first['categoryId'];
        // 从 state.categoryList 中查找
        final cat = _findCategoryById(state.categoryList, catId as int);
        if (cat != null) {
          categoryName = cat.title;
          // categoryIcon = Icons.local_dining; // 实际项目中应从 cat.icon 获取
        }
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧：分类图标和名称
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          
          const Spacer(),
          
          // 右侧：金额
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '金额',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                _amountStr,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Monospace', // 等宽字体对齐
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(EditBillState state, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 工具栏
          _ActionToolbar(
            state: state,
            remarkController: _remarkController,
            onUpdate: () => setState(() {}),
          ),
          const Divider(height: 1),
          // 数字键盘
          _NumericKeypad(
            onTap: _onKeypadTap,
            confirmColor: color,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Color _getBillTypeColor(BillType type) {
    switch (type) {
      case BillType.expenditure:
        return Colors.redAccent;
      case BillType.income:
        return Colors.green;
      case BillType.transfer:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  CategorySelectItem? _findCategoryById(List<CategorySelectItem> list, int id) {
    for (var item in list) {
      if (item.id == id) return item;
      if (item.children != null) {
        final found = _findCategoryById(item.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }
}

// --- 组件：分段控制器 ---
class _BillTypeSegmentedControl extends StatelessWidget {
  final BillType currentType;
  final ValueChanged<BillType> onTypeChanged;

  const _BillTypeSegmentedControl({
    required this.currentType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(BillType.expenditure, '支出'),
          _buildSegment(BillType.income, '收入'),
          _buildSegment(BillType.transfer, '转账'),
        ],
      ),
    );
  }

  Widget _buildSegment(BillType type, String label) {
    final isSelected = currentType == type;
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}


// 修正后的分类选择器
class _CategorySelectorWrapper extends StatefulWidget {
  final BillType billType;
  final EditBillState state;
  final Function(int) onSelect;

  const _CategorySelectorWrapper({
    required this.billType,
    required this.state,
    required this.onSelect,
  });

  @override
  State<_CategorySelectorWrapper> createState() => _CategorySelectorWrapperState();
}

class _CategorySelectorWrapperState extends State<_CategorySelectorWrapper> {
  int _selectedParentId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.state.categoryList.isNotEmpty) {
      _selectedParentId = widget.state.categoryList.first.id;
      // 如果已选了分类，定位到该分类的父级
      final pairs = widget.state.editBill.data?.categoryAmountPair;
      if (pairs != null && pairs.isNotEmpty) {
        final selectedId = pairs.first['categoryId'] as int;
        for(var parent in widget.state.categoryList) {
          if (parent.id == selectedId) {
             _selectedParentId = parent.id;
             break;
          }
          if (parent.children != null) {
            for(var child in parent.children!) {
              if (child.id == selectedId) {
                _selectedParentId = parent.id;
                break;
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentList = widget.state.categoryList;
    final currentParent = parentList.firstWhere(
      (e) => e.id == _selectedParentId,
      orElse: () => parentList.isNotEmpty ? parentList.first : CategorySelectItem('', 0),
    );
    final subCategories = currentParent.children ?? [];

    return Row(
      children: [
        // 一级分类列表
        Container(
          width: 100,
          color: Colors.grey[100],
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: parentList.length,
            separatorBuilder: (c, i) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) {
              final cat = parentList[index];
              final isSelected = cat.id == _selectedParentId;
              return InkWell(
                onTap: () => setState(() => _selectedParentId = cat.id),
                child: Container(
                  height: 56,
                  color: isSelected ? Colors.white : Colors.transparent,
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(2)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            cat.title,
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // 二级分类网格
        Expanded(
          child: subCategories.isEmpty 
          ? Center(
              child: InkWell(
                 onTap: () => widget.onSelect(currentParent.id),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Icon(Icons.check_circle_outline, size: 40, color: Colors.grey),
                     const SizedBox(height: 8),
                     Text('直接选择 "${currentParent.title}"', style: const TextStyle(color: Colors.grey)),
                   ],
                 ),
              )
            )
          : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCat = subCategories[index];
              // 检查是否被选中
              final pairs = widget.state.editBill.data?.categoryAmountPair;
              bool isSelected = false;
              if (pairs != null && pairs.isNotEmpty) {
                 isSelected = pairs.any((p) => p['categoryId'] == subCat.id);
              }

              return InkWell(
                onTap: () => widget.onSelect(subCat.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category, // TODO: 支持自定义图标
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subCat.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 别名，指向上面的Wrapper
typedef _CategorySelector = _CategorySelectorWrapper;

// --- 组件：转账选择器 ---
class _TransferSelector extends StatefulWidget {
  final EditBillState state;
  const _TransferSelector({required this.state});

  @override
  State<_TransferSelector> createState() => _TransferSelectorState();
}

class _TransferSelectorState extends State<_TransferSelector> {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final outAccountName = _getAccountName(state.transferOutAccountList, state.editBill.data?.accountId);
    final inAccountName = _getAccountName(state.transferAccountList, state.editBill.data?.toAccountId);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildAccountCard(
            title: '转出账户',
            value: outAccountName,
            icon: Icons.upload_rounded,
            color: Colors.redAccent,
            onTap: () => _showAccountSelect(context, state.transferOutAccountList, true),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Icon(Icons.arrow_downward, color: Colors.grey),
          ),
          _buildAccountCard(
            title: '转入账户',
            value: inAccountName,
            icon: Icons.download_rounded,
            color: Colors.green,
            onTap: () => _showAccountSelect(context, state.transferAccountList, false),
          ),
        ],
      ),
    );
  }

  String _getAccountName(List<DropdownItem<AccountSelectItem>> list, int? id) {
    if (id == null) return '请选择';
    try {
      return list.firstWhere((e) => e.value.id == id).label;
    } catch (e) {
      return '未知账户';
    }
  }

  Widget _buildAccountCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAccountSelect(BuildContext context, List<DropdownItem<AccountSelectItem>> items, bool isOut) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (c, i) => ListTile(
          title: Text(items[i].label),
          onTap: () {
            final bloc = context.read<EditBillBloc>();
            if (isOut) {
              bloc.state.editBill.data?.accountId = items[i].value.id;
            } else {
              bloc.state.editBill.data?.toAccountId = items[i].value.id;
            }
            Navigator.pop(ctx);
            setState(() {});
          },
        ),
      ),
    );
  }
}

// --- 组件：底部工具栏 ---
class _ActionToolbar extends StatelessWidget {
  final EditBillState state;
  final TextEditingController remarkController;
  final VoidCallback onUpdate;

  const _ActionToolbar({
    required this.state,
    required this.remarkController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = state.editBill.data?.tradeTime ?? DateFormat('MM-dd').format(DateTime.now());
    final displayDate = dateStr.contains(' ') ? dateStr.split(' ')[0] : dateStr;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 日期选择
          _ToolButton(
            icon: Icons.calendar_today,
            label: displayDate,
            onTap: () => _showDatePicker(context),
          ),
          
          // 账户选择 (非转账模式)
          if (BillType.fromValue(state.editBill.data?.billType ?? 1) != BillType.transfer)
             _ToolButton(
              icon: Icons.wallet,
              label: '账户',
              isActive: state.editBill.data?.accountId != null,
              onTap: () => _showAccountPicker(context),
            ),

          // 标签
          _ToolButton(
            icon: Icons.local_offer_outlined,
            label: '标签',
            isActive: (state.editBill.data?.tagIdList ?? []).isNotEmpty,
            onTap: () => _showTagPicker(context),
          ),

          // 备注
          _ToolButton(
            icon: Icons.edit_note,
            label: '备注',
            isActive: remarkController.text.isNotEmpty,
            onTap: () => _showRemarkDialog(context),
          ),
          
          // 附件
          _ToolButton(
            icon: Icons.attach_file,
            label: '附件',
            isActive: state.attachments.isNotEmpty,
            onTap: () => _showAttachmentPicker(context),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (result != null) {
      final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime(result.year, result.month, result.day, now.hour, now.minute)
      );
      state.editBill.data?.tradeTime = timeStr;
      onUpdate();
    }
  }

  void _showAccountPicker(BuildContext context) {
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);
    final items = billType == BillType.income 
        ? state.incomeAccountList 
        : state.expenseAccountList;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text("选择账户", style: TextStyle(fontWeight: FontWeight.bold))),
          ...items.map((e) => ListTile(
            title: Text(e.label),
            leading: const Icon(Icons.wallet),
            selected: state.editBill.data?.accountId == e.value.id,
            onTap: () {
               state.editBill.data?.accountId = e.value.id;
               Navigator.pop(ctx);
               onUpdate();
            },
          )),
        ],
      ),
    );
  }

  void _showRemarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加备注'),
        content: TextField(
          controller: remarkController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '写点什么...'),
          onChanged: (v) => state.editBill.data?.remark = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定')),
        ],
      ),
    ).then((_) => onUpdate());
  }

  void _showTagPicker(BuildContext context) {
    // 简化版标签选择，实际可复用原有的TagTree
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            const Text('选择标签', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: state.tagList.map((tag) {
                  final isSelected = state.editBill.data?.tagIdList?.contains(tag.id) ?? false;
                  return CheckboxListTile(
                    title: Text(tag.title),
                    value: isSelected,
                    onChanged: (v) {
                       List<int> ids = state.editBill.data?.tagIdList ?? [];
                       if (v == true) {
                         ids.add(tag.id);
                       } else {
                         ids.remove(tag.id);
                       }
                       state.editBill.data?.tagIdList = ids;
                       // 强制刷新当前Sheet (这里简化了，实际需要StatefulBuilder)
                       Navigator.pop(ctx); // 简单粗暴，关掉重开或让用户自己关
                       _showTagPicker(context); 
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => onUpdate());
  }
  
  void _showAttachmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             AttachmentUploadWidget(
               initialAttachments: state.attachments,
               onAttachmentsChanged: (list) {
                 context.read<EditBillBloc>().add(EditBillAttachmentsChanged(list));
                 onUpdate();
               },
             ),
             const SizedBox(height: 20),
          ]
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isActive ? Theme.of(context).primaryColor : Colors.grey[600]),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 组件：数字键盘 ---
class _NumericKeypad extends StatelessWidget {
  final Function(String) onTap;
  final Color confirmColor;

  const _NumericKeypad({required this.onTap, required this.confirmColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        children: [
          _buildRow(['1', '2', '3', 'DEL']),
          _buildRow(['4', '5', '6', 'OK'], isLastColumnSpecial: true), // OK 占两行? 布局稍微复杂点，先简单做
          // 重新设计：
          // 1 2 3 DEL
          // 4 5 6
          // 7 8 9 OK (span 2 row)
          // . 0   
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildKeyRow(['1', '2', '3']),
                    _buildKeyRow(['4', '5', '6']),
                    _buildKeyRow(['7', '8', '9']),
                    _buildKeyRow(['.', '0', 'HIDE']), // HIDE: 收起键盘或者00
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildKey('DEL', height: 112, color: Colors.transparent), // 2格高
                    _buildKey('OK', height: 112, color: confirmColor, textColor: Colors.white),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, {bool isLastColumnSpecial = false}) {
    return Row(
      children: keys.map((k) => Expanded(child: _buildKey(k))).toList(),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      children: keys.map((k) => Expanded(child: _buildKey(k))).toList(),
    );
  }

  Widget _buildKey(String value, {double height = 56, Color? color, Color? textColor}) {
    // 处理特殊建
    Widget content;
    if (value == 'DEL') {
      content = const Icon(Icons.backspace_outlined);
    } else if (value == 'OK') {
      content = const Text('完成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
    } else if (value == 'HIDE') {
       // content = const Icon(Icons.keyboard_hide_outlined);
       content = const SizedBox(); // 占位，或者换成 '00'
    } else {
      content = Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500));
    }
    
    // 特殊逻辑：如果是HIDE，换成空白占位，但为了对齐，不响应点击
    if (value == 'HIDE') {
       return SizedBox(height: height);
    }

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        height: height,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: color == null ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 1,
            )
          ] : null,
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: TextStyle(color: textColor ?? Colors.black87),
          child: content,
        ),
      ),
    );
  }
}