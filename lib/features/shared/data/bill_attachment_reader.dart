import 'dart:convert';
import 'dart:typed_data';

import 'package:fortuneboot/features/shared/data/bill_attachment_reader_native.dart'
    if (dart.library.html) 'package:fortuneboot/features/shared/data/bill_attachment_reader_web.dart'
    as platform;
import 'package:fortuneboot/features/shared/data/bill_service.dart';

enum BillAttachmentActionStatus { opened, saved, downloadStarted, unsupported }

class BillAttachmentActionResult {
  const BillAttachmentActionResult(this.status, {this.path});

  final BillAttachmentActionStatus status;
  final String? path;
}

/// 详情附件的平台打开/保存边界；只处理已下载的本地字节，不上传。
class BillAttachmentReader {
  const BillAttachmentReader();

  Future<BillAttachmentActionResult> open(BillFileVo file) =>
      platform.openBillAttachment(file);

  Future<BillAttachmentActionResult> save(BillFileVo file) =>
      platform.saveBillAttachment(file);
}

Uint8List? decodeBillAttachmentBytes(String? encoded) {
  if (encoded == null || encoded.isEmpty) return null;
  try {
    final normalized = encoded.contains(',')
        ? encoded.split(',').last
        : encoded;
    return base64Decode(normalized);
  } on FormatException {
    return null;
  }
}
