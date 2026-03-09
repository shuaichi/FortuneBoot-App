import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

// 正确引入 BLoC 和 Model
import '../bloc/bills_stats_bloc.dart';
import '../models/stats_models.dart';
import 'package:hjproject/request/include_request.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

class FintechColors {
  static const Color primaryText = Color(0xFF1C1C1E);
  static const Color secondaryText = Color(0xFF8E8E93);
  static const Color background = Color(0xFFF2F4F7);
  static const Color surface = Colors.white;
  static const Color income = Color(0xFF34C759);
  static const Color expense = Color(0xFFFF3B30);
  static const Color neutral = Color(0xFF007AFF);
  static const Color gridLine = Color(0x14000000);

  static const List<Color> palette =[
    Color(0xFF007AFF), Color(0xFF5AC8FA), Color(0xFF5856D6),
    Color(0xFFFF9500), Color(0xFFFF2D55), Color(0xFFAF52DE),
    Color(0xFFFFCC00), Color(0xFF34C759), Color(0xFF8E8E93),
  ];
}

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) {
        final billsRepo = context.read<BillsRepository>();
        final bookId = billsRepo.bookId() ?? 1;
        final groupId = 1;

        final endDate = DateTime.now();
        final startDate = endDate.subtract(const Duration(days: 180));

        final includeService = IncludeService(Dio());

        return BlocProvider(
          create: (context) => BillsStatsBloc(includeService: includeService)
            ..add(BillsStatsRequested(
                groupId: groupId,
                bookId: bookId,
                startDate: startDate,
                endDate: endDate)),
          child: const StatsView(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 作为普通组件挂载时的处理
    final billsRepo = context.read<BillsRepository>();
    final bookId = billsRepo.bookId() ?? 1;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 180));
    final includeService = IncludeService(Dio());

    return BlocProvider(
      create: (context) => BillsStatsBloc(includeService: includeService)
        ..add(BillsStatsRequested(groupId: 1, bookId: bookId, startDate: startDate, endDate: endDate)),
      child: const StatsView(),
    );
  }
}

