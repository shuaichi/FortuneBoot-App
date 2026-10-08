import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/features/shared/presentation/bills/bill_detail_flow.dart';
import 'package:fortuneboot/features/stats/data/chinese_calendar_day.dart';
import 'package:fortuneboot/features/stats/data/stats_models.dart';
import 'package:fortuneboot/features/stats/presentation/widgets/stats_formatters.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/image_save_service.dart';
import 'package:intl/intl.dart';

/// 日历某日汇总：购物小票样式，上方统计、中间明细、底部付款与合计。
Future<void> showCalendarDaySummarySheet(
  BuildContext context, {
  required DateTime date,
  required IncomeExpenseCalendarBucket bucket,
  required int bookId,
  String? currencyCode,
  VoidCallback? onViewAllBills,
  BillService? service,
}) {
  return FxSheet.show<void>(
    context,
    scrollable: true,
    maxHeightFactor: FxSheet.pickerHeightFactor,
    child: CalendarDaySummarySheet(
      date: date,
      bucket: bucket,
      bookId: bookId,
      currencyCode: currencyCode,
      onViewAllBills: onViewAllBills,
      service: service,
    ),
  );
}

class CalendarDaySummarySheet extends StatefulWidget {
  const CalendarDaySummarySheet({
    super.key,
    required this.date,
    required this.bucket,
    required this.bookId,
    this.currencyCode,
    this.onViewAllBills,
    this.service,
  });

  final DateTime date;
  final IncomeExpenseCalendarBucket bucket;
  final int bookId;
  final String? currencyCode;
  final VoidCallback? onViewAllBills;
  final BillService? service;

  @override
  State<CalendarDaySummarySheet> createState() =>
      _CalendarDaySummarySheetState();
}

