import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:mime/mime.dart';

Widget buildBillAttachmentPreview({
  required BillAttachment attachment,
  required double size,
  required String fileName,
  required Widget fallback,
}) {
  if (attachment case BytesBillAttachment(
    :final bytes,
  ) when _isImage(fileName)) {
    return Image.memory(
      bytes,
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: fileName,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
  return fallback;
}

bool _isImage(String name) =>
    lookupMimeType(name)?.startsWith('image/') ?? false;
