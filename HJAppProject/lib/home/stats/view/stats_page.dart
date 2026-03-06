import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/home/setting_page/bloc/setting_bloc.dart';
import 'package:hjproject/home/stats/bloc/bills_stats_bloc.dart';
import 'package:hjproject/home/stats/models/bill_stats_chart_EI.dart';
import 'package:hjproject/home/stats/models/bill_stats_classification.dart';
import 'package:hjproject/home/bill_overview/models/bill_statistics.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import '../../../generated/l10n.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => BlocProvider(
          create: (context) => BillsStatsBloc(
            billsRepository: context.read<BillsRepository>(),
          )..add(BillsStatsRequested()),
          child: const StatsView(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SettingBloc(billsRepository: context.read<BillsRepository>()),
      child: const StatsView(),
    );
  }
}

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['收支趋势', '收入分析', '支出分析' /** lxjtodo, '资产负债'*/];
  int _selectedTimeRange = 1; // 0: 周, 1: 月, 2: 年
  final List<String> _timeRanges = ['周', '月', '年'];
  var maxValue = 0.0;
  // 交互状态：饼图与柱状图的触摸选择
  int? _pieSelectedIndex;
  Offset? _pieTooltipPos;
  int? _barSelectedGroup;
  Offset? _barTooltipPos;

  // 颜色解析：统一使用高饱和度的 Material 主色系，尽量不使用自定义颜色
  Color _resolveCategoryColor(int index, BillStatsClassification item) {
    final material = Colors.primaries[index % Colors.primaries.length];
    return material.shade700 ?? material.shade600 ?? material;
  }

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.statsAppBarTitle),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.all(0),
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          isScrollable: true,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
        actions: [
          _buildTimeRangeSelector(),
        ],
      ),
      body: BlocBuilder<BillsStatsBloc, BillsStatsState>(
        builder: (context, state) {
          if (state.status == BillsStatsStatus.loading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state.status != BillsStatsStatus.success) {
            return const SizedBox();
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTrendsTab(context, state.statistics, state.incomeList,
                    state.expenseList),
                _buildIncomeAnalysisTab(context, state.incomeCategarys),
                _buildExpenseAnalysisTab(context, state.expenseCategarys),
                // _buildAssetsLiabilitiesTab(context),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('近6月'));
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //   child: DropdownButton<int>(
    //     value: _selectedTimeRange,
    //     underline: Container(),
    //     icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
    //     style: TextStyle(
    //         color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
    //     dropdownColor: Theme.of(context).cardColor,
    //     items: List.generate(_timeRanges.length, (index) {
    //       return DropdownMenuItem(
    //         value: index,
    //         child: Text(_timeRanges[index],
    //             style: TextStyle(
    //               color: index == _selectedTimeRange
    //                   ? Theme.of(context).primaryColor
    //                   : Colors.grey[700],
    //             )),
    //       );
    //     }),
    //     onChanged: (value) {
    //       if (value != null) {
    //         setState(() {
    //           _selectedTimeRange = value;
    //         });
    //       }
    //     },
    //   ),
    // );
  }

  Widget _buildTrendsTab(
      BuildContext context,
      BillStatistics? statistics,
      List<BillStatsChartEi> incomeTrends,
      List<BillStatsChartEi> expenseTrends) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, statistics),
          const SizedBox(height: 24),
          Text(
            '收支趋势图',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildSimpleLineChart(context, incomeTrends, expenseTrends),
          // const SizedBox(height: 24),
          // _buildCompletionStats(context),
        ],
      ),
    );
  }

  Widget _buildIncomeAnalysisTab(
      BuildContext context, List<BillStatsClassification> incomeCategarys) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '收入分类占比',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSimplePieChart(
            context,
            incomeCategarys,
          ),
          const SizedBox(height: 24),
          _buildCategoryList(
            context,
            incomeCategarys,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseAnalysisTab(
      BuildContext context, List<BillStatsClassification> expenseCategarys) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支出分类占比',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSimplePieChart(
            context,
            expenseCategarys,
          ),
          const SizedBox(height: 24),
          _buildCategoryList(
            context,
            expenseCategarys,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsLiabilitiesTab(BuildContext context) {
    // 模拟数据 - 实际应用中应从API获取
    final double totalAssets = 120000.0;
    final double totalLiabilities = 45000.0;
    final double netWorth = totalAssets - totalLiabilities;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '净资产',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥${NumberFormat('#,##0.00').format(netWorth)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: netWorth >= 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAssetLiabilityRow(
                    context,
                    '总资产',
                    totalAssets,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                  const SizedBox(height: 16),
                  _buildAssetLiabilityRow(
                    context,
                    '总负债',
                    totalLiabilities,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '资产分布',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAssetsList(context),
          const SizedBox(height: 24),
          Text(
            '负债分布',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildLiabilitiesList(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, BillStatistics? statistics) {
    // 模拟数据 - 实际应用中应从API获取
    final double monthlyIncome = statistics?.income ?? 0.0;
    final double monthlyExpense = statistics?.expense ?? 0.0;
    final double monthlyBalance = monthlyIncome - monthlyExpense;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '半年收支概览',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(context, '收入', monthlyIncome, Colors.green),
                _buildSummaryItem(context, '支出', monthlyExpense, Colors.red),
                _buildSummaryItem(
                  context,
                  '结余',
                  monthlyBalance,
                  monthlyBalance >= 0 ? Colors.blue : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String label, double amount, Color color) {
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
          '¥${NumberFormat('#,##0.00').format(amount)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleLineChart(
      BuildContext context,
      List<BillStatsChartEi> incomeTrends,
      List<BillStatsChartEi> expenseTrends) {
    // 简单的图表替代，不使用fl_chart库
    List<Widget> children = [];
    maxValue = 0.0;
    incomeTrends.forEach((ele) {
      maxValue = max(ele.value ?? 0.0, maxValue);
    });
    expenseTrends.forEach((ele) {
      maxValue = max(ele.value ?? 0.0, maxValue);
    });
    for (var j = 0; j < 6; j++) {
      final idx = incomeTrends.length - 6 + j;
      final name = incomeTrends[idx].name ?? '${j + 1}月';
      final inc = incomeTrends[idx].value ?? 0;
      final exp = expenseTrends[idx].value ?? 0;
      children.add(_buildBarGroup(
        context,
        name,
        inc,
        exp,
        Colors.green,
        Colors.red,
        highlighted: _barSelectedGroup == j,
      ));
    }
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final dx = details.localPosition.dx;
                    final groupCount = 6;
                    final perGroupWidth = constraints.maxWidth / groupCount;
                    int g = dx ~/ perGroupWidth;
                    if (g < 0) g = 0;
                    if (g > groupCount - 1) g = groupCount - 1;
                    setState(() {
                      _barSelectedGroup = g;
                      _barTooltipPos = details.localPosition;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: children,
                      ),
                      if (_barSelectedGroup != null && incomeTrends.isNotEmpty && expenseTrends.isNotEmpty)
                        Positioned(
                          left: max(0.0, min((_barTooltipPos?.dx ?? 0) - 60, constraints.maxWidth - 120)),
                          top: max(0.0, min((_barTooltipPos?.dy ?? 0) - 50, constraints.maxHeight - 80)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Builder(
                              builder: (context) {
                                const groupCount = 6;
                                final baseIndex = incomeTrends.length - groupCount;
                                int idx = baseIndex + (_barSelectedGroup ?? 0);
                                if (idx < 0) idx = 0;
                                if (idx > incomeTrends.length - 1) idx = incomeTrends.length - 1;
                                final name = incomeTrends[idx].name ?? '';
                                final inc = incomeTrends[idx].value ?? 0;
                                final exp = expenseTrends[idx].value ?? 0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('收入: ¥${NumberFormat('#,##0.00').format(inc)}', style: const TextStyle(color: Colors.white)),
                                    Text('支出: ¥${NumberFormat('#,##0.00').format(exp)}', style: const TextStyle(color: Colors.white)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('收入'),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('支出'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup(BuildContext context, String label, double income,
      double expense, Color incomeColor, Color expenseColor, {bool highlighted = false}) {
    // 图表最大值
    final incomeHeight = (income / maxValue) * 200; // 200是图表高度
    final expenseHeight = (expense / maxValue) * 200;
    print('lxjtodo draw: $incomeHeight, $expenseHeight');
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: highlighted
                ? BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(6),
            )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: highlighted ? 18 : 15,
                  height: incomeHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: incomeColor,
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                Container(
                  width: highlighted ? 18 : 15,
                  height: expenseHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: expenseColor,
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePieChart(
      BuildContext context, List<BillStatsClassification> categarys) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (categarys.isEmpty) {
                  return const Center(child: Text('暂无数据'));
                }
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final center = Offset(size.width / 2, size.height / 2);
                    final dx = details.localPosition.dx - center.dx;
                    final dy = details.localPosition.dy - center.dy;
                    final dist = sqrt(dx * dx + dy * dy);
                    final outerRadius = (size.width < size.height ? size.width / 2 * 0.8 : size.height / 2 * 0.8);
                    final innerRadius = outerRadius * 0.5;
                    if (dist < innerRadius || dist > outerRadius) {
                      setState(() {
                        _pieSelectedIndex = null;
                        _pieTooltipPos = null;
                      });
                      return;
                    }
                    double angle = atan2(dy, dx);
                    if (angle < 0) angle += 2 * pi;
                    double start = 0;
                    int? hitIndex;
                    for (int i = 0; i < categarys.length; i++) {
                      final per = (categarys[i].percent ?? 0) / 100.0;
                      final sweep = per * 2 * pi;
                      if (angle >= start && angle <= start + sweep) {
                        hitIndex = i;
                        break;
                      }
                      start += sweep;
                    }
                    setState(() {
                      _pieSelectedIndex = hitIndex;
                      _pieTooltipPos = details.localPosition;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SimplePieChartPainter(categarys, selectedIndex: _pieSelectedIndex),
                        ),
                      ),
                      if (_pieSelectedIndex != null && _pieTooltipPos != null && _pieSelectedIndex! < categarys.length)
                        Positioned(
                          left: max(0.0, min(_pieTooltipPos!.dx - 60, constraints.maxWidth - 120)),
                          top: max(0.0, min(_pieTooltipPos!.dy - 48, constraints.maxHeight - 80)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Builder(
                              builder: (context) {
                                final item = categarys[_pieSelectedIndex!];
                                final name = item.name ?? '';
                                final totalPercent = categarys.fold<double>(0, (s, e) => s + (e.percent ?? 0));
                                final totalValue = categarys.fold<double>(0, (s, e) => s + (e.value ?? 0));
                                final raw = item.percent ?? 0;
                                double frac = 0;
                                if (totalPercent > 0) {
                                  frac = raw > 1 ? raw / 100.0 : raw;
                                } else if (totalValue > 0) {
                                  frac = (item.value ?? 0) / totalValue;
                                }
                                final percentText = (frac * 100).toStringAsFixed(1);
                                final value = (item.value ?? 0);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text('占比: $percentText%', style: const TextStyle(color: Colors.white)),
                                    Text('金额: ¥${NumberFormat('#,##0.00').format(value)}', style: const TextStyle(color: Colors.white)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 使用 SingleChildScrollView 包裹 Wrap，并指定滚动方向为水平
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 设置为水平滚动
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              // 注意：当置于水平滚动的SingleChildScrollView内时，Wrap的主轴方向通常保持默认的水平方向即可。
              children: categarys.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final dotColor = _resolveCategoryColor(i, item);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // 百分比显示兼容：支持小数(0..1)与百分比(0..100)，无percent时按value占比
                    Builder(builder: (context) {
                      final totalPercent = categarys.fold<double>(0, (s, e) => s + (e.percent ?? 0));
                      final totalValue = categarys.fold<double>(0, (s, e) => s + (e.value ?? 0));
                      final raw = item.percent ?? 0;
                      double frac = 0;
                      if (totalPercent > 0) {
                        frac = raw > 1 ? raw / 100.0 : raw;
                      } else if (totalValue > 0) {
                        frac = (item.value ?? 0) / totalValue;
                      }
                      final display = (frac * 100).toStringAsFixed(1);
                      return Text('${item.name} ($display%)');
                    }),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompletionStats(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '账单完成情况',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.green),
              ),
              title: Text(S.current.statsCompletedTodoCountLabel),
              trailing: Text(
                '',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.radio_button_unchecked_rounded,
                    color: Colors.orange),
              ),
              title: Text(S.current.statsActiveTodoCountLabel),
              trailing: Text(
                '',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context, List<BillStatsClassification> categarys) {
    return Column(
      children: categarys.asMap().entries.map((entry) {
        final i = entry.key;
        final category = entry.value;
        final dotColor = _resolveCategoryColor(i, category);
        return ListTile(
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(
            category.name ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¥${NumberFormat('#,##0.00').format(category.value)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(category.percent ?? 0).toStringAsFixed(2)}%',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssetLiabilityRow(BuildContext context, String label,
      double amount, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Text(
          '¥${NumberFormat('#,##0.00').format(amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsList(BuildContext context) {
    // 模拟数据 - 实际应用中应从API获取
    final List<Map<String, dynamic>> assets = [
      {'name': '现金', 'amount': 15000.0, 'icon': Icons.money},
      {'name': '银行存款', 'amount': 50000.0, 'icon': Icons.account_balance},
      {'name': '股票', 'amount': 35000.0, 'icon': Icons.trending_up},
      {'name': '基金', 'amount': 20000.0, 'icon': Icons.pie_chart},
    ];

    return Column(
      children: assets.map((asset) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(asset['icon'] as IconData?, color: Colors.green),
            ),
            title: Text(
              asset['name'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '¥${NumberFormat('#,##0.00').format(asset['amount'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLiabilitiesList(BuildContext context) {
    // 模拟数据 - 实际应用中应从API获取
    final List<Map<String, dynamic>> liabilities = [
      {'name': '信用卡', 'amount': 5000.0, 'icon': Icons.credit_card},
      {'name': '房贷', 'amount': 30000.0, 'icon': Icons.home},
      {'name': '车贷', 'amount': 10000.0, 'icon': Icons.directions_car},
    ];

    return Column(
      children: liabilities.map((liability) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(liability['icon'] as IconData?, color: Colors.red),
            ),
            title: Text(
              liability['name'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '¥${NumberFormat('#,##0.00').format(liability['amount'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 简单的饼图绘制器
class SimplePieChartPainter extends CustomPainter {
  final List<BillStatsClassification> categarys;
  final int? selectedIndex;

  SimplePieChartPainter(this.categarys, {this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
    size.width < size.height ? size.width / 2 * 0.8 : size.height / 2 * 0.8;

    double startAngle = 0;

    // 兼容percent为小数或百分比；当percent不可用时按value占比绘制
    final double totalPercent = categarys.fold(0.0, (s, i) => s + (i.percent ?? 0.0));
    final double totalValue = categarys.fold(0.0, (s, i) => s + (i.value ?? 0.0));

    for (int i = 0; i < categarys.length; i++) {
      final item = categarys[i];

      double frac = 0.0;
      final raw = item.percent ?? 0.0;
      if (totalPercent > 0.0) {
        // 如果传入的是百分比(0..100)，转换为比例；如果是比例(0..1)，直接使用
        frac = raw > 1.0 ? raw / 100.0 : raw;
      } else if (totalValue > 0.0) {
        // 无percent时按value占比
        frac = (item.value ?? 0.0) / totalValue;
      }

      final sweepAngle = frac * 2 * pi;

      // 使用高饱和度的 Material 主色系作为默认颜色，提升鲜艳度（忽略自定义颜色）
      final material = Colors.primaries[i % Colors.primaries.length];
      final defaultColor = material.shade700 ?? material.shade600 ?? material;
      final fillPaint = Paint()
        ..color = defaultColor
        ..style = PaintingStyle.fill;

      final rect = Rect.fromCircle(center: center, radius: radius);

      // 填充扇形
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        fillPaint,
      );

      // 高亮选中的扇区（外圈描边）
      if (selectedIndex != null && selectedIndex == i) {
        final highlightPaint = Paint()
          ..color = Colors.white70
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawArc(
          rect,
          startAngle,
          sweepAngle,
          false, // 仅画弧线，不连接到中心
          highlightPaint,
        );
      }

      startAngle += sweepAngle;
    }

    // 绘制中心空白
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