class StatsView extends StatefulWidget {
  const StatsView({super.key});
  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickDateRange(BuildContext context, BillsStatsState state) async {
    final billsRepo = context.read<BillsRepository>();
    final bookId = billsRepo.bookId() ?? 1;

    final initialRange = DateTimeRange(
      start: state.startDate ?? DateTime.now().subtract(const Duration(days: 180)),
      end: state.endDate ?? DateTime.now(),
    );

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: FintechColors.neutral),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<BillsStatsBloc>().add(BillsStatsRequested(
        groupId: 1,
        bookId: bookId,
        startDate: picked.start,
        endDate: picked.end,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FintechColors.background,
      appBar: AppBar(
        backgroundColor: FintechColors.surface,
        elevation: 0,
        title: const Text('财务洞察', style: TextStyle(color: FintechColors.primaryText, fontWeight: FontWeight.bold)),
        actions:[
          BlocBuilder<BillsStatsBloc, BillsStatsState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: FintechColors.neutral),
                tooltip: '筛选时间',
                onPressed: () => _pickDateRange(context, state),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: FintechColors.neutral,
          unselectedLabelColor: FintechColors.secondaryText,
          indicatorColor: FintechColors.neutral,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const[Tab(text: '概览'), Tab(text: '支出'), Tab(text: '收入')],
        ),
      ),
      body: BlocBuilder<BillsStatsBloc, BillsStatsState>(
        builder: (context, state) {
          if (state.status == BillsStatsStatus.loading || state.status == BillsStatsStatus.initial) {
            return const Center(child: CupertinoActivityIndicator(radius: 14));
          }
          if (state.status == BillsStatsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  const Icon(Icons.error_outline, size: 48, color: FintechColors.secondaryText),
                  const SizedBox(height: 16),
                  const Text('数据加载失败，请检查网络设置', style: TextStyle(color: FintechColors.secondaryText)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final billsRepo = context.read<BillsRepository>();
                      context.read<BillsStatsBloc>().add(BillsStatsRequested(
                        groupId: 1,
                        bookId: billsRepo.bookId() ?? 1,
                        startDate: state.startDate ?? DateTime.now(),
                        endDate: state.endDate ?? DateTime.now(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: FintechColors.neutral),
                    child: const Text('重新加载', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children:[
              _buildOverviewTab(state),
              _buildAnalysisTab(state.categoryExpense, state.tagExpense, FintechColors.expense, '总支出'),
              _buildAnalysisTab(state.categoryIncome, [], FintechColors.income, '总收入'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BillsStatsState state) {
    final dateFmt = DateFormat('yyyy/MM/dd');
    final dateHint = (state.startDate != null && state.endDate != null)
        ? '${dateFmt.format(state.startDate!)} - ${dateFmt.format(state.endDate!)}'
        : '全部数据';

    return CustomScrollView(
      slivers:[
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const Icon(Icons.access_time_filled, size: 14, color: FintechColors.secondaryText),
                const SizedBox(width: 6),
                Text(dateHint, style: const TextStyle(fontSize: 12, color: FintechColors.secondaryText, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildNetAssetsHero(state.assetsLiabilities),
              const SizedBox(height: 16),
              _buildIncomeExpenseRow(state.statistics),
              const SizedBox(height: 24),
              _buildTrendChartCard(state.incomeTrends, state.expenseTrends),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab(List<FortunePieVo> categories, List<FortuneBarVo> tags, Color themeColor, String title) {
    if (categories.isEmpty) {
      return const Center(child: Text('当前时间范围内暂无数据', style: TextStyle(color: FintechColors.secondaryText)));
    }

    final total = categories.fold(0.0, (sum, item) => sum + item.value);

    return CustomScrollView(
      slivers:[
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDonutChartCard(categories, themeColor, title, total),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildBarChartCard(tags, themeColor, '标签分布'),
              ],
              const SizedBox(height: 24),
              const Text('分类明细', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FintechColors.primaryText)),
              const SizedBox(height: 12),
              ...categories.asMap().entries.map((e) => _buildCategoryTile(e.value, FintechColors.palette[e.key % FintechColors.palette.length])),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildNetAssetsHero(FortuneAssetsLiabilitiesVo? data) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          const Text('净资产', style: TextStyle(fontSize: 14, color: FintechColors.secondaryText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '¥${NumberFormat('#,##0.00').format(data?.netAssets ?? 0)}',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: FintechColors.primaryText, fontFeatures: [FontFeature.tabularFigures()]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              _MiniMetric('总资产', data?.totalAssets ?? 0, FintechColors.primaryText),
              _MiniMetric('总负债', data?.totalLiabilities ?? 0, FintechColors.expense),
            ],
          )
        ],
      ),
    );
  }

  Widget _MiniMetric(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Text(label, style: const TextStyle(fontSize: 12, color: FintechColors.secondaryText)),
        Text('¥${NumberFormat('#,##0.00').format(val)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color, fontFeatures: const [FontFeature.tabularFigures()])),
      ],
    );
  }

  Widget _buildIncomeExpenseRow(BillStatisticsVo? stats) {
    return Row(
      children:[
        Expanded(child: _KPICard(title: '本期收入', amount: stats?.income ?? 0, color: FintechColors.income, icon: Icons.arrow_circle_down_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _KPICard(title: '本期支出', amount: stats?.expense ?? 0, color: FintechColors.expense, icon: Icons.arrow_circle_up_rounded)),
      ],
    );
  }

  Widget _buildTrendChartCard(List<FortuneLineVo> income, List<FortuneLineVo> expense) {
    if (income.isEmpty && expense.isEmpty) return const SizedBox.shrink();

    return _DashboardCard(
      title: '收支趋势',
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: FintechColors.gridLine, strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    int idx = value.toInt();
                    if (idx < 0 || idx >= income.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 10), child: Text(income[idx].name, style: const TextStyle(fontSize: 10, color: FintechColors.secondaryText)));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData:[
              if (income.isNotEmpty) _buildLineChartBar(income, FintechColors.income),
              if (expense.isNotEmpty) _buildLineChartBar(expense, FintechColors.expense),
            ],
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBar(List<FortuneLineVo> data, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
    );
  }

  Widget _buildDonutChartCard(List<FortunePieVo> data, Color themeColor, String centerTitle, double total) {
    return _DashboardCard(
      child: SizedBox(
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children:[
            Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                Text(centerTitle, style: const TextStyle(fontSize: 14, color: FintechColors.secondaryText)),
                Text('¥${NumberFormat('#,##0').format(total)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: FintechColors.primaryText, fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 80,
                sections: data.asMap().entries.map((e) {
                  return PieChartSectionData(
                    color: FintechColors.palette[e.key % FintechColors.palette.length],
                    value: e.value.value,
                    title: '',
                    radius: 20,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(List<FortuneBarVo> tags, Color themeColor, String title) {
    return _DashboardCard(
      title: title,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: FintechColors.gridLine, strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= tags.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 8), child: Text(tags[value.toInt()].name, style: const TextStyle(fontSize: 11, color: FintechColors.secondaryText)));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: tags.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods:[BarChartRodData(toY: e.value.value, color: themeColor, width: 16, borderRadius: BorderRadius.circular(4))],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(FortunePieVo item, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: FintechColors.surface, borderRadius: BorderRadius.circular(16), boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)]),
      child: Column(
        children: [
          Row(
            children:[
              CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 18, child: Icon(Icons.category, color: color, size: 18)),
              const SizedBox(width: 12),
              Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FintechColors.primaryText))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                  Text('¥${NumberFormat('#,##0.00').format(item.value)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFeatures: [FontFeature.tabularFigures()])),
                  Text('${item.percent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: FintechColors.secondaryText)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: item.percent / 100, backgroundColor: FintechColors.background, color: color, minHeight: 6),
          )
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final String? title;

  const _DashboardCard({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: FintechColors.surface, borderRadius: BorderRadius.circular(20), boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: FintechColors.primaryText)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _KPICard({required this.title, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: FintechColors.surface, borderRadius: BorderRadius.circular(16), boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: FintechColors.secondaryText)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¥${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color, fontFeatures: const [FontFeature.tabularFigures()]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}