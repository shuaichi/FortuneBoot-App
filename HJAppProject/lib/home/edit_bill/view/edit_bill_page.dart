import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
    return BlocListener<EditBillBloc, EditBillState>(
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
            ..showSnackBar(const SnackBar(content: Text('提交失败')));
        }
      },
      child: const EditBillView(),
    );
  }
}

class EditBillView extends StatefulWidget {
  const EditBillView({super.key});

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  // 核心状态：当前正在编辑的金额字段索引
  // -1 表示转账金额，>=0 表示多分类列表中的索引
  final ValueNotifier<int> _activeAmountIndex = ValueNotifier(0);
  // 控制键盘显隐，默认为 true
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier(true);
  
  // 核心状态：分类-金额组合列表
  late List<CategoryAmountItem> _categoryAmountItems;

  final TextEditingController _remarkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ValueNotifier<bool> _isSecondaryExpanded = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController();

  // 主题色配置 (Mock Settings)
  Color _getThemeColor(BillType type) {
    switch (type) {
      case BillType.expenditure:
        return Colors.green; // 支出：绿色
      case BillType.income:
        return Colors.red;   // 收入：红色
      case BillType.transfer:
        return Colors.blue;  // 转账：蓝色
      default:
        return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<EditBillBloc>().state;
    _initCategoryAmountItems(state);
    
    if (state.editBill.data?.remark != null) {
      _remarkController.text = state.editBill.data!.remark!;
    }
    if (state.editBill.data?.title != null) {
      _titleController.text = state.editBill.data!.title!;
    }
  }

  void _initCategoryAmountItems(EditBillState state) {
    _categoryAmountItems = [];
    final pairs = state.editBill.data?.categoryAmountPair;
    if (pairs != null && pairs.isNotEmpty) {
      for (var p in pairs) {
        _categoryAmountItems.add(CategoryAmountItem(
          categoryId: (p['categoryId'] as num?)?.toInt(),
          amount: (p['amount'] as num?)?.toDouble() ?? 0.0,
        ));
      }
    } else {
      _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
    }
  }

  @override
  void dispose() {
    _activeAmountIndex.dispose();
    _isKeyboardVisible.dispose();
    _remarkController.dispose();
    _titleController.dispose();
    _isSecondaryExpanded.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditBillBloc>().state;
    final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
    final isTransfer = billType == BillType.transfer;
    final themeColor = _getThemeColor(billType);

    return Scaffold(
      backgroundColor: Colors.grey[50], // 浅灰背景提升层次感
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildTypeSwitcher(billType, state.status == EditBillStatus.loading, themeColor),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: state.status.isLoadingOrInit ? null : () => _submit(state),
            style: TextButton.styleFrom(
              foregroundColor: themeColor,
            ),
            child: state.status.isLoadingOrInit 
              ? const CupertinoActivityIndicator() 
              : const Text('完成', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  // 1. 金额核心区 & 分类组合区 (主卡片)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: isTransfer
                          ? _buildTransferAmountSection(state, themeColor)
                          : _buildCategoryAmountList(state, themeColor),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 2. 主要信息区 (主卡片)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildMainInfoSection(state, isTransfer, themeColor),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 3. 次要信息区 (次卡片，默认折叠)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: _buildSecondaryInfoSection(state, isTransfer, themeColor),
                  ),

                  const SizedBox(height: 80), // 留白给键盘
                ],
              ),
            ),
          ),
          
          // 4. 数字键盘 (可折叠)
          ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisible,
            builder: (context, visible, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: visible ? (50.0 * 4 + 40) : 0, // 4行键盘 + 顶部栏
                child: visible ? _buildNumericKeyboard(themeColor) : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 顶部类型切换 ---
  Widget _buildTypeSwitcher(BillType currentType, bool isLoading, Color themeColor) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _typeButton(BillType.expenditure, '支出', currentType, isLoading, _getThemeColor(BillType.expenditure)),
          _typeButton(BillType.income, '收入', currentType, isLoading, _getThemeColor(BillType.income)),
          _typeButton(BillType.transfer, '转账', currentType, isLoading, _getThemeColor(BillType.transfer)),
        ],
      ),
    );
  }

  Widget _typeButton(BillType type, String label, BillType currentType, bool isLoading, Color activeColor) {
    final isSelected = type == currentType;
    return GestureDetector(
      onTap: isLoading ? null : () {
        if (!isSelected) {
          context.read<EditBillBloc>().add(EditBillTypeChange(type));
          setState(() {
            _activeAmountIndex.value = type == BillType.transfer ? -1 : 0;
            _categoryAmountItems = [CategoryAmountItem(amount: 0.0)];
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- 转账金额区 ---
  Widget _buildTransferAmountSection(EditBillState state, Color themeColor) {
    return Column(
      children: [
        Text('转账金额', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            _activeAmountIndex.value = -1;
            _isKeyboardVisible.value = true;
          },
          child: ValueListenableBuilder<int>(
            valueListenable: _activeAmountIndex,
            builder: (_, activeIndex, __) {
              final isActive = activeIndex == -1;
              final amount = state.editBill.data?.amount ?? 0.0;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: isActive ? Border(bottom: BorderSide(color: themeColor, width: 2)) : null,
                ),
                child: Text(
                  amount == 0 ? '0.00' : amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: isActive ? themeColor : Colors.black87,
                    fontFamily: 'RobotoMono', // 等宽字体更适合金额
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 分类金额列表区 (支出/收入) ---
  Widget _buildCategoryAmountList(EditBillState state, Color themeColor) {
    return Column(
      children: [
        // 列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categoryAmountItems.length,
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, indent: 48),
          ),
          itemBuilder: (context, index) {
            return _buildCategoryAmountItem(state, index, themeColor);
          },
        ),
        
        // 添加按钮
        if (_categoryAmountItems.length < 5)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _categoryAmountItems.add(CategoryAmountItem(amount: 0.0));
                  _activeAmountIndex.value = _categoryAmountItems.length - 1;
                  _isKeyboardVisible.value = true;
                });
                _syncCategoryAmountToState();
              },
              icon: Icon(Icons.add_circle, size: 20, color: themeColor),
              label: Text('添加明细', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(
                backgroundColor: themeColor.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryAmountItem(EditBillState state, int index, Color themeColor) {
    final item = _categoryAmountItems[index];
    final categoryName = _getCategoryName(state.categoryList, item.categoryId);
    
    return Dismissible(
      key: item.key,
      direction: _categoryAmountItems.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) {
        setState(() {
          _categoryAmountItems.removeAt(index);
          if (_activeAmountIndex.value >= _categoryAmountItems.length) {
            _activeAmountIndex.value = _categoryAmountItems.length - 1;
          }
        });
        _syncCategoryAmountToState();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _activeAmountIndex,
        builder: (_, activeIndex, __) {
          final isActive = activeIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: isActive ? themeColor.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: themeColor.withOpacity(0.3)) : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                // 分类选择
                InkWell(
                  onTap: () => _showCategorySelector(context, state, index, themeColor),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category_outlined, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            categoryName.isEmpty ? '选择分类' : categoryName.split(' > ').last, // 只显示末级名称简洁点
                            style: TextStyle(
                              color: categoryName.isEmpty ? Colors.grey : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // 金额显示 (点击展开键盘)
                InkWell(
                  onTap: () {
                    _activeAmountIndex.value = index;
                    _isKeyboardVisible.value = true;
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      item.amount == 0 ? '0.00' : item.amount.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isActive ? themeColor : Colors.black87,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 主要信息区 ---
  Widget _buildMainInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return Column(
      children: [
        // 标题输入 (新增)
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '请输入标题（必填）',
            border: InputBorder.none,
            icon: Icon(Icons.title, color: Colors.grey[600]),
            suffixIcon: _titleController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _titleController.clear();
                    state.editBill.data?.title = '';
                  },
                ) 
              : null,
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          onChanged: (v) {
            state.editBill.data?.title = v;
          },
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // 账户 / 转出账户
        _buildInfoRow(
          icon: isTransfer ? Icons.arrow_upward : Icons.account_balance_wallet,
          label: isTransfer ? '转出账户' : '账户',
          value: _getAccountName(state, isTransfer ? state.editBill.data?.accountId : state.editBill.data?.accountId),
          placeholder: '选择账户',
          onTap: () => _showAccountSelector(context, state, isSource: true),
        ),
        
        const SizedBox(height: 16),
        
        if (isTransfer) ...[
          // 转入账户
           _buildInfoRow(
            icon: Icons.arrow_downward,
            label: '转入账户',
            value: _getAccountName(state, state.editBill.data?.toAccountId),
            placeholder: '选择账户',
            onTap: () => _showAccountSelector(context, state, isSource: false),
          ),
           const SizedBox(height: 16),
        ],
        
        // 时间
        _buildInfoRow(
          icon: Icons.access_time,
          label: '时间',
          value: state.editBill.data?.tradeTime ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          placeholder: '选择时间',
          onTap: () => _showTimeSelector(context, state),
        ),
        
        if (!isTransfer) ...[
          const SizedBox(height: 16),
          // 交易对象
          _buildInfoRow(
            icon: Icons.person_outline,
            label: '交易对象',
            value: _getPayeeName(state, state.editBill.data?.payeeId),
            placeholder: '无',
            onTap: () => _showPayeeSelector(context, state),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const Spacer(),
            Text(
              value.isEmpty ? placeholder : value,
              style: TextStyle(
                fontSize: 15,
                color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // --- 次要信息区 ---
  Widget _buildSecondaryInfoSection(EditBillState state, bool isTransfer, Color themeColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isSecondaryExpanded,
      builder: (_, isExpanded, __) {
        return Column(
          children: [
            // 标题栏（点击展开/折叠）
            InkWell(
              onTap: () => _isSecondaryExpanded.value = !isExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text('更多信息', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const Spacer(),
                    if (!isExpanded) ...[
                      // 折叠时显示简要信息图标
                       if (state.editBill.data?.tagIdList?.isNotEmpty == true)
                         Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.local_offer, size: 16, color: themeColor)),
                       if (state.editBill.data?.remark?.isNotEmpty == true)
                         Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.note, size: 16, color: themeColor)),
                       if (state.attachments.isNotEmpty)
                         Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.attach_file, size: 16, color: themeColor)),
                    ],
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标签 (树形多选)
                    _buildTagInfoRow(state, themeColor),
                    const SizedBox(height: 20),
                    
                    // 备注
                    TextField(
                      controller: _remarkController,
                      decoration: InputDecoration(
                        labelText: '备注',
                        hintText: '写点什么...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (v) {
                        state.editBill.data?.remark = v;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // 附件
                    AttachmentUploadWidget(
                      initialAttachments: state.attachments,
                      onAttachmentsChanged: (list) {
                        context.read<EditBillBloc>().add(EditBillAttachmentsChanged(list));
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 确认 & 统计
                    Row(
                      children: [
                        Expanded(
                          child: _buildSwitchTile(
                            '确认', 
                            state.editBill.data?.confirm ?? true, 
                            isTransfer ? null : (v) {
                              setState(() {
                                state.editBill.data?.confirm = v;
                              });
                            },
                            themeColor
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSwitchTile(
                            '统计', 
                            state.editBill.data?.include ?? true, 
                            isTransfer ? null : (v) {
                              setState(() {
                                state.editBill.data?.include = v;
                              });
                            },
                            themeColor
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildTagInfoRow(EditBillState state, Color themeColor) {
    final hasTags = state.editBill.data?.tagIdList?.isNotEmpty ?? false;
    return InkWell(
      onTap: () => _showTagSelector(context, state, themeColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_offer_outlined, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('标签', style: TextStyle(fontSize: 15, color: Colors.black87)),
                if (hasTags) ...[
                   const SizedBox(height: 8),
                   Wrap(
                     spacing: 6,
                     runSpacing: 4,
                     children: state.editBill.data!.tagIdList!.map((id) {
                       final tagName = _getTagName(state.tagList, id);
                       return Chip(
                         label: Text(tagName, style: const TextStyle(fontSize: 12)),
                         backgroundColor: themeColor.withOpacity(0.1),
                         labelStyle: TextStyle(color: themeColor),
                         padding: EdgeInsets.zero,
                         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                       );
                     }).toList(),
                   )
                ] else
                   Text('无', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
  
  String _getTagName(List<TagSelectItem> tags, int id) {
     return TagSelectItem.getFullPathById(tags, id);
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool)? onChanged, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- 数字键盘 ---
  Widget _buildNumericKeyboard(Color themeColor) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 键盘工具栏
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: const Border(top: BorderSide(color: Colors.black12), bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_hide, color: Colors.grey[600]),
                    onPressed: () => _isKeyboardVisible.value = false,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildKeyboardRow(['1', '2', '3']),
                      _buildKeyboardRow(['4', '5', '6']),
                      _buildKeyboardRow(['7', '8', '9']),
                      _buildKeyboardRow(['.', '0', 'DEL']),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                       FocusScope.of(context).unfocus();
                       _isKeyboardVisible.value = false;
                       // Optional: Add logic to check completeness
                    },
                    child: Container(
                      height: 50.0 * 4,
                      decoration: BoxDecoration(
                        color: themeColor,
                        border: Border(left: BorderSide(color: Colors.grey[200]!)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('完成', style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return SizedBox(
      height: 50,
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: InkWell(
              onTap: () => _onKeyTap(key),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Colors.grey[100]!),
                    bottom: BorderSide(color: Colors.grey[100]!),
                  ),
                ),
                child: key == 'DEL' 
                  ? const Icon(Icons.backspace_outlined, size: 20)
                  : Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onKeyTap(String key) {
    final idx = _activeAmountIndex.value;
    final state = context.read<EditBillBloc>().state;
    
    // 获取当前正在编辑的值
    double currentVal;
    if (idx == -1) {
      currentVal = state.editBill.data?.amount ?? 0;
    } else {
      currentVal = _categoryAmountItems[idx].amount;
    }
    
    String strVal = currentVal == 0 ? '' : currentVal.toString();
    if (strVal.endsWith('.0')) strVal = strVal.substring(0, strVal.length - 2);

    if (key == 'DEL') {
      if (strVal.isNotEmpty) {
        strVal = strVal.substring(0, strVal.length - 1);
      }
    } else if (key == '.') {
      if (!strVal.contains('.')) {
        strVal = strVal.isEmpty ? '0.' : '$strVal.';
      }
    } else {
      // 数字
      if (strVal.contains('.')) {
        if (strVal.split('.')[1].length < 2) { // 限制2位小数
          strVal += key;
        }
      } else {
        if (strVal.length < 9) { // 限制整数位数
           strVal += key;
        }
      }
    }
    
    double newVal = double.tryParse(strVal) ?? 0;
    
    // 更新状态
    setState(() {
      if (idx == -1) {
        state.editBill.data?.amount = newVal;
      } else {
        _categoryAmountItems[idx].amount = newVal;
        _syncCategoryAmountToState();
      }
    });
  }

  // --- 辅助方法 ---

  void _syncCategoryAmountToState() {
    final state = context.read<EditBillBloc>().state;
    List<Map<String, num>> pairs = [];
    double total = 0;
    for (var item in _categoryAmountItems) {
      if (item.categoryId != null) {
        pairs.add({'categoryId': item.categoryId!, 'amount': item.amount});
      }
      total += item.amount;
    }
    state.editBill.data?.categoryAmountPair = pairs;
    // 同时也更新总金额
    state.editBill.data?.amount = total;
  }
  
  String _getCategoryName(List<CategorySelectItem> categories, int? id) {
    if (id == null) return '';
    return CategorySelectItem.getFullPathById(categories, id);
  }
  
  String _getAccountName(EditBillState state, int? id) {
    if (id == null) return '';
    // 搜索 expense/income/transfer 列表
    for (var i in [...state.expenseAccountList, ...state.incomeAccountList, ...state.transferAccountList]) {
      if (i.value.id == id) return i.label;
    }
    return '';
  }
  
  String _getPayeeName(EditBillState state, int? id) {
     if (id == null) return '';
     for (var i in state.payeeList) {
       if (i.value.id == id) return i.label;
     }
     return '';
  }

  // --- 底部弹窗 ---

  void _showCategorySelector(BuildContext context, EditBillState state, int index, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CategorySelectorSheet(
          categories: state.categoryList,
          activeColor: themeColor,
          onSelected: (id) {
            setState(() {
              _categoryAmountItems[index].categoryId = id;
            });
            _syncCategoryAmountToState();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  
  void _showTagSelector(BuildContext context, EditBillState state, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: TagSelectorSheet(
          tags: state.tagList,
          activeColor: themeColor,
          selectedIds: state.editBill.data?.tagIdList ?? [],
          onChanged: (ids) {
            setState(() {
               state.editBill.data?.tagIdList = ids;
            });
          },
        ),
      ),
    );
  }

  void _showAccountSelector(BuildContext context, EditBillState state, {required bool isSource}) {
     // 根据当前类型和是转出还是转入，确定列表
     final billType = BillType.fromValue(state.editBill.data?.billType ?? 1) ?? BillType.expenditure;
     List<DropdownItem<AccountSelectItem>> list = [];
     
     if (billType == BillType.transfer) {
       list = isSource ? state.transferOutAccountList : state.transferAccountList;
     } else if (billType == BillType.income) {
       list = state.incomeAccountList;
     } else {
       list = state.expenseAccountList;
     }
     
     showModalBottomSheet(
       context: context,
       builder: (_) => Container(
         padding: const EdgeInsets.symmetric(vertical: 16),
         child: ListView.builder(
           shrinkWrap: true,
           itemCount: list.length,
           itemBuilder: (_, i) => ListTile(
             title: Text(list[i].label),
             onTap: () {
               setState(() {
                 if (billType == BillType.transfer) {
                   if (isSource) {
                     state.editBill.data?.accountId = list[i].value.id;
                   } else {
                     state.editBill.data?.toAccountId = list[i].value.id;
                   }
                 } else {
                   state.editBill.data?.accountId = list[i].value.id;
                 }
               });
               Navigator.pop(context);
             },
           ),
         ),
       ),
     );
  }

  void _showTimeSelector(BuildContext context, EditBillState state) {
     DateTime initialDate = DateTime.now();
     try {
       initialDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(state.editBill.data?.tradeTime ?? '');
     } catch(e) {}

     showModalBottomSheet(
       context: context,
       isScrollControlled: true,
       builder: (_) => SizedBox(
         height: 400,
         child: CustomDateTimePicker(
           initialDate: initialDate,
           onDateTimeChanged: (dt) {
             setState(() {
               state.editBill.data?.tradeTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
             });
             Navigator.pop(context);
           },
         ),
       ),
     );
  }
  
  void _showPayeeSelector(BuildContext context, EditBillState state) {
    showModalBottomSheet(
       context: context,
       builder: (_) => Container(
         padding: const EdgeInsets.symmetric(vertical: 16),
         child: ListView.builder(
           shrinkWrap: true,
           itemCount: state.payeeList.length,
           itemBuilder: (_, i) => ListTile(
             title: Text(state.payeeList[i].label),
             onTap: () {
               setState(() {
                 state.editBill.data?.payeeId = state.payeeList[i].value.id;
               });
               Navigator.pop(context);
             },
           ),
         ),
       ),
     );
  }

  void _submit(EditBillState state) {
     final billType = BillType.fromValue(state.editBill.data?.billType ?? 1);
     
     if (billType == BillType.transfer) {
       if ((state.editBill.data?.amount ?? 0) <= 0) {
         _showError('请输入金额'); return;
       }
       if (state.editBill.data?.accountId == null || state.editBill.data?.toAccountId == null) {
         _showError('请选择账户'); return;
       }
     } else {
       if (_categoryAmountItems.isEmpty || _categoryAmountItems.every((e) => e.amount <= 0)) {
         _showError('请输入金额'); return;
       }
       if (_categoryAmountItems.any((e) => e.categoryId == null)) {
         _showError('请选择分类'); return;
       }
       if (state.editBill.data?.accountId == null) {
         _showError('请选择账户'); return;
       }
     }
     
     context.read<EditBillBloc>().add(EditBillSubmitted());
  }
  
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class CategoryAmountItem {
  int? categoryId;
  double amount;
  final UniqueKey key;

  CategoryAmountItem({this.categoryId, required this.amount}) : key = UniqueKey();
}


// --- 分类选择器（支持任意层级选择） ---
class CategorySelectorSheet extends StatefulWidget {
  final List<CategorySelectItem> categories;
  final Function(int) onSelected;
  final Color activeColor;

  const CategorySelectorSheet({super.key, required this.categories, required this.onSelected, required this.activeColor});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  List<CategorySelectItem>? _currentLevelItems;
  final List<CategorySelectItem> _breadcrumb = [];

  @override
  void initState() {
    super.initState();
    _currentLevelItems = widget.categories;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部栏：返回 + 标题 + 面包屑
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
               if (_breadcrumb.isNotEmpty)
                 IconButton(
                   icon: const Icon(Icons.arrow_back_ios, size: 18),
                   onPressed: () {
                     setState(() {
                        _breadcrumb.removeLast();
                        if (_breadcrumb.isEmpty) {
                          _currentLevelItems = widget.categories;
                        } else {
                          _currentLevelItems = _breadcrumb.last.children;
                        }
                     });
                   },
                 ),
               Expanded(
                 child: Text(
                   _breadcrumb.isEmpty ? '选择分类' : _breadcrumb.map((e) => e.title).join(' > '), 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                   overflow: TextOverflow.ellipsis,
                 ),
               ),
            ],
          ),
        ),
        const Divider(height: 1),
        
        Expanded(
          child: ListView.builder(
            itemCount: _currentLevelItems?.length ?? 0,
            itemBuilder: (context, index) {
              final item = _currentLevelItems![index];
              final hasChildren = item.children != null && item.children!.isNotEmpty;
              return InkWell(
                onTap: () {
                   // 点击行即可选中
                   widget.onSelected(item.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: const TextStyle(fontSize: 16)),
                      ),
                      
                      // 选中按钮
                      Icon(Icons.check_circle_outline, size: 20, color: widget.activeColor.withOpacity(0.5)),
                      
                      // 如果有子级，显示进入下一级的按钮
                      if (hasChildren) ...[
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                             // 进入下一级
                             setState(() {
                               _breadcrumb.add(item);
                               _currentLevelItems = item.children;
                             });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text('下级', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
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

// --- 标签选择器（树形多选，任意层级） ---
class TagSelectorSheet extends StatefulWidget {
  final List<TagSelectItem> tags;
  final List<int> selectedIds;
  final Function(List<int>) onChanged;
  final Color activeColor;

  const TagSelectorSheet({super.key, required this.tags, required this.selectedIds, required this.onChanged, required this.activeColor});

  @override
  State<TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<TagSelectorSheet> {
  late List<int> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Padding(
           padding: const EdgeInsets.all(16),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('选择标签', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               TextButton(
                 onPressed: () => Navigator.pop(context), 
                 child: Text('确定', style: TextStyle(color: widget.activeColor, fontWeight: FontWeight.bold)),
               ),
             ],
           ),
         ),
         const Divider(height: 1),
         Expanded(
           child: SingleChildScrollView(
             child: Column(
               children: _buildNodes(widget.tags),
             ),
           ),
         ),
      ],
    );
  }
  
  List<Widget> _buildNodes(List<TagSelectItem> nodes, [int depth = 0]) {
    return nodes.map((node) => _buildNode(node, depth)).toList();
  }
  
  Widget _buildNode(TagSelectItem node, int depth) {
    final hasChildren = node.children != null && node.children!.isNotEmpty;
    final isSelected = _currentSelectedIds.contains(node.id);
    
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey('tag_${node.id}'),
        tilePadding: EdgeInsets.only(left: 16 + depth * 16.0, right: 16),
        title: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: widget.activeColor,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _currentSelectedIds.add(node.id);
                  } else {
                    _currentSelectedIds.remove(node.id);
                  }
                  widget.onChanged(_currentSelectedIds);
                });
              },
            ),
            Text(node.title),
          ],
        ),
        initiallyExpanded: hasChildren, // 默认展开以便看到子级
        trailing: hasChildren ? null : const SizedBox.shrink(), // 如果没子级隐藏箭头
        children: hasChildren ? _buildNodes(node.children!, depth + 1) : [],
      ),
    );
  }
}

// --- 复用原有的时间选择器代码 (稍作修改以独立使用) ---
class CustomDateTimePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateTimeChanged;

  const CustomDateTimePicker({
    super.key,
    required this.initialDate,
    required this.onDateTimeChanged,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;
  late int selectedHour;
  late int selectedMinute;

  final int startYear = 2000;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedHour = widget.initialDate.hour;
    selectedMinute = widget.initialDate.minute;

    _yearController = FixedExtentScrollController(initialItem: selectedYear - startYear);
    _monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消', style: TextStyle(color: Colors.grey))),
              const Text('选择时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                   final dt = DateTime(selectedYear, selectedMonth, selectedDay, selectedHour, selectedMinute);
                   widget.onDateTimeChanged(dt);
                }, 
                child: const Text('确定')
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildPicker(_yearController, 50, (i) => setState(() => selectedYear = startYear + i), (i) => '${startYear + i}年'),
              _buildPicker(_monthController, 12, (i) => setState(() => selectedMonth = i + 1), (i) => '${i + 1}月'),
              _buildPicker(_dayController, 31, (i) => setState(() => selectedDay = i + 1), (i) => '${i + 1}日'),
              _buildPicker(_hourController, 24, (i) => setState(() => selectedHour = i), (i) => '${i}时'),
              _buildPicker(_minuteController, 60, (i) => setState(() => selectedMinute = i), (i) => '${i}分'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPicker(FixedExtentScrollController controller, int count, ValueChanged<int> onChanged, String Function(int) label) {
    return Expanded(
      child: CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        itemBuilder: (context, index) => Center(child: Text(label(index), style: const TextStyle(fontSize: 16))),
        childCount: count,
      ),
    );
  }
}