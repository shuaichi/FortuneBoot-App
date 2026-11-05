import 'dart:io';

import 'package:fortuneboot/features/shared/data/bill_attachment_reader.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<BillAttachmentActionResult> openBillAttachment(BillFileVo file) async {
  final bytes = decodeBillAttachmentBytes(file.fileData);
  if (bytes == null || bytes.isEmpty) {
    return const BillAttachmentActionResult(
      BillAttachmentActionStatus.unsupported,
    );
  }
  if (!_supportsNativePreview(file.contentType)) {
    return const BillAttachmentActionResult(
      BillAttachmentActionStatus.unsupported,
    );
  }
  final path = await _writeBytes(file, bytes);
  final launched = await launchUrl(
    Uri.file(path),
    mode: LaunchMode.externalApplication,
  );
  return BillAttachmentActionResult(
    launched
        ? BillAttachmentActionStatus.opened
        : BillAttachmentActionStatus.unsupported,
    path: launched ? path : null,
  );
}

Future<BillAttachmentActionResult> saveBillAttachment(BillFileVo file) async {
  final bytes = decodeBillAttachmentBytes(file.fileData);
  if (bytes == null || bytes.isEmpty) {
    return const BillAttachmentActionResult(
      BillAttachmentActionStatus.unsupported,
    );
  }
  final path = await _writeBytes(file, bytes);
  return BillAttachmentActionResult(
    BillAttachmentActionStatus.saved,
    path: path,
  );
}

Future<String> _writeBytes(BillFileVo file, List<int> bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final name = _safeName(file.originalName, file.fileId);
  final target = File('${directory.path}/bill-attachments/$name');
  await target.parent.create(recursive: true);
  await target.writeAsBytes(bytes, flush: true);
  return target.path;
}

String _safeName(String? originalName, int? fileId) {
  final normalized = (originalName?.trim().isNotEmpty == true)
      ? originalName!.replaceAll(RegExp('[^A-Za-z0-9._-]'), '_')
      : 'attachment-${fileId ?? 'unknown'}';
  return normalized.replaceAll(RegExp(r'^\.+'), '');
}

bool _supportsNativePreview(String? contentType) => switch (contentType) {
  'text/plain' || 'text/csv' || 'application/json' => true,
  _ => false,
};
