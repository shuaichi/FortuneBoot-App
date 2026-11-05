import 'package:fortuneboot/features/shared/data/bill_attachment_reader.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:fortuneboot/util/web_download.dart';

Future<BillAttachmentActionResult> openBillAttachment(BillFileVo file) async {
  final result = await saveBillAttachment(file);
  return result.status == BillAttachmentActionStatus.downloadStarted
      ? const BillAttachmentActionResult(BillAttachmentActionStatus.opened)
      : result;
}

Future<BillAttachmentActionResult> saveBillAttachment(BillFileVo file) async {
  final bytes = decodeBillAttachmentBytes(file.fileData);
  if (bytes == null || bytes.isEmpty) {
    return const BillAttachmentActionResult(
      BillAttachmentActionStatus.unsupported,
    );
  }
  final saved = await downloadBytes(
    file.originalName ?? 'attachment-${file.fileId ?? 'unknown'}',
    bytes,
    file.contentType ?? 'application/octet-stream',
  );
  return BillAttachmentActionResult(
    saved
        ? BillAttachmentActionStatus.downloadStarted
        : BillAttachmentActionStatus.unsupported,
  );
}