class _CalendarDaySummarySheetState extends State<CalendarDaySummarySheet> {
  late final BillService _service = widget.service ?? BillService();
  late final BillDetailFlow _detailFlow = BillDetailFlow(service: _service);
  late Future<BillPage> _billsFuture;
  final GlobalKey _receiptKey = GlobalKey();
  /// 打开小票时的查看时间，用于底部分界线中间展示。
  final DateTime _viewedAt = DateTime.now();
  var _readyToSave = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _billsFuture = _loadBills();
    _billsFuture.whenComplete(() {
      if (mounted) setState(() => _readyToSave = true);
    }).ignore();
  }

  Future<BillPage> _loadBills() {
    final day = BillService.dayFormat.format(widget.date);
    final pageSize = widget.bucket.totalCount.clamp(20, 200);
    return _service.getPage(
      BillQuery(
        bookId: widget.bookId,
        pageSize: pageSize,
        tradeTimeStartTime: day,
        tradeTimeEndTime: day,
      ),
    );
  }

  void _openBill(FortuneBillVo bill) {
    _detailFlow.show(context, bookId: widget.bookId, bill: bill);
  }

  Future<void> _saveReceipt() async {
    if (_saving || !_readyToSave) return;
    final s = S.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(2.0, 3.0);
    setState(() => _saving = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary =
          _receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        FxFeedback.error(context, message: s.imageSaveFailed);
        return;
      }
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final png = bytes?.buffer.asUint8List();
      if (png == null || png.isEmpty) {
        if (!mounted) return;
        FxFeedback.error(context, message: s.imageSaveFailed);
        return;
      }
      final name =
          'haoji_receipt_${DateFormat('yyyyMMdd').format(widget.date)}.png';
      final result = await ImageSaveService.saveBytes(
        png,
        name,
        mimeHint: 'png',
      );
      if (!mounted) return;
      switch (result) {
        case ImageSaveResult.saved:
          FxFeedback.success(context, message: s.imageSaveSuccess);
        case ImageSaveResult.downloadStarted:
          FxFeedback.success(context, message: s.imageSaveDownloadStarted);
        case ImageSaveResult.failed:
          FxFeedback.error(context, message: s.imageSaveFailed);
        case ImageSaveResult.unsupported:
          FxFeedback.warning(context, message: s.imageSaveUnsupported);
      }
    } on Object {
      if (!mounted) return;
      FxFeedback.error(context, message: s.imageSaveFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    final bookName = context.select<SessionCubit, String?>((c) {
      final name = c.state.currentBook?.bookName?.trim();
      return (name == null || name.isEmpty) ? null : name;
    });
    final paper = Theme.of(context).brightness == Brightness.dark
        ? palette.surface
        : const Color(0xFFFFFBF5);
    final ink = palette.textPrimary;
    final muted = palette.textSecondary;
    final formats = StatsFormatters.of(
      context,
      currencyCode: widget.currencyCode,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _receiptKey,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: const _ReceiptNotchClipper(),
                child: ColoredBox(
                  color: paper,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                    child: DefaultTextStyle(
                      style: FxTypography.body.copyWith(
                        color: ink,
                        height: 1.35,
                      ),
                      child: FutureBuilder<BillPage>(
                        future: _billsFuture,
                        builder: (context, snapshot) {
                          final loading =
                              snapshot.connectionState != ConnectionState.done;
                          final error = snapshot.hasError;
                          final rows =
                              snapshot.data?.rows ?? const <FortuneBillVo>[];
                          var transferCount = 0;
                          var transferAmount = 0.0;
                          for (final bill in rows) {
                            if (bill.billType != FxBillType.transfer.value) {
                              continue;
                            }
                            transferCount += 1;
                            transferAmount += bill.displayAmount;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                s.statsReceiptWelcome,
                                textAlign: TextAlign.center,
                                style: FxTypography.title.copyWith(
                                  color: ink,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bookName ?? s.appTitle,
                                textAlign: TextAlign.center,
                                style: FxTypography.bodyStrong.copyWith(
                                  color: ink,
                                ),
                              ),
                              const _ReceiptDash(),
                              _ReceiptMeta(
                                date: widget.date,
                                serial: loading || error
                                    ? null
                                    : _receiptSerial(rows),
                                ink: ink,
                                muted: muted,
                              ),
                              const _ReceiptDash(),
                              _ReceiptColumns(muted: muted),
                              const _ReceiptDash(),
                              if (loading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: FxSpacing.xl,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (error)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: FxSpacing.md,
                                  ),
                                  child: Text(
                                    s.dashboardLoadFailed,
                                    textAlign: TextAlign.center,
                                    style: FxTypography.body.copyWith(
                                      color: palette.danger,
                                    ),
                                  ),
                                )
                              else if (rows.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: FxSpacing.md,
                                  ),
                                  child: Text(
                                    s.statsCalendarDayBillsEmpty,
                                    textAlign: TextAlign.center,
                                    style: FxTypography.body.copyWith(
                                      color: palette.textTertiary,
                                    ),
                                  ),
                                )
                              else
                                for (final bill in rows)
                                  _ReceiptLine(
                                    bill: bill,
                                    formats: formats,
                                    ink: ink,
                                    muted: muted,
                                    finance: finance,
                                    onTap: () => _openBill(bill),
                                  ),
                              const _ReceiptDash(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    s.statsReceiptPayment,
                                    style: FxTypography.body.copyWith(
                                      color: ink,
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _ReceiptExtraBadge(
                                        label: s.statsReceiptDiscountTotal(
                                          formats.money(
                                            rows.fold<double>(
                                              0,
                                              (sum, b) =>
                                                  sum + b.discountTotal,
                                            ),
                                          ),
                                        ),
                                        foreground: const Color(0xFFD14343),
                                        background: const Color(0xFFFFE8E8),
                                      ),
                                      const SizedBox(height: 2),
                                      _ReceiptExtraBadge(
                                        label: s.statsReceiptFeeTotal(
                                          formats.money(
                                            rows.fold<double>(
                                              0,
                                              (sum, b) => sum + b.feeTotal,
                                            ),
                                          ),
                                        ),
                                        foreground: const Color(0xFFC47A2C),
                                        background: const Color(0xFFFFF0DD),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _ReceiptTotalRow(
                                label: s.statsReceiptIncomeGoods,
                                qty: widget.bucket.incomeCount,
                                amount: widget.bucket.income,
                                formats: formats,
                                color: finance.income,
                              ),
                              const SizedBox(height: 4),
                              _ReceiptTotalRow(
                                label: s.statsReceiptSoldGoods,
                                qty: widget.bucket.expenseCount,
                                amount: widget.bucket.expense,
                                formats: formats,
                                color: finance.expense,
                              ),
                              const SizedBox(height: 4),
                              _ReceiptTotalRow(
                                label: s.statsReceiptTransferCount,
                                qty: transferCount,
                                amount: transferAmount,
                                formats: formats,
                                color: finance.transfer,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.statsCalendarTotalCount(
                                  widget.bucket.totalCount,
                                ),
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                              _ReceiptDash(
                                centerText: DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(_viewedAt),
                              ),
                              const SizedBox(height: FxSpacing.md),
                              Text(
                                s.statsReceiptFooterWelcome,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.statsReceiptFooterUrl,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.statsReceiptFooterExcel,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: FxSpacing.sm),
                              Center(
                                child: Image.asset(
                                  'assets/images/receipt_sponsor_wechat.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                              const SizedBox(height: FxSpacing.sm),
                              Text(
                                s.statsReceiptFooterScan,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.statsReceiptFooterDelivery,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.statsReceiptFooterCounter,
                                textAlign: TextAlign.center,
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: FxButton(
                  label: s.statsReceiptSave,
                  icon: Icons.save_alt_rounded,
                  expand: true,
                  loading: _saving,
                  onPressed: _readyToSave ? _saveReceipt : null,
                ),
              ),
              if (widget.onViewAllBills != null) ...[
                const SizedBox(width: FxSpacing.sm),
                Expanded(
                  child: FxButton.tonal(
                    label: s.statsCalendarViewBills,
                    expand: true,
                    onPressed: _saving
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onViewAllBills!();
                          },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 流水号：按列表顺序拼接各账单 [FortuneBillVo.billId]，最长 15 位。
  String _receiptSerial(List<FortuneBillVo> rows) {
    final ids = rows
        .map((b) => b.billId)
        .whereType<int>()
        .map((id) => '$id')
        .toList();
    if (ids.isEmpty) return '—';
    final joined = ids.join();
    if (joined.length <= 15) return joined;
    return joined.substring(0, 15);
  }
}

class _ReceiptMeta extends StatelessWidget {
  const _ReceiptMeta({
    required this.date,
    required this.ink,
    required this.muted,
    this.serial,
  });

  final DateTime date;
  final Color ink;
  final Color muted;
  final String? serial;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final calendar = ChineseCalendarDay.of(date);
    final dateText = DateFormat('yyyy-MM-dd').format(date);
    final caption = FxTypography.caption.copyWith(color: ink);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.statsReceiptDate(dateText), style: caption),
              const SizedBox(height: 2),
              Text(
                '${calendar.weekdayLabel}  ${calendar.lunarDateLabel}',
                style: FxTypography.caption.copyWith(color: muted),
              ),
            ],
          ),
        ),
        if (serial != null) ...[
          const SizedBox(width: FxSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  s.statsReceiptSerial(serial!),
                  textAlign: TextAlign.right,
                  style: caption.copyWith(
                    fontFamily: FxTypography.monoFamily,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.statsReceiptCashier,
                  textAlign: TextAlign.right,
                  style: FxTypography.caption.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReceiptColumns extends StatelessWidget {
  const _ReceiptColumns({required this.muted});

  final Color muted;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final style = FxTypography.caption.copyWith(color: muted);
    return Row(
      children: [
        Expanded(flex: 7, child: Text(s.statsReceiptItem, style: style)),
        Expanded(
          flex: 3,
          child: Text(
            s.statsReceiptAmountCol,
            style: style,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.bill,
    required this.formats,
    required this.ink,
    required this.muted,
    required this.finance,
    required this.onTap,
  });

  final FortuneBillVo bill;
  final StatsFormatters formats;
  final Color ink;
  final Color muted;
  final FxFinanceColors finance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final category = bill.primaryCategoryName.trim();
    final title = (bill.title?.trim().isNotEmpty == true)
        ? bill.title!.trim()
        : (category.isNotEmpty ? category : '—');
    final members = bill.memberList
        .map((m) => m.memberName?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join('、');
    final tags = bill.tagList
        .map((t) => t.tagName?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .join('、');
    final account = bill.accountName?.trim() ?? '';
    final sub = [
      if (category.isNotEmpty && category != title) category,
      account,
      members,
      tags,
    ].where((e) => e.isNotEmpty).join(' · ');
    final fee = bill.feeTotal;
    final discount = bill.discountTotal;
    final hasExtras = bill.hasExtrasAdjustment && !formats.masked;
    final amountColor = switch (bill.billType) {
      1 => finance.expense,
      2 => finance.income,
      _ => ink,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.body.copyWith(color: ink),
                  ),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FxTypography.caption.copyWith(color: muted),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasExtras)
                    Text(
                      formats.money(bill.displayAmount),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FxTypography.caption.copyWith(
                        color: muted,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: muted,
                        fontSize: 11,
                        height: 1.15,
                      ),
                    ),
                  Text(
                    formats.money(
                      hasExtras ? bill.settledAmount : bill.displayAmount,
                      showSign: bill.billType == 2,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.money.copyWith(
                      color: amountColor,
                      fontSize: 14,
                    ),
                  ),
                  if (hasExtras && (fee > 0 || discount > 0)) ...[
                    const SizedBox(height: 2),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: FxSpacing.xs,
                      runSpacing: 2,
                      children: [
                        if (fee > 0)
                          _ReceiptExtraBadge(
                            label: '${s.billsFee} ${formats.money(fee)}',
                            foreground: const Color(0xFFC47A2C),
                            background: const Color(0xFFFFF0DD),
                          ),
                        if (discount > 0)
                          _ReceiptExtraBadge(
                            label: '${s.billsDiscount} ${formats.money(discount)}',
                            foreground: const Color(0xFFD14343),
                            background: const Color(0xFFFFE8E8),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptExtraBadge extends StatelessWidget {
  const _ReceiptExtraBadge({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: FxTypography.caption.copyWith(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  const _ReceiptTotalRow({
    required this.label,
    required this.qty,
    required this.amount,
    required this.formats,
    required this.color,
  });

  final String label;
  final int qty;
  final double amount;
  final StatsFormatters formats;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ink = FxPalette.of(context).textPrimary;
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(label, style: FxTypography.bodyStrong.copyWith(color: ink)),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: FxTypography.bodyStrong.copyWith(
              color: ink,
              fontFamily: FxTypography.monoFamily,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            formats.money(amount),
            textAlign: TextAlign.right,
            style: FxTypography.money.copyWith(color: color, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _ReceiptDash extends StatelessWidget {
  const _ReceiptDash({this.centerText});

  final String? centerText;

  @override
  Widget build(BuildContext context) {
    final color = FxPalette.of(context).textTertiary.withValues(alpha: 0.7);
    final style = FxTypography.caption.copyWith(
      color: color,
      fontFamily: FxTypography.monoFamily,
      height: 1,
      letterSpacing: 0,
    );
    final bar = Text(
      '=' * 48,
      maxLines: 1,
      overflow: TextOverflow.clip,
      textAlign: TextAlign.center,
      style: style,
    );
    final center = centerText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: center == null
          ? bar
          : Row(
              children: [
                Expanded(
                  child: Text(
                    '=' * 24,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    center,
                    maxLines: 1,
                    style: style.copyWith(
                      color: FxPalette.of(context).textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '=' * 24,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.right,
                    style: style,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReceiptNotchClipper extends CustomClipper<Path> {
  const _ReceiptNotchClipper();

  @override
  Path getClip(Size size) {
    const tooth = 7.0;
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - tooth);
    var x = size.width;
    var down = true;
    while (x > 0) {
      x -= tooth;
      path.lineTo(x.clamp(0, size.width), size.height - (down ? 0 : tooth));
      down = !down;
    }
    path.lineTo(0, size.height - tooth);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
