import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/bloc/edit_bill_bloc.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';
import 'package:hjproject/home/edit_bill/view/select_field/category_select_field.dart';
import 'package:hjproject/home/edit_bill/view/select_field/tag_select_field.dart';
import 'package:hjproject/home/edit_bill/widgets/attachment_upload_widget.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/generated/l10n.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/util/app_icon.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

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
            listenWhen: (previous, current) =>
            previous.status != current.status,
            listener: (context, state) {
              if (state.status == EditBillStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(S.current.todosOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<EditBillBloc, EditBillState>(
            listenWhen: (previous, current) =>
            previous.status != current.status,
            listener: (context, state) {
              if (state.status == EditBillStatus.closed) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(state.isNewBill ? '添加成功' : '修改成功'),
                    ),
                  );
                Navigator.of(context).pop();
              }
            },
          ),
          BlocListener<EditBillBloc, EditBillState>(
            listenWhen: (previous, current) =>
            previous.status != current.status,
            listener: (context, state) {
              if (state.status == EditBillStatus.submitFailed) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('添加失败'),
                    ),
                  );
              }
            },
          ),
        ],
        child: BlocListener<EditBillBloc, EditBillState>(
          listenWhen: (previous, current) =>
          previous.status != current.status &&
              current.status == EditBillStatus.success,
          listener: (context, state) => (),
          child: EditBillView(),
        ));
  }
}

class EditBillView extends StatefulWidget {
  EditBillView({super.key});

  @override
  State<EditBillView> createState() => _EditBillViewState();
}

