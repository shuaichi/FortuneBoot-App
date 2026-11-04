import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/core/session/bill_mutations.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/features/io/data/io_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_icon_tile.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/layout/fx_page_scaffold.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:fortuneboot/util/web_download_stub.dart'
    if (dart.library.html) 'package:fortuneboot/util/web_download.dart'
    as webdl;
import 'package:fortuneboot_ohos_security/fortuneboot_ohos_security.dart';
import 'package:path_provider/path_provider.dart';

/// 导入导出页（Routes.io）：导出账单 Excel / 下载模板 / 导入 Excel。
class IoPage extends StatefulWidget {
  const IoPage({super.key});

  @override
  State<IoPage> createState() => _IoPageState();
}

class _IoPageState extends State<IoPage> {
  final IoService _service = IoService();
  final FortunebootOhosSecurity _ohosSecurity = FortunebootOhosSecurity();

  bool _exporting = false;
  bool _downloadingTemplate = false;
  bool _importing = false;

  int? get _bookId => context.read<SessionCubit>().state.currentBookId;

  bool get _busy => _exporting || _downloadingTemplate || _importing;

  void _showToast(String message) {
    FxFeedback.info(context, message: message);
  }

  bool _isCurrentBook(int bookId) => _bookId == bookId;

  bool get _isOhos => !kIsWeb && Platform.operatingSystem == 'ohos';

  /// 保存字节流：Web 触发下载；鸿蒙走系统文档保存；其它端写临时目录。
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
    if (_isOhos) {
      final status = await _ohosSecurity.saveDocument(
        bytes: Uint8List.fromList(res.bytes),
        fileName: res.filename,
      );
      if (status == 'cancelled') return s.commonCancel;
      if (status == 'saved') return s.ioSavedTo(res.filename);
      return null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${res.filename}';
    final file = File(path);
    await file.writeAsBytes(res.bytes, flush: true);
    return s.ioSavedTo(path);
  }

  Future<void> _export() async {
    if (_busy) return;
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
      if (!mounted || !_isCurrentBook(bookId)) return;
      final msg = await _saveBytes(res);
      if (!mounted || !_isCurrentBook(bookId)) return;
      _showToast(msg ?? noDataMsg);
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _downloadTemplate() async {
    if (_busy) return;
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ioSelectBookFirst);
      return;
    }
    final failedMsg = S.of(context).ioDownloadFailed;
    setState(() => _downloadingTemplate = true);
    try {
      final res = await _service.downloadTemplate(bookId);
      if (!mounted || !_isCurrentBook(bookId)) return;
      final msg = await _saveBytes(res);
      if (!mounted || !_isCurrentBook(bookId)) return;
      _showToast(msg ?? failedMsg);
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _downloadingTemplate = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    final bookId = _bookId;
    if (bookId == null) {
      _showToast(S.of(context).ioSelectBookFirst);
      return;
    }
    final readFailedMsg = S.of(context).ioReadFileFailed;
    final XFile? picked;
    try {
      // 鸿蒙无 file_picker 实现；统一走已适配的 file_selector。
      picked = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(label: 'Excel', extensions: ['xlsx', 'xls']),
        ],
      );
    } on MissingPluginException {
      if (mounted) _showToast(S.of(context).profileSaveFailedRetry);
      return;
    } on PlatformException {
      if (mounted) _showToast(S.of(context).profileSaveFailedRetry);
      return;
    }
    if (!mounted || !_isCurrentBook(bookId)) return;
    if (picked == null) {
      _showToast(S.of(context).commonCancel);
      return;
    }
    final extension = picked.name.split('.').last.toLowerCase();
    if (extension != 'xlsx' && extension != 'xls') {
      _showToast(readFailedMsg);
      return;
    }

    setState(() => _importing = true);
    try {
      final bytes = await picked.readAsBytes();
      if (!mounted || !_isCurrentBook(bookId)) return;
      if (bytes.isEmpty) {
        _showToast(readFailedMsg);
        return;
      }
      final outcome = await _service.importBills(
        bookId: bookId,
        fileBytes: bytes,
        filename: picked.name,
      );
      if (!mounted || !_isCurrentBook(bookId)) return;
      final imported = outcome.result?.successCount ?? 0;
      if (imported > 0) BillMutations.bump();
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

  String _err(Object e) =>
      e is FxApiException ? e.message : S.of(context).profileSaveFailedRetry;

  @override
  Widget build(BuildContext context) {
    final bookId = context.select<SessionCubit, int?>(
      (c) => c.state.currentBookId,
    );
    return FxPageScaffold(
      title: S.of(context).ioTitle,
      child: bookId == null
          ? FxStateView.empty(message: S.of(context).ioSelectBookFirst)
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      children: [
        _actionCard(
          icon: Icons.file_download_outlined,
          primary: true,
          title: S.of(context).ioExportBillsTitle,
          subtitle: S.of(context).ioExportBillsSubtitle,
          buttonLabel: S.of(context).ioExport,
          loading: _exporting,
          onTap: _busy ? null : _export,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.description_outlined,
          title: S.of(context).ioDownloadTemplateTitle,
          subtitle: S.of(context).ioDownloadTemplateSubtitle,
          buttonLabel: S.of(context).ioDownloadTemplate,
          loading: _downloadingTemplate,
          onTap: _busy ? null : _downloadTemplate,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.file_upload_outlined,
          title: S.of(context).ioImportBillsTitle,
          subtitle: S.of(context).ioImportBillsSubtitle,
          buttonLabel: S.of(context).ioSelectFileImport,
          loading: _importing,
          onTap: _busy ? null : _import,
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required bool loading,
    required VoidCallback? onTap,
    bool primary = false,
  }) {
    final button = primary
        ? FxButton(
            label: buttonLabel,
            expand: true,
            loading: loading,
            onPressed: loading ? null : onTap,
          )
        : FxButton.tonal(
            label: buttonLabel,
            expand: true,
            loading: loading,
            onPressed: loading ? null : onTap,
          );
    return Semantics(
      button: true,
      enabled: onTap != null && !loading,
      label: title,
      child: FxCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FxIconTile(icon: icon, size: 40, iconSize: 22),
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
            button,
          ],
        ),
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
                  palette.textPrimary,
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
