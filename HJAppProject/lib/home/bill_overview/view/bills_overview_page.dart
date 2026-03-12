import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:hjproject/home/edit_bill/view/edit_bill_page.dart';
import 'package:hjproject/home/stats/view/stats_page.dart';
import 'package:hjproject/home/bill_overview/bloc/bills_overview_bloc.dart';
import 'package:hjproject/home/bill_overview/models/bill_item.dart';
import 'package:hjproject/home/bill_overview/models/bill_item_add.dart';
import 'package:hjproject/home/bill_overview/view/bill_detail_sheet.dart';
import 'package:hjproject/home/bill_overview/view/bill_list_tile.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import '../../../generated/l10n.dart';

// ==========================================
// 设计系统常量 (国内金融红绿习惯 + Apple 极简风格)
// ==========================================
class FintechTheme {
  static const Color bg = Color(0xFFF2F2F7);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFFE5E5EA);

  // 全新定制的业务色彩标准
  static Color getBillColor(BillType? type) {
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
        return textPrimary;
    }
  }

  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}

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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: FintechTheme.bg,
        appBar: AppBar(
          backgroundColor: FintechTheme.bg,
          elevation: 0,
          toolbarHeight: 44,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.chart_pie,
                  color: FintechTheme.textPrimary, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(StatsPage.route());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildUltraCompactHeader(context),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<BillsOverviewBloc, BillsOverviewState>(
                    listenWhen: (prev, cur) => prev.status != cur.status,
                    listener: (context, state) {
                      if (state.status == BillsOverviewStatus.failure) {
                        _showModernSnack(context,
                            S.current.todosOverviewErrorSnackbarText, true);
                      }
                    },
                  ),
                ],
                child: BlocBuilder<BillsOverviewBloc, BillsOverviewState>(
                  builder: (context, state) {
                    if (!(state.bills?.isNotEmpty == true)) {
                      if (state.status == BillsOverviewStatus.loading) {
                        return const Center(
                            child: CupertinoActivityIndicator(radius: 14));
                      } else if (state.status != BillsOverviewStatus.success) {
                        return const SizedBox();
                      } else {
                        return _buildEmptyState(context);
                      }
                    }

                    final bills = state.bills ?? [];
                    final Map<String, List<BillItem>> grouped = {};
                    final Map<String, DateTime> groupDateMap = {};
                    for (var bill in bills) {
                      final date = DateTime(bill.tradeTime!.year,
                          bill.tradeTime!.month, bill.tradeTime!.day);
                      final key = _dateKey(date);
                      groupDateMap[key] = date;
                      grouped.putIfAbsent(key, () => []).add(bill);
                    }
                    _groupDates = groupDateMap.values.toList()
                      ..sort((a, b) => b.compareTo(a));

                    if (_currentGroupDate == null && _groupDates.isNotEmpty) {
                      _currentGroupDate = _groupDates.first;
                    }

                    for (var d in _groupDates) {
                      _groupKeys.putIfAbsent(_dateKey(d), () => GlobalKey());
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _updateCurrentGroupDate(context));
                        if (notification is ScrollEndNotification &&
                            notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent - 50) {
                          if (!state.isLoadingMore && state.hasMore) {
                            HapticFeedback.lightImpact();
                            context
                                .read<BillsOverviewBloc>()
                                .add(const BillsOverviewLoadMoreRequested());
                          }
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        color: FintechTheme.textPrimary,
                        backgroundColor: Colors.white,
                        onRefresh: () async {
                          HapticFeedback.mediumImpact();
                          context
                              .read<BillsOverviewBloc>()
                              .add(const BillsOverviewLoadLastRequested());
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(top: 0, bottom: 120),
                          itemCount: _groupDates.length + 1,
                          itemBuilder: (context, groupIdx) {
                            if (groupIdx == _groupDates.length)
                              return _buildFooterWidget(state);

                            final date = _groupDates[groupIdx];
                            final key = _groupKeys[_dateKey(date)]!;
                            final billsInGroup = grouped[_dateKey(date)] ?? [];

                            double dayIncome = 0;
                            double dayExpense = 0;
                            for (var bill in billsInGroup) {
                              if (bill.billType == BillType.income)
                                dayIncome += bill.convertedAmount ?? 0;
                              else if (bill.billType == BillType.expenditure)
                                dayExpense += bill.convertedAmount ?? 0;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _getGroupSeparator(
                                    context, date, key, dayIncome, dayExpense),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Column(
                                      children: List.generate(
                                          billsInGroup.length, (index) {
                                        final bill = billsInGroup[index];
                                        final isLast =
                                            index == billsInGroup.length - 1;
                                        return Column(
                                          children: [
                                            BillListTile(
                                              bill: bill,
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                _showBillDetails(context, bill);
                                              },
                                              onCopy: () {
                                                if (bill.billType ==
                                                    BillType.adjust) {
                                                  _showModernSnack(context,
                                                      '余额调整账单不支持复制', true);
                                                  return;
                                                }
                                                HapticFeedback.mediumImpact();
                                                _showModernSnack(context,
                                                    '账单已复制，请修改后保存', false);
                                                Navigator.of(context).push(
                                                    EditBillPage.route(
                                                        initialBill: BillItemAdd
                                                            .fromBillItem(bill),
                                                        isCopyBill: true));
                                              },
                                              onDismissed: (direction) {
                                                HapticFeedback.mediumImpact();
                                                context
                                                    .read<BillsOverviewBloc>()
                                                    .add(
                                                        BillsOverviewDeleteRequested(
                                                            bill.billId!));
                                              },
                                            ),
                                            if (!isLast)
                                              const Divider(
                                                  height: 1,
                                                  thickness: 0.5,
                                                  indent: 64,
                                                  color: FintechTheme.divider),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
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
      ),
    );
  }

  // =======================================================
  // 头部月度汇总 (色彩逻辑已翻转)
  // =======================================================
  Widget _buildUltraCompactHeader(BuildContext context) {
    return BlocBuilder<BillsOverviewBloc, BillsOverviewState>(
      builder: (context, state) {
        if (state.status != BillsOverviewStatus.success ||
            state.bills == null) {
          return const SizedBox.shrink();
        }

        final now = state.statistics?.staticTime ?? DateTime.now();
        double monthIncome = state.statistics?.income ?? 0;
        double monthExpense = state.statistics?.expense ?? 0;
        double balance = monthIncome - monthExpense;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final currentValue =
                      context.read<BillsRepository>().billStatisticsDay() ?? 1;
                  final newValue = await showCupertinoDialog<String>(
                    context: context,
                    builder: (context) =>
                        EditValueDialog(currentValue: currentValue.toString()),
                  );
                  if (newValue != null && mounted) {
                    context.read<BillsOverviewBloc>().add(
                        BillsOverviewRefreshStatisticsDayChanged(
                            int.parse(newValue)));
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${now.year}年${now.month}月',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: FintechTheme.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(CupertinoIcons.chevron_down,
                        size: 14, color: FintechTheme.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('¥',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: FintechTheme.textPrimary)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                FintechTheme.formatAmount(monthExpense),
                                key: ValueKey<double>(monthExpense),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                  color: FintechTheme.textPrimary,
                                  // 总支出保持黑色沉稳
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '收 ¥${FintechTheme.formatAmount(monthIncome)}',
                        // 收入使用红色
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FintechTheme.getBillColor(BillType.income),
                            fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '余 ¥${FintechTheme.formatAmount(balance)}',
                        // 结余正为红，负为绿
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: balance >= 0
                                ? FintechTheme.getBillColor(BillType.income)
                                : FintechTheme.getBillColor(
                                    BillType.expenditure),
                            fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getGroupSeparator(BuildContext context, DateTime date, Key key,
      double income, double expense) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String dateText;
    final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    String weekdayText = weekdays[date.weekday % 7];

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      dateText = '今天';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      dateText = '昨天';
    } else if (date.year == now.year) {
      dateText = '${date.month}月${date.day}日';
    } else {
      dateText = '${date.year}年${date.month}月${date.day}日';
    }

    return VisibilityDetector(
      key: ValueKey(key),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 1.0) {
          context
              .read<BillsOverviewBloc>()
              .add(BillsOverviewRefreshStatisticsRequested(date));
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(dateText,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: FintechTheme.textPrimary)),
                const SizedBox(width: 8),
                Text(weekdayText,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: FintechTheme.textSecondary)),
              ],
            ),
            if (income > 0 || expense > 0)
              Text(
                [
                  if (income > 0) '收 ¥${FintechTheme.formatAmount(income)}',
                  if (expense > 0) '支 ¥${FintechTheme.formatAmount(expense)}'
                ].join('   '),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: FintechTheme.textSecondary,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
          ],
        ),
      ),
    );
  }

  void _showModernSnack(BuildContext context, String message, bool isError) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 15)),
        backgroundColor:
            isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_plaintext,
              size: 48, color: FintechTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(S.current.todosOverviewEmptyText,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: FintechTheme.textSecondary)),
        ],
      ),
    );
  }

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
    if (newGroup != null && newGroup != _currentGroupDate)
      setState(() => _currentGroupDate = newGroup);
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Widget _buildFooterWidget(BillsOverviewState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: state.isLoadingMore
            ? const CupertinoActivityIndicator()
            : (!state.hasMore && (state.bills?.isNotEmpty ?? false))
                ? const Text('没有更多记录了',
                    style: TextStyle(
                        color: FintechTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500))
                : const SizedBox.shrink(),
      ),
    );
  }

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
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定要删除这条记录吗？'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('取消',
                        style: TextStyle(color: FintechTheme.textSecondary)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      overViewState
                          .add(BillsOverviewDeleteRequested(bill.billId!));
                    },
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
  final String currentValue;

  const EditValueDialog({super.key, required this.currentValue});

  @override
  State<EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('每月结算日'),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: CupertinoTextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _IntegerRangeFormatter(min: 1, max: 31),
          ],
          decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8)),
        ),
      ),
      actions: [
        CupertinoDialogAction(
            child: const Text('取消',
                style: TextStyle(color: FintechTheme.textSecondary)),
            onPressed: () => Navigator.pop(context)),
        CupertinoDialogAction(
            child: Text('确认',
                style: TextStyle(
                    color: FintechTheme.getBillColor(BillType.transfer))),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_controller.text.isNotEmpty)
                Navigator.pop(context, _controller.text);
            }),
      ],
    );
  }
}

class _IntegerRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _IntegerRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final num = int.tryParse(newValue.text);
    if (num == null) return oldValue;
    int correctedValue = num;
    if (num < min) correctedValue = min;
    if (num > max) correctedValue = max;
    return TextEditingValue(
      text: correctedValue.toString(),
      selection:
          TextSelection.collapsed(offset: correctedValue.toString().length),
    );
  }
}