class _EditBillViewState extends State<EditBillView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final ValueNotifier<bool> _isTagExpanded = ValueNotifier(true);
  final ValueNotifier<bool?> _confirm = ValueNotifier(null);
  final ValueNotifier<bool?> _include = ValueNotifier(null);
  final ValueNotifier<String?> _tradeTimeStr = ValueNotifier(null);
  GlobalKey<CategoryTreeWidgetState>? curCategoryKey;
  BillType? _lastCategoryBillType;

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditBillBloc bloc) => bloc.state.status);
    final state = context.select((EditBillBloc bloc) => bloc.state);

    // 强校验：拦截“余额调整”账单进入编辑页（无论是复制还是编辑）
    final bool isEditingOrCopyingAdjust = state.initialBill != null &&
        (BillType.fromValue(state.editBill.data?.billType ?? 1) == BillType.adjust);
    if (isEditingOrCopyingAdjust) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 轻提示并返回上一页，防止通过路由参数直接进入
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('余额调整账单不支持复制或编辑')),
        );
        Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    if (_confirm.value == null || _include.value == null) {
      // 如果是转账类型，则强制设置为 true
      if (curBillType() == BillType.transfer) {
        _confirm.value = true;
        _include.value = true;
        // 同时更新账单数据
        state.editBill.data!.confirm = true;
        state.editBill.data!.include = true;
      } else {
        _confirm.value = state.editBill.data!.confirm;
        _include.value = state.editBill.data!.include;
      }
    } else if (curBillType() == BillType.transfer) {
      // 如果已经初始化过，但当前是转账类型，也要确保值为 true
      _confirm.value = true;
      _include.value = true;
      state.editBill.data!.confirm = true;
      state.editBill.data!.include = true;
    }
    // 初始化备注控制器
    if (state.editBill.data?.remark != null && _remarkController.text.isEmpty) {
      _remarkController.text = state.editBill.data!.remark!;
    }
    print('zctodo 222 = ${state.editBill.data}');
    final isNewBill = context.select(
          (EditBillBloc bloc) => bloc.state.isNewBill,
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: S.current.editTodoSaveButtonTooltip,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed:
        status.isLoadingOrInit ? null : () => _submitBill(state.editBill),
        child: status.isLoadingOrInit
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      appBar: AppBar(
        title: Text(
          isNewBill ? '记一笔' : '编辑账单',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   if (status.isLoadingOrSuccess)
        //     const Padding(
        //       padding: EdgeInsets.all(16.0),
        //       child: CupertinoActivityIndicator(),
        //     )
        //   else
        //     TextButton.icon(
        //       onPressed: _submitBill,
        //       icon: const Icon(Icons.check_circle_outline),
        //       label: const Text('保存'),
        //       style: TextButton.styleFrom(
        //         foregroundColor: theme.colorScheme.primary,
        //       ),
        //     ),
        // ],
      ),
      body: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 账单类型选择器
              _buildBillTypeSelector(),
              // 基本信息
              wrapCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 16),
                    _buildCategorySection(),
                    const SizedBox(height: 8),
                    // 日期时间选择
                    TimeSelector(
                        tradeTimeStr: _tradeTimeStr,
                        context: context,
                        state: state),
                  ],
                ),
              ),
              wrapCard(
                _buildAccountSection(),
              ),
              // 分类选择区域
              // 附加信息区域
              wrapCard(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTagSection(),
                ],
              )),
              wrapCard(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdditionalOptionsSection(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget wrapCard(Widget child) {
    return Card(
        margin: const EdgeInsets.all(8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ));
  }

  BillType curBillType() {
    final state = context.watch<EditBillBloc>().state;
    return BillType.fromValue(state.editBill.data?.billType ?? 1) ??
        BillType.expenditure;
  }

  // 账单类型选择器
  Widget _buildBillTypeSelector() {
    final enable =
        context.watch<EditBillBloc>().state.status != EditBillStatus.loading;
    final billType = curBillType();
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SegmentedButton<BillType>(
        segments: [
          ButtonSegment(
            enabled: enable,
            value: BillType.expenditure,
            label: const Text('支出'),
            icon: const Icon(Icons.arrow_upward),
          ),
          ButtonSegment(
            enabled: enable,
            value: BillType.income,
            label: const Text('收入'),
            icon: const Icon(Icons.arrow_downward),
          ),
          ButtonSegment(
            enabled: enable,
            value: BillType.transfer,
            label: const Text('转账'),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
        selected: {billType},
        onSelectionChanged: (Set<BillType> newSelection) {
          // 如果切换到转账类型，确保"是否确认"和"是否统计"为 true
          if (newSelection.first == BillType.transfer) {
            _confirm.value = true;
            _include.value = true;
            context.read<EditBillBloc>().state.editBill.data?.confirm = true;
            context.read<EditBillBloc>().state.editBill.data?.include = true;
          }
          context
              .read<EditBillBloc>()
              .add(EditBillTypeChange(newSelection.first));
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primaryContainer;
              }
              return Colors.transparent;
            },
          ),
        ),
      ),
    );
  }

  // 基本信息区域
  Widget _buildBasicInfoSection() {
    var state = context.watch<EditBillBloc>().state;
    _titleController.text = state.editBill.data?.title ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '基本信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // 标题输入
        TitleField(titleController: _titleController, state: state),
      ],
    );
  }

  // 账户区域
  Widget _buildAccountSection() {
    if (curBillType() == BillType.transfer) {
      return _buildTransferAccountSection();
    } else {
      return _buildNormalAccountSection();
    }
  }

  // 普通账户选择（支出/收入）
  Widget _buildNormalAccountSection() {
    final state = context.watch<EditBillBloc>().state;
    final items = curBillType() == BillType.income
        ? state.incomeAccountList
        : state.expenseAccountList;
    final payeeItems = state.payeeList;
    // 优先使用账单中的账户ID，如果没有则使用默认账户ID
    final int? accountSelectId = state.editBill.data?.accountId ??
        (curBillType() == BillType.income
            ? state.defaultIncomeAccountId
            : state.defaultExpenseAccountId);
    AccountSelectItem? selectItem;
    for (final item in items) {
      if (item.value.id == accountSelectId) {
        selectItem = item.value;
        break;
      }
    }
    PayeeSelectItem? payeeSelectItem;
    for (final item in payeeItems) {
      if (item.value.id == state.editBill.data?.payeeId) {
        payeeSelectItem = item.value;
        break;
      }
    }
    // 只在原始账户ID为null时设置默认账户ID
    if (state.editBill.data?.accountId == null && selectItem != null) {
      state.editBill.data?.accountId = selectItem.id;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '账户信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // 账户选择
        InkWell(
          onTap: () => _showAccountSelectionDialog(context, items, selectItem, (value) {
            setState(() {
              state.editBill.data?.accountId = value?.id;
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcon.resolve(selectItem?.icon) ??
                      Icons.account_balance_wallet,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  '账户',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  selectItem?.title ?? '请选择账户',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 交易对象选择
        InkWell(
          onTap: () => _showPayeeSelectionDialog(context, payeeItems, payeeSelectItem, (value) {
            setState(() {
              state.editBill.data?.payeeId = value?.id;
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcon.resolve(payeeSelectItem?.icon) ?? Icons.person,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  '交易对象',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  payeeSelectItem?.title ?? '请选择交易对象',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 转账账户选择
  Widget _buildTransferAccountSection() {
    final state = context.watch<EditBillBloc>().state;
    if (state.editBill.data?.amount != null) {
      _amountController.text = (state.editBill.data?.amount ?? 0).toString();
    }
    final inItems = state.transferAccountList;
    final outItems = state.transferOutAccountList;
    AccountSelectItem? selectInItem;
    // 优先使用账单中的账户ID，如果没有则使用默认账户ID
    final int? selectAccountId =
        state.editBill.data?.accountId ?? state.defaultTransferInAccountId;
    final int? selectOutAccountId =
        state.editBill.data?.toAccountId ?? state.defaultTransferOutAccountId;
    for (final item in outItems) {
      if (item.value.id == selectAccountId) {
        selectInItem = item.value;
        break;
      }
    }
    AccountSelectItem? selectOutItem;
    for (final item in inItems) {
      if (item.value.id == selectOutAccountId) {
        selectOutItem = item.value;
        break;
      }
    }
    print(
        'lxjtodo: _buildTransferAccountSection $outItems \n $inItems\n $selectInItem\n $selectOutItem\n $selectAccountId $selectOutAccountId');
    if (state.editBill.data?.accountId == null && selectInItem != null) {
      state.editBill.data?.accountId = selectInItem.id;
    }
    if(state.editBill.data?.toAccountId == null && selectOutItem != null) {
      state.editBill.data?.toAccountId = selectOutItem.id;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '转账信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          onChanged: (value) {
            state.editBill.data?.amount = double.tryParse(value) ?? 0;
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^-?\d*\.?\d{0,5}')), // 允许负号、数字和最多5位小数
          ],
          decoration: InputDecoration(
            hintText: '请输入金额',
            labelText: '金额',
            labelStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
            prefixIcon: const Icon(Icons.monetization_on_outlined),
            // 统一所有状态下的边框样式
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue), // 聚焦状态边框颜色
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red), // 错误状态边框颜色
              borderRadius: BorderRadius.circular(12),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLength: 50,
        ),
        const SizedBox(height: 8),
        // 转入账户选择
        InkWell(
          onTap: () => _showTransferInAccountSelectionDialog(context, inItems, selectOutItem, (value) {
            setState(() {
              state.editBill.data?.toAccountId = value?.id;
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_upward, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  '转入账户',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (AppIcon.resolve(selectOutItem?.icon) != null) ...[
                  Icon(
                    AppIcon.resolve(selectOutItem?.icon),
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  selectOutItem?.title ?? '请选择转入账户',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 转出账户选择
        InkWell(
          onTap: () => _showTransferOutAccountSelectionDialog(context, outItems, selectInItem, (value) {
            setState(() {
              state.editBill.data?.accountId = value?.id;
            });
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_downward, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  '转出账户',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (AppIcon.resolve(selectInItem?.icon) != null) ...[
                  Icon(
                    AppIcon.resolve(selectInItem?.icon),
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  selectInItem?.title ?? '请选择转出账户',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 分类选择区域
  Widget _buildCategorySection() {
    // 转账类型不需要分类
    final billType = curBillType();
    if (billType == BillType.transfer) {
      return const SizedBox.shrink();
    }
    final state = context.watch<EditBillBloc>().state;
    final List<Map<String, num>> curCategroy =
        state.editBill.data?.categoryAmountPair ?? [];
    final Map<int, double> categoryAmountPair = {};
    for (final category in curCategroy) {
      final amount = category["amount"] ?? 0.0;
      final categoryId = category["categoryId"] ?? 0;

      categoryAmountPair[categoryId.toInt()] = amount.toDouble();
    }
    if (curCategoryKey == null || _lastCategoryBillType != billType) {
      curCategoryKey = GlobalKey<CategoryTreeWidgetState>(debugLabel: '${billType}_category');
      _lastCategoryBillType = billType;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '费用',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 分类选择器
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CategoryTreeWidget(
                key: curCategoryKey,
                categoryAmountPairs: categoryAmountPair,
                categories: state.categoryList,
                billType: billType,
                onCategorySelected: (categorys) {
                  fetchAmountList(categorys, state.editBill);
                }),
          ),
        ),
      ],
    );
  }

  void fetchAmountList(Map<int, double>? categorys, BillItemAdd editBill) {
    if (categorys == null || categorys.isEmpty) {
      return;
    }
    final List<Map<String, num>> categoryAmountPairList = [];
    categorys.forEach((categoryId, categoryAmount) {
      categoryAmountPairList
          .add({"categoryId": categoryId, "amount": categoryAmount});
    });
    editBill.data?.categoryAmountPair = categoryAmountPairList;
  }

  // 快速选择常用分类
  Widget _buildQuickCategorySelector() {
    BillType billType = curBillType();
    // 这里可以根据用户的使用频率或者预设的常用分类来显示
    List<Map<String, dynamic>> quickCategories = [];

    if (billType == BillType.expenditure) {
      quickCategories = [
        {'name': '餐饮', 'icon': Icons.restaurant},
        {'name': '交通', 'icon': Icons.directions_car},
        {'name': '购物', 'icon': Icons.shopping_bag},
        {'name': '娱乐', 'icon': Icons.movie},
        {'name': '日用', 'icon': Icons.home},
      ];
    } else if (billType == BillType.income) {
      quickCategories = [
        {'name': '工资', 'icon': Icons.work},
        {'name': '奖金', 'icon': Icons.card_giftcard},
        {'name': '理财', 'icon': Icons.account_balance},
        {'name': '报销', 'icon': Icons.receipt},
        {'name': '其他', 'icon': Icons.more_horiz},
      ];
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickCategories.length,
        itemBuilder: (context, index) {
          final category = quickCategories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    // 选择该分类的逻辑
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData?,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category['name'] as String? ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 标签选择区域
  Widget _buildTagSection() {
    var state = context.watch<EditBillBloc>().state;
    return ValueListenableBuilder(
        valueListenable: _isTagExpanded,
        builder: (b, expanded, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    _isTagExpanded.value = !expanded;
                  },
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '标签',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      expanded
                          ? Icon(Icons.expand_more)
                          : Icon(Icons.expand_less),
                    ],
                  )),
              const SizedBox(height: 16),
              Visibility(
                visible: !expanded,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TagTreeSelection(
                        key: Key('${curBillType()}_tag'),
                        selectedTagIds: state.editBill.data?.tagIdList ?? [],
                        tags: state.tagList,
                        onTagSelected: (tags) {
                          state.editBill.data?.tagIdList = tags;
                        }),
                  ),
                ),
              )
            ],
          );
        });
  }

  // 附加选项区域
  Widget _buildAdditionalOptionsSection() {
    var state = context.watch<EditBillBloc>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '附加信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 是否确认
        ValueListenableBuilder(
            valueListenable: _confirm,
            builder: (_, confirm, __) {
              // 转账类型时，"是否确认"开关不可修改且保持开启状态
              final isTransfer = curBillType() == BillType.transfer;
              return SwitchListTile(
                title: const Text('是否确认'),
                subtitle: const Text('确认后将会扣除对应账户金额'),
                value: isTransfer ? true : (confirm ?? true),
                onChanged: isTransfer ? null : (value) {
                  state.editBill.data?.confirm = value;
                  _confirm.value = value;
                },
                secondary: const Icon(Icons.verified),
                contentPadding: EdgeInsets.zero,
              );
            }),
        ValueListenableBuilder(
            valueListenable: _include,
            builder: (_, include, __) {
              // 转账类型时，"是否统计"开关不可修改且保持开启状态
              final isTransfer = curBillType() == BillType.transfer;
              return SwitchListTile(
                title: const Text('是否统计'),
                subtitle: const Text('纳入统计的账单会在报表中显示'),
                value: isTransfer ? true : (include ?? true),
                onChanged: isTransfer ? null : (value) {
                  state.editBill.data?.include = value;
                  _include.value = value;
                },
                secondary: const Icon(Icons.bar_chart),
                contentPadding: EdgeInsets.zero,
              );
            }),

        const SizedBox(height: 16),

        // 备注
        TextField(
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          controller: _remarkController,
          onChanged: (value) {
            state.editBill.data?.remark = value;
          },
          decoration: InputDecoration(
            labelText: '备注',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 2,
          maxLength: 300,
        ),

        const SizedBox(height: 24),

        const SizedBox(height: 16),
        AttachmentUploadWidget(
          initialAttachments: state.attachments,
          onAttachmentsChanged: (attachments) {
            context.read<EditBillBloc>().add(EditBillAttachmentsChanged(attachments));
          },
        ),
      ],
    );
  }

  // 提交账单
  void _submitBill(BillItemAdd billItemAdd) {
    // 验证必填字段
    print('lxjtodo: _submitBill $billItemAdd');
    if (!(billItemAdd.data!.title?.isNotEmpty == true)) {
      billItemAdd.data!.title = '未命名账单';
    }
    if (billItemAdd.data?.billType == BillType.transfer.value) {
      if (billItemAdd.data!.amount == null || billItemAdd.data!.amount == 0) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请填入非零金额')),
        );
        return;
      }
    } else {
      if (!(billItemAdd.data?.categoryAmountPair?.isNotEmpty == true)) {
        fetchAmountList(curCategoryKey?.currentState?.categorys(), billItemAdd);
        if (!(billItemAdd.data?.categoryAmountPair?.isNotEmpty == true)) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请填入费用或类型')),
          );
          return;
        }
      }
    }

    if (billItemAdd.data?.billType == BillType.transfer.value) {
      // 转账类型
      if (billItemAdd.data?.accountId == null ||
          billItemAdd.data?.toAccountId == null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择转账账户')),
        );
        return;
      }
    }
    context.read<EditBillBloc>().add(EditBillSubmitted());
  }
}

class TimeSelector extends StatelessWidget {
  const TimeSelector({
    super.key,
    required ValueNotifier<String?> tradeTimeStr,
    required this.context,
    required this.state,
  }) : _tradeTimeStr = tradeTimeStr;

  final ValueNotifier<String?> _tradeTimeStr;
  final BuildContext context;
  final EditBillState state;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _tradeTimeStr,
        builder: (_, value, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '时间',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _showCustomDateTimePicker(context, value),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Text(
                        '日期时间',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        state.editBill.data?.tradeTime ??
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showCustomDateTimePicker(BuildContext context, String? currentValue) {
    DateTime initialDate = currentValue != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(currentValue)
        : DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return CustomDateTimePicker(
              initialDate: initialDate,
              onDateTimeChanged: (DateTime selectedDateTime) {
                _tradeTimeStr.value =
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime);
                state.editBill.data?.tradeTime = _tradeTimeStr.value;
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

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
  final int endYear = DateTime.now().year + 25;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;
    selectedHour = widget.initialDate.hour;
    selectedMinute = widget.initialDate.minute;

    _yearController = FixedExtentScrollController(
      initialItem: selectedYear - startYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: selectedDay - 1,
    );
    _hourController = FixedExtentScrollController(
      initialItem: selectedHour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );
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

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _updateDay() {
    final daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
    if (selectedDay > daysInMonth) {
      selectedDay = daysInMonth;
      _dayController.animateToItem(
        selectedDay - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部标题栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  '取消',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const Expanded(
                child: Text(
                  '选择日期时间',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final selectedDateTime = DateTime(
                    selectedYear,
                    selectedMonth,
                    selectedDay,
                    selectedHour,
                    selectedMinute,
                  );
                  widget.onDateTimeChanged(selectedDateTime);
                },
                child: const Text(
                  '确定',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        // 滚动选择器
        Expanded(
          child: Row(
            children: [
              // 年份选择器
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('年', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _yearController,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedYear = startYear + index;
                            _updateDay();
                          });
                        },
                        children: List.generate(
                          endYear - startYear + 1,
                          (index) => Center(
                            child: Text(
                              '${startYear + index}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 月份选择器
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('月', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _monthController,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMonth = index + 1;
                            _updateDay();
                          });
                        },
                        children: List.generate(
                          12,
                          (index) => Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 日期选择器
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _dayController,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedDay = index + 1;
                          });
                        },
                        children: List.generate(
                          _getDaysInMonth(selectedYear, selectedMonth),
                          (index) => Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 小时选择器
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('时', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _hourController,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedHour = index;
                          });
                        },
                        children: List.generate(
                          24,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 分钟选择器
              Expanded(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _minuteController,
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMinute = index;
                          });
                        },
                        children: List.generate(
                          60,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TitleField extends StatelessWidget {
  const TitleField({
    super.key,
    required TextEditingController titleController,
    required this.state,
  }) : _titleController = titleController;

  final TextEditingController _titleController;
  final EditBillState state;

  @override
  Widget build(BuildContext context) {
    return TextField(
      // lxjtodo:
      controller: _titleController,
      onChanged: (value) {
        state.editBill.data?.title = value;
      },
      decoration: InputDecoration(
        hintText: '请输入标题',
        labelText: '标题',
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 16,
        ),
        prefixIcon: const Icon(Icons.title),
        // 统一所有状态下的边框样式
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue), // 聚焦状态边框颜色
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // 错误状态边框颜色
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLength: 50,
    );
  }
}

// 显示账户选择弹窗
  void _showAccountSelectionDialog(
    BuildContext context,
    List<DropdownItem<AccountSelectItem>> items,
    AccountSelectItem? currentItem,
    Function(AccountSelectItem?) onSelected,
  ) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可选账户')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '选择账户',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // 列表内容
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentItem?.id == item.value.id;
                      final IconData? itemIcon =
                          AppIcon.resolve(item.value.icon);
                      return ListTile(
                        leading: itemIcon == null ? null : Icon(itemIcon),
                        title: Text(item.label),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(item.value);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 显示交易对象选择弹窗
  void _showPayeeSelectionDialog(
    BuildContext context,
    List<DropdownItem<PayeeSelectItem>> items,
    PayeeSelectItem? currentItem,
    Function(PayeeSelectItem?) onSelected,
  ) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可选交易对象')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '选择交易对象',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // 列表内容
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentItem?.id == item.value.id;
                      final IconData? itemIcon =
                          AppIcon.resolve(item.value.icon);
                      return ListTile(
                        leading: itemIcon == null ? null : Icon(itemIcon),
                        title: Text(item.label),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(item.value);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// 显示转入账户选择弹窗
  void _showTransferInAccountSelectionDialog(
    BuildContext context,
    List<DropdownItem<AccountSelectItem>> items,
    AccountSelectItem? currentItem,
    Function(AccountSelectItem?) onSelected,
  ) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可选转入账户')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '选择转入账户',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // 列表内容
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentItem?.id == item.value.id;
                      final IconData? itemIcon =
                          AppIcon.resolve(item.value.icon);
                      return ListTile(
                        leading: itemIcon == null ? null : Icon(itemIcon),
                        title: Text(item.label),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(item.value);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 显示转出账户选择弹窗
  void _showTransferOutAccountSelectionDialog(
    BuildContext context,
    List<DropdownItem<AccountSelectItem>> items,
    AccountSelectItem? currentItem,
    Function(AccountSelectItem?) onSelected,
  ) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无可选转出账户')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '选择转出账户',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // 列表内容
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = currentItem?.id == item.value.id;
                      final IconData? itemIcon =
                          AppIcon.resolve(item.value.icon);
                      return ListTile(
                        leading: itemIcon == null ? null : Icon(itemIcon),
                        title: Text(item.label),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSelected(item.value);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
