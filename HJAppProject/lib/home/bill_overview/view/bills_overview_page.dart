import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/edit_bill/view/edit_bill_page.dart';
import 'package:hjproject/home/stats/view/stats_page.dart';
import 'package:hjproject/home/theme/theme.dart';
import 'package:hjproject/home/bill_overview/bloc/bills_overview_bloc.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/home/bill_overview/view/bill_detail_sheet.dart';
import 'package:hjproject/home/bill_overview/view/bill_list_tile.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../generated/l10n.dart';

class BillsOverviewPage extends StatelessWidget {
  const BillsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BillsOverviewBloc(
        billsRepository: context.read<BillsRepository>(),
      )..add(const BillsOverviewSubscriptionRequested()),
      child: const BillsOverviewView(),
    );
  }
}

class BillsOverviewView extends StatefulWidget {
  const BillsOverviewView({super.key});

  @override
  State<BillsOverviewView> createState() => _BillsOverviewViewState();
}

class _BillsOverviewViewState extends State<BillsOverviewView>
    with SingleTickerProviderStateMixin {
  DateTime? _currentGroupDate;
  final Map<String, GlobalKey> _groupKeys = {};
  List<DateTime> _groupDates = [];
  late TabController _tabController;
  final List<String> _tabs = ['日', '周', '月', '年'];
  // final List<String> _tabs = ['日', '周', '月', '年'];
  int _selectedFilterIndex = 0; // 当前选中的筛选索引
  final List<Map<String, dynamic>> _filters = [
    {'name': '全部', 'icon': Icons.all_inclusive, 'color': null},
    {'name': '收入', 'icon': Icons.arrow_downward, 'color': Colors.green},
    {'name': '支出', 'icon': Icons.arrow_upward, 'color': Colors.red},
    {'name': '转账', 'icon': Icons.swap_horiz, 'color': Colors.blue},
    {'name': '调整', 'icon': Icons.settings, 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.current.todosOverviewAppBarTitle,
            style: Theme.of(context).appBarTheme.titleTextStyle),
        // bottom: PreferredSize( // TODO：时间范围选择
        //   preferredSize: const Size.fromHeight(48),
        //   child: Container(
        //     color: Theme.of(context).appBarTheme.backgroundColor,
        //     child: TabBar(
        //       controller: _tabController,
        //       tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        //       indicatorColor: Theme.of(context).primaryColor,
        //       labelColor: Theme.of(context).primaryColor,
        //       unselectedLabelColor: Colors.grey,
        //       indicatorSize: TabBarIndicatorSize.label,
        //       onTap: (index) {
        //         // 可以在这里处理不同时间范围的数据加载
        //       },
        //     ),
        //   ),
        // ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.filter_list),
          //   tooltip: S.current.todosOverviewFilterTooltip,
          //   onPressed: () {
          //     // 显示筛选选项
          //     _showFilterOptions(context);
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     // 实现搜索功能
          //     _showSearchDialog(context);
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.add_chart_sharp),
            onPressed: () {
              // 实现搜索功能
              Navigator.of(context).push(StatsPage.route());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(context),
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<BillsOverviewBloc, BillsOverviewState>(
                  listenWhen: (previous, current) =>
                      previous.status != current.status,
                  listener: (context, state) {
                    if (state.status == BillsOverviewStatus.failure) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content:
                                Text(S.current.todosOverviewErrorSnackbarText),
                            backgroundColor: Colors.red,
                          ),
                        );
                    }
                  },
                ),
                BlocListener<BillsOverviewBloc, BillsOverviewState>(
                  listenWhen: (previous, current) =>
                      previous.lastDeletedBill != current.lastDeletedBill &&
                      current.lastDeletedBill != null,
                  listener: (context, state) {
                    final deletedBill = state.lastDeletedBill!;
                    final messenger = ScaffoldMessenger.of(context);
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            S.current.todosOverviewTodoDeletedSnackbarText(
                              deletedBill.title ?? '',
                            ),
                          ),
                          action: SnackBarAction(
                            label:
                                S.current.todosOverviewUndoDeletionButtonText,
                            onPressed: () {
                              messenger.hideCurrentSnackBar();
                              context.read<BillsOverviewBloc>().add(
                                  const BillsOverviewUndoDeletionRequested());
                            },
                          ),
                        ),
                      );
                  },
                ),
              ],
              child: BlocBuilder<BillsOverviewBloc, BillsOverviewState>(
                builder: (context, state) {
                  print('🔍 DEBUG: UI构建 - status: ${state.status}, bills数量: ${state.bills?.length ?? 0}');
                  print('🔍 DEBUG: UI构建 - statistics: income=${state.statistics?.income}, expense=${state.statistics?.expense}');
                  if (!(state.bills?.isNotEmpty == true)) {
                    print('🔍 DEBUG: UI显示空状态或加载状态');
                    if (state.status == BillsOverviewStatus.loading) {
                      return const Center(child: CupertinoActivityIndicator());
                    } else if (state.status != BillsOverviewStatus.success) {
                      return const SizedBox();
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.current.todosOverviewEmptyText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                  }

                  final bills = state.bills ?? [];
                  // 按日期分组
                  final Map<String, List<BillItem>> grouped = {};
                  final Map<String, DateTime> groupDateMap = {};
                  for (var bill in bills) {
                    final date = DateTime(
                      bill.tradeTime!.year,
                      bill.tradeTime!.month,
                      bill.tradeTime!.day,
                    );
                    final key = _dateKey(date);
                    groupDateMap[key] = date;
                    grouped.putIfAbsent(key, () => []).add(bill);
                  }
                  _groupDates = groupDateMap.values.toList()
                    ..sort((a, b) => b.compareTo(a));
                  // 初始化当前分组日期
                  if (_currentGroupDate == null && _groupDates.isNotEmpty) {
                    _currentGroupDate = _groupDates.first;
                  }

                  final groupKeys = _groupDates
                      .map((d) => _groupKeys.putIfAbsent(
                          _dateKey(d), () => GlobalKey()))
                      .toList();

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateCurrentGroupDate(context));
                      // 上拉触底加载更多
                      if (notification is ScrollEndNotification &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 50) {
                        if (!state.isLoadingMore && state.hasMore) {
                          context
                              .read<BillsOverviewBloc>()
                              .add(const BillsOverviewLoadMoreRequested());
                        }
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<BillsOverviewBloc>()
                            .add(const BillsOverviewLoadLastRequested());
                      },
                      child: ListView.builder(
                        itemCount: _groupDates.length + 1, // +1 for footer
                        itemBuilder: (context, groupIdx) {
                          if (groupIdx == _groupDates.length) {
                            // footer
                            return _buildFooterWidget(state);
                          }
                          final date = _groupDates[groupIdx];
                          final key = _groupKeys[_dateKey(date)]!;
                          final billsInGroup = grouped[_dateKey(date)] ?? [];

                          // 计算当日收支总额
                          double dayIncome = 0;
                          double dayExpense = 0;
                          for (var bill in billsInGroup) {
                            if (bill.billType == BillType.income) {
                              dayIncome += bill.convertedAmount ?? 0;
                            } else if (bill.billType == BillType.expenditure) {
                              dayExpense += bill.convertedAmount ?? 0;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _getGroupSeparator(
                                  context, date, key, dayIncome, dayExpense),
                              ...billsInGroup
                                  .map((bill) => BillListTile(
                                        bill: bill,
                                        onTap: () {
                                          // 点击账单项跳转到详情页
                                          _showBillDetails(context, bill);
                                        },
                                        onCopy: () {
                                          // 余额调整账单不允许复制：直接提示并阻断
                                          if (bill.billType == BillType.adjust) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('余额调整账单不支持复制或修改')),
                                            );
                                            return;
                                          }
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('账单已复制，请修改后保存')),
                                          );
                                          Navigator.of(context).push(
                                              EditBillPage.route(
                                                  initialBill:
                                                          BillItemAdd.fromBillItem(
                                                              bill),
                                                  isCopyBill: true));
                                        },
                                        onDismissed: (direction) {
                                          // 实现左滑删除功能
                                          // 这里需要添加删除账单的逻辑
                                          context.read<BillsOverviewBloc>().add(
                                              BillsOverviewDeleteRequested(
                                                  bill.billId!));
                                        },
                                      ))
                                  .toList(),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 添加新账单
      //     Navigator.of(context).pushNamed('/edit-bill');
      //   },
      //   child: const Icon(Icons.add),
      //   tooltip: '添加账单',
      // ),
    );
  }

  // 更新当前分组日期
  void _updateCurrentGroupDate(BuildContext context) {
    if (_groupDates.isEmpty) return;
    RenderBox? listBox = context.findRenderObject() as RenderBox?;
    if (listBox == null) return;
    double listTop = listBox.localToGlobal(Offset.zero).dy;

    DateTime? newGroup;
    for (var date in _groupDates) {
      final key = _groupKeys[_dateKey(date)];
      if (key == null) continue;
      final ctx = key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final offset = box.localToGlobal(Offset.zero).dy - listTop;
      if (offset <= 0) {
        newGroup = date;
      } else {
        break;
      }
    }
    if (newGroup != null && newGroup != _currentGroupDate) {
      setState(() {
        _currentGroupDate = newGroup;
      });
    }
  }

  // 日期格式化为字符串键
  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // 构建底部加载更多组件
  Widget _buildFooterWidget(BillsOverviewState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 32),
        height: 56,
        child: state.isLoadingMore
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 1.5))
            : !state.hasMore
                ? Text(
                    '我是有底线的',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  // 构建顶部汇总卡片
  Widget _buildSummaryCard(BuildContext context) {
    return BlocBuilder<BillsOverviewBloc, BillsOverviewState>(
      builder: (context, state) {
        if (state.status != BillsOverviewStatus.success ||
            state.bills == null) {
          return const SizedBox.shrink();
        }

        // 计算本月收支
        final now = state.statistics?.staticTime ?? DateTime.now();
        // final currentMonth = DateTime(now.year, now.month);
        double monthIncome = state.statistics?.income ?? 0;
        double monthExpense = state.statistics?.expense ?? 0;

        return Column(
          children: [
            // 月度汇总卡片
            Card(
              margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${now.year}年${now.month}月收支',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.bar_chart, size: 16),
                          label: const Text('设置结算日'),
                          onPressed: () async {
                            // 跳转到月度报表
                            final currentValue = context
                                    .read<BillsRepository>()
                                    .billStatisticsDay() ??
                                1;
                            final newValue = await showDialog<String>(
                              context: context,
                              builder: (context) => EditValueDialog(
                                  currentValue: currentValue.toString()),
                            );
                            if (newValue != null) {
                              context.read<BillsOverviewBloc>().add(
                                  BillsOverviewRefreshStatisticsDayChanged(
                                      int.parse(newValue)));
                              print('lxjtodo 用户输入的新值: $newValue'); // 处理新值
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('收入', monthIncome, Colors.green),
                        _buildSummaryItem('支出', monthExpense, Colors.red),
                        _buildSummaryItem(
                            '结余',
                            monthIncome - monthExpense,
                            (monthIncome - monthExpense) >= 0
                                ? Colors.blue
                                : Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 预算进度卡片 隐藏预算逻辑 TODO
            // Card(
            //   margin: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            //   elevation: 2.0,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12.0),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             const Text(
            //               '本月预算',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '¥${monthExpense.toStringAsFixed(2)} / ¥${monthlyBudget.toStringAsFixed(0)}',
            //               style: TextStyle(
            //                 fontSize: 14,
            //                 color: isOverBudget ? Colors.red : Colors.grey[700],
            //                 fontWeight: isOverBudget
            //                     ? FontWeight.bold
            //                     : FontWeight.normal,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 8),
            //         ClipRRect(
            //           borderRadius: BorderRadius.circular(4),
            //           child: LinearProgressIndicator(
            //             value: (monthExpense / monthlyBudget).clamp(0.0, 1.0),
            //             backgroundColor: Colors.grey[200],
            //             color: isOverBudget
            //                 ? Colors.red
            //                 : budgetUsedPercentage > 80
            //                     ? Colors.orange
            //                     : Colors.green,
            //             minHeight: 8,
            //           ),
            //         ),
            //         const SizedBox(height: 8),
            //         Text(
            //           isOverBudget
            //               ? '已超出预算 ¥${(monthExpense - monthlyBudget).toStringAsFixed(2)}'
            //               : '剩余预算 ¥${(monthlyBudget - monthExpense).toStringAsFixed(2)}',
            //           style: TextStyle(
            //             fontSize: 12,
            //             color: isOverBudget ? Colors.red : Colors.grey[600],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // 快速筛选按钮
            // SizedBox(
            //   height: 50,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //     itemCount: _filters.length,
            //     itemBuilder: (context, index) {
            //       final filter = _filters[index];
            //       final isSelected = _selectedFilterIndex == index;

            //       return Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 4.0),
            //         child: ChoiceChip(
            //           label: Text(filter['name'] as String),
            //           selected: isSelected,
            //           avatar: Icon(
            //             filter['icon'] as IconData,
            //             size: 16,
            //             color: isSelected
            //                 ? Colors.white
            //                 : filter['color'] as Color? ?? Colors.grey[700],
            //           ),
            //           selectedColor: Theme.of(context).primaryColor,
            //           backgroundColor: Colors.grey[100],
            //           labelStyle: TextStyle(
            //             color: isSelected ? Colors.white : Colors.black,
            //           ),
            //           onSelected: (selected) {
            //             if (selected) {
            //               setState(() {
            //                 _selectedFilterIndex = index;
            //               });
            //               // 应用筛选逻辑
            //             }
            //           },
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        );
      },
    );
  }

  // 构建汇总项
  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // 构建日期分组标题
  Widget _getGroupSeparator(BuildContext context, DateTime date, Key key,
      double income, double expense) {
    // 使用更符合中国人习惯的日期格式
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String dateText;
    String weekdayText;
    final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    weekdayText = weekdays[date.weekday % 7];

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      dateText = '今天';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      dateText = '昨天';
    } else if (date.year == now.year) {
      // 同年只显示月日
      dateText = '${date.month}月${date.day}日';
    } else {
      // 不同年显示年月日
      dateText = '${date.year}年${date.month}月${date.day}日';
    }

    // 计算日收支差额
    final double dayBalance = income - expense;

    return VisibilityDetector(
        key: ValueKey(key),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction == 1.0) {
            print('lxjtodo: $date');
            context
                .read<BillsOverviewBloc>()
                .add(BillsOverviewRefreshStatisticsRequested(date));
          }
        },
        child: Container(
          key: key,
          margin: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 4.0,
              ),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // 日期部分
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        weekdayText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 收支信息
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (income > 0) ...[
                          const Icon(
                            Icons.arrow_downward,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '¥${income.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                        if (income > 0 && expense > 0)
                          const SizedBox(width: 12),
                        if (expense > 0) ...[
                          const Icon(
                            Icons.arrow_upward,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '¥${expense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (income > 0 || expense > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '结余: ${dayBalance >= 0 ? '+' : ''}¥${dayBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: dayBalance >= 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  // 显示筛选选项
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '筛选账单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _buildFilterOption(context, '全部', Icons.all_inclusive),
              _buildFilterOption(context, '收入', Icons.arrow_downward,
                  color: Colors.green),
              _buildFilterOption(context, '支出', Icons.arrow_upward,
                  color: Colors.red),
              _buildFilterOption(context, '转账', Icons.swap_horiz,
                  color: Colors.blue),
              _buildFilterOption(context, '余额调整', Icons.settings,
                  color: Colors.orange),
            ],
          ),
        );
      },
    );
  }

  // 构建筛选选项
  Widget _buildFilterOption(BuildContext context, String title, IconData icon,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // 应用筛选
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('敬请期待...')),
        );
      },
    );
  }

  // 显示搜索对话框
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('搜索账单'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: '输入关键词搜索',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('敬请期待...')),
              );
              // 执行搜索
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 执行搜索
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('敬请期待...')),
                );
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }

  // 显示账单详情
  void _showBillDetails(BuildContext context, BillItem bill) {
    var overViewState = context.read<BillsOverviewBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BillDetailSheet(
          billItem: bill,
          deleteBk: () {
            Navigator.pop(context);
            // 显示删除确认对话框
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定要删除这条账单记录吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      overViewState
                          .add(BillsOverviewDeleteRequested(bill.billId!));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('删除'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EditValueDialog extends StatefulWidget {
  final String currentValue; // 当前值

  const EditValueDialog({super.key, required this.currentValue});

  @override
  State<EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 初始化控制器，预填充当前值
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose(); // 销毁控制器避免内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('每月结算日'),
      content: Column(
        mainAxisSize: MainAxisSize.min, // 自适应高度
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前每月: ${widget.currentValue} 日'), // 展示当前值
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // 只允许输入数字[4,7](@ref)
              _IntegerRangeFormatter(min: 1, max: 31), // 自定义范围限制
            ],
            autofocus: true, // 自动聚焦到输入框
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '输入新值',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // 取消关闭弹窗
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text); // 确认并返回新值
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}

// 自定义范围过滤器（处理边界值）
class _IntegerRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _IntegerRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // 处理非法输入（如非数字）
    final num = int.tryParse(newValue.text);
    if (num == null) return oldValue;

    // 自动修正边界
    int correctedValue = num;
    if (num < min) correctedValue = min;
    if (num > max) correctedValue = max;

    // 返回修正后的值
    return TextEditingValue(
      text: correctedValue.toString(),
      selection:
          TextSelection.collapsed(offset: correctedValue.toString().length),
    );
  }
}
