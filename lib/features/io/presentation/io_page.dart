import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/io/data/io_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/web_download_stub.dart'
    if (dart.library.html) 'package:fortuneboot/util/web_download.dart'
    as webdl;
import 'package:path_provider/path_provider.dart';

/// 导入导出页（Routes.io）：导出账单 Excel / 下载模板 / 导入 Excel。
class IoPage extends StatefulWidget {
  const IoPage({super.key});

  @override
  State<IoPage> createState() => _IoPageState();
}

class _IoPageState extends State<IoPage> {
  final IoService _service = IoService();

  bool _exporting = false;
  bool _downloadingTemplate = false;
  bool _importing = false;

  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 保存字节流：Web 触发下载；移动端存临时目录并返回路径。
  Future<String?> _saveBytes(BytesResult res) async {
    if (res.bytes.isEmpty) return null;
    final s = S.of(context);
    if (kIsWeb) {
      final ok = await webdl.downloadBytes(
        res.filename,
        Uint8List.fromList(res.bytes),
        IoService.xlsxMime,
      );
      return ok ? s.ioDownloadStarted(res.filename) : null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${res.filename}';
    final file = File(path);
    await file.writeAsBytes(res.bytes, flush: true);
    return s.ioSavedTo(path);
  }

  Future<void> _export() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ioSelectBookFirst);
      return;
    }
    final noDataMsg = S.of(context).ioExportFailedNoData;
    setState(() => _exporting = true);
    try {
      // 最简筛选：仅 bookId。可扩展为携带当前 Bills 页筛选条件。
      final res = await _service.exportBills({'bookId': bookId});
      final msg = await _saveBytes(res);
      if (!mounted) return;
      _showToast(msg ?? noDataMsg);
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _downloadTemplate() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ioSelectBookFirst);
      return;
    }
    final failedMsg = S.of(context).ioDownloadFailed;
    setState(() => _downloadingTemplate = true);
    try {
      final res = await _service.downloadTemplate(bookId);
      final msg = await _saveBytes(res);
      if (!mounted) return;
      _showToast(msg ?? failedMsg);
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _downloadingTemplate = false);
    }
  }

  Future<void> _import() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ioSelectBookFirst);
      return;
    }
    final readFailedMsg = S.of(context).ioReadFileFailed;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes =
        file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      _showToast(readFailedMsg);
      return;
    }

    setState(() => _importing = true);
    try {
      final outcome = await _service.importBills(
        bookId: bookId,
        fileBytes: bytes,
        filename: file.name,
      );
      if (!mounted) return;
      await _showImportResult(outcome);
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _showImportResult(ImportOutcome outcome) async {
    final downloadFailedMsg = S.of(context).ioDownloadFailed;
    await FxSheet.show<void>(
      context,
      title: S.of(context).ioImportResult,
      child: _ImportResultBody(
        outcome: outcome,
        onDownloadError: (res) async {
          final msg = await _saveBytes(res);
          if (mounted) _showToast(msg ?? downloadFailedMsg);
        },
      ),
    );
  }

  String _err(Object e) => e is FxApiException ? e.message : e.toString();

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    return Scaffold(
      backgroundColor: FxPalette.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: bookId == null
                  ? FxStateView.empty(message: S.of(context).ioSelectBookFirst)
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.of(context).maybePop(),
            radius: 22,
            child: Padding(
              padding: const EdgeInsets.all(FxSpacing.xs),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: palette.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              S.of(context).ioTitle,
              style: FxTypography.title,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final palette = FxPalette.of(context);
    final finance = FxFinanceColors.of(context);
    return ListView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      children: [
        _actionCard(
          icon: Icons.file_download_outlined,
          tint: finance.income,
          title: S.of(context).ioExportBillsTitle,
          subtitle: S.of(context).ioExportBillsSubtitle,
          buttonLabel: S.of(context).ioExport,
          loading: _exporting,
          onTap: _export,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.description_outlined,
          tint: palette.info,
          title: S.of(context).ioDownloadTemplateTitle,
          subtitle: S.of(context).ioDownloadTemplateSubtitle,
          buttonLabel: S.of(context).ioDownloadTemplate,
          loading: _downloadingTemplate,
          onTap: _downloadTemplate,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.file_upload_outlined,
          tint: palette.primary,
          title: S.of(context).ioImportBillsTitle,
          subtitle: S.of(context).ioImportBillsSubtitle,
          buttonLabel: S.of(context).ioSelectFileImport,
          loading: _importing,
          onTap: _import,
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color tint,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: FxRadius.tileBorder,
                ),
                child: Icon(icon, color: tint),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: FxTypography.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: FxTypography.caption.copyWith(
                        color: FxPalette.of(context).textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FxSpacing.md),
          FxButton(
            label: buttonLabel,
            expand: true,
            loading: loading,
            onPressed: loading ? null : onTap,
          ),
        ],
      ),
    );
  }
}

/// 导入结果内容：成功统计条 或 失败可下载错误文件。
class _ImportResultBody extends StatelessWidget {
  final ImportOutcome outcome;
  final Future<void> Function(BytesResult) onDownloadError;

  const _ImportResultBody({
    required this.outcome,
    required this.onDownloadError,
  });

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final result = outcome.result;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (result != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat(
                  context,
                  S.of(context).ioSuccess,
                  result.successCount,
                  palette.success,
                ),
                _stat(
                  context,
                  S.of(context).ioFail,
                  result.failCount,
                  palette.danger,
                ),
                _stat(
                  context,
                  S.of(context).ioTotal,
                  result.total,
                  palette.textPrimary,
                ),
              ],
            ),
            if ((result.message ?? '').isNotEmpty) ...[
              const SizedBox(height: FxSpacing.md),
              Text(result.message!, style: FxTypography.body),
            ],
          ] else ...[
            Text(
              S.of(context).ioImportFailedWithErrors,
              style: FxTypography.body,
            ),
            const SizedBox(height: FxSpacing.lg),
            FxButton(
              label: S.of(context).ioDownloadErrorDetails,
              expand: true,
              icon: Icons.download_rounded,
              onPressed: () {
                final err = outcome.errorFile;
                if (err != null) onDownloadError(err);
              },
            ),
          ],
          const SizedBox(height: FxSpacing.lg),
          FxButton.tonal(
            label: S.of(context).ioDone,
            expand: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: FxTypography.title.copyWith(color: color)),
        const SizedBox(height: FxSpacing.xs),
        Text(
          label,
          style: FxTypography.caption.copyWith(
            color: FxPalette.of(context).textTertiary,
          ),
        ),
      ],
    );
  }
}
