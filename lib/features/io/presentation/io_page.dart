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
    if (kIsWeb) {
      final ok = await webdl.downloadBytes(
        res.filename,
        Uint8List.fromList(res.bytes),
        IoService.xlsxMime,
      );
      return ok ? '已开始下载 ${res.filename}' : null;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${res.filename}';
    final file = File(path);
    await file.writeAsBytes(res.bytes, flush: true);
    return '已保存到：$path';
  }

  Future<void> _export() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    setState(() => _exporting = true);
    try {
      // 最简筛选：仅 bookId。可扩展为携带当前 Bills 页筛选条件。
      final res = await _service.exportBills({'bookId': bookId});
      final msg = await _saveBytes(res);
      if (!mounted) return;
      _showToast(msg ?? '导出失败：无数据');
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _downloadTemplate() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
    setState(() => _downloadingTemplate = true);
    try {
      final res = await _service.downloadTemplate(bookId);
      final msg = await _saveBytes(res);
      if (!mounted) return;
      _showToast(msg ?? '下载失败');
    } on Object catch (e) {
      if (mounted) _showToast(_err(e));
    } finally {
      if (mounted) setState(() => _downloadingTemplate = false);
    }
  }

  Future<void> _import() async {
    final bookId = _bookId;
    if (bookId == null) {
      _showToast('请先选择账本');
      return;
    }
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
      _showToast('读取文件失败');
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
    await FxSheet.show<void>(
      context,
      title: '导入结果',
      child: _ImportResultBody(
        outcome: outcome,
        onDownloadError: (res) async {
          final msg = await _saveBytes(res);
          if (mounted) _showToast(msg ?? '下载失败');
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
                  ? FxStateView.empty(message: '请先选择账本')
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
          const Expanded(child: Text('导入导出', style: FxTypography.title)),
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
          title: '导出账单 Excel',
          subtitle: '导出当前账本账单（含筛选，最大 10000 条）',
          buttonLabel: '导出',
          loading: _exporting,
          onTap: _export,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.description_outlined,
          tint: palette.info,
          title: '下载导入模板',
          subtitle: '获取标准 Excel 模板，按格式填写后导入',
          buttonLabel: '下载模板',
          loading: _downloadingTemplate,
          onTap: _downloadTemplate,
        ),
        const SizedBox(height: FxSpacing.md),
        _actionCard(
          icon: Icons.file_upload_outlined,
          tint: palette.primary,
          title: '导入账单 Excel',
          subtitle: '选择 .xlsx 文件上传，导入完成后展示结果',
          buttonLabel: '选择文件导入',
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
                    Text(subtitle, style: FxTypography.caption),
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
                _stat('成功', result.successCount, palette.success),
                _stat('失败', result.failCount, palette.danger),
                _stat('共', result.total, palette.textPrimary),
              ],
            ),
            if ((result.message ?? '').isNotEmpty) ...[
              const SizedBox(height: FxSpacing.md),
              Text(result.message!, style: FxTypography.body),
            ],
          ] else ...[
            const Text(
              '导入失败，存在错误行。可下载错误明细 Excel 查看具体原因。',
              style: FxTypography.body,
            ),
            const SizedBox(height: FxSpacing.lg),
            FxButton(
              label: '下载错误明细',
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
            label: '完成',
            expand: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: FxTypography.title.copyWith(color: color)),
        const SizedBox(height: FxSpacing.xs),
        Text(label, style: FxTypography.caption),
      ],
    );
  }
}
