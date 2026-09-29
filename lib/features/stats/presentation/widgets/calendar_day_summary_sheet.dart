import 'dart:math' as math;
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
  var _readyToSave = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _billsFuture = _loadBills();
    _billsFuture.whenComplete(() {
      if (mounted) setState(() => _readyToSave = true);
    });
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
                              _ReceiptTotalRow(
                                label: s.statsCalendarIncomeCount(
                                  widget.bucket.incomeCount,
                                ),
                                amount: widget.bucket.income,
                                formats: formats,
                                color: finance.income,
                              ),
                              const SizedBox(height: 4),
                              _ReceiptTotalRow(
                                label: s.statsCalendarExpenseCount(
                                  widget.bucket.expenseCount,
                                ),
                                amount: widget.bucket.expense,
                                formats: formats,
                                color: finance.expense,
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
                              const _ReceiptDash(),
                              Text(
                                s.statsReceiptPayment,
                                style: FxTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _paymentLabel(rows),
                                style: FxTypography.body.copyWith(color: ink),
                              ),
                              const SizedBox(height: FxSpacing.md),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 64,
                                    color: ink.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: FxSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          s.statsReceiptCashier,
                                          style: FxTypography.caption.copyWith(
                                            color: muted,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          s.statsReceiptKeep,
                                          textAlign: TextAlign.right,
                                          style: FxTypography.caption.copyWith(
                                            color: muted,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          s.statsReceiptThanks,
                                          textAlign: TextAlign.right,
                                          style: FxTypography.label.copyWith(
                                            color: ink,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  String _paymentLabel(List<FortuneBillVo> rows) {
    if (rows.isEmpty) return '—';
    final names = <String>{};
    for (final bill in rows) {
      final from = bill.accountName?.trim();
      final to = bill.toAccountName?.trim();
      if (from != null && from.isNotEmpty) names.add(from);
      if (to != null && to.isNotEmpty) names.add(to);
    }
    if (names.isEmpty) return '—';
    return names.join(' / ');
  }
}

class _ReceiptMeta extends StatelessWidget {
  const _ReceiptMeta({
    required this.date,
    required this.ink,
    required this.muted,
  });

  final DateTime date;
  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = Localizations.localeOf(context).toString();
    final calendar = ChineseCalendarDay.of(date);
    final dateText = DateFormat.yMMMEd(locale).format(date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.statsReceiptDate(dateText),
          style: FxTypography.caption.copyWith(color: ink),
        ),
        const SizedBox(height: 2),
        Text(
          '${calendar.weekdayLabel}  ${calendar.lunarDateLabel}',
          style: FxTypography.caption.copyWith(color: muted),
        ),
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
        Expanded(flex: 5, child: Text(s.statsReceiptItem, style: style)),
        Expanded(
          flex: 2,
          child: Text(
            s.statsReceiptQty,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
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
    final category = bill.primaryCategoryName.trim();
    final title = (bill.title?.trim().isNotEmpty == true)
        ? bill.title!.trim()
        : (category.isNotEmpty ? category : '—');
    final sub = [
      category,
      bill.accountName?.trim() ?? '',
    ].where((e) => e.isNotEmpty && e != title).join(' · ');
    final amountColor = switch (bill.billType) {
      1 => finance.expense,
      2 => finance.income,
      _ => ink,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FxTypography.body.copyWith(color: ink),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '1',
                    textAlign: TextAlign.center,
                    style: FxTypography.body.copyWith(
                      color: ink,
                      fontFamily: FxTypography.monoFamily,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formats.money(
                      bill.displayAmount,
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
                ),
              ],
            ),
            if (sub.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 72),
                child: Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FxTypography.caption.copyWith(color: muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  const _ReceiptTotalRow({
    required this.label,
    required this.amount,
    required this.formats,
    required this.color,
  });

  final String label;
  final double amount;
  final StatsFormatters formats;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: FxTypography.bodyStrong)),
        Text(
          formats.money(amount),
          style: FxTypography.money.copyWith(color: color, fontSize: 15),
        ),
      ],
    );
  }
}

class _ReceiptDash extends StatelessWidget {
  const _ReceiptDash();

  @override
  Widget build(BuildContext context) {
    final color = FxPalette.of(context).textTertiary.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CustomPaint(
        painter: _DashLinePainter(color: color),
        child: const SizedBox(width: double.infinity, height: 1),
      ),
    );
  }
}

class _DashLinePainter extends CustomPainter {
  const _DashLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    const gap = 4.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, size.width), y),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashLinePainter oldDelegate) =>
      oldDelegate.color != color;
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
