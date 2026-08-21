import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_path_inspector.dart';

enum BillAttachmentValidationReason {
  unreadable,
  empty,
  fileTooLarge,
  totalTooLarge,
}

class BillAttachmentValidationException implements Exception {
  const BillAttachmentValidationException(this.reason);

  final BillAttachmentValidationReason reason;
}

class BillAttachmentInspection {
  const BillAttachmentInspection({
    required this.attachment,
    required this.sizeBytes,
  });

  final BillAttachment attachment;
  final int sizeBytes;
}

/// Validates the attachment contract before multipart construction.
class BillAttachmentValidator {
  const BillAttachmentValidator();

  static const int maxSingleBytes = 5 * 1024 * 1024;
  static const int maxTotalBytes = 20 * 1024 * 1024;

  Future<BillAttachmentInspection> inspect(BillAttachment attachment) async {
    final sizeBytes = switch (attachment) {
      BytesBillAttachment(:final bytes) => bytes.length,
      PathBillAttachment(:final path) => await _inspectPath(path),
    };
    if (sizeBytes == 0) {
      throw const BillAttachmentValidationException(
        BillAttachmentValidationReason.empty,
      );
    }
    if (sizeBytes > maxSingleBytes) {
      throw const BillAttachmentValidationException(
        BillAttachmentValidationReason.fileTooLarge,
      );
    }
    return BillAttachmentInspection(
      attachment: attachment,
      sizeBytes: sizeBytes,
    );
  }

  Future<int> _inspectPath(String path) async {
    final sizeBytes = await inspectBillAttachmentPath(path);
    if (sizeBytes == null) {
      throw const BillAttachmentValidationException(
        BillAttachmentValidationReason.unreadable,
      );
    }
    return sizeBytes;
  }

  Future<List<BillAttachmentInspection>> inspectAll(
    Iterable<BillAttachment> attachments,
  ) async {
    var totalBytes = 0;
    final inspections = <BillAttachmentInspection>[];
    for (final attachment in attachments) {
      final inspection = await inspect(attachment);
      totalBytes += inspection.sizeBytes;
      if (totalBytes > maxTotalBytes) {
        throw const BillAttachmentValidationException(
          BillAttachmentValidationReason.totalTooLarge,
        );
      }
      inspections.add(inspection);
    }
    return inspections;
  }
}
