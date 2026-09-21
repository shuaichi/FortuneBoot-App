import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:mime/mime.dart';

Widget buildBillAttachmentPreview({
  required BillAttachment attachment,
  required double size,
  required String fileName,
  required Widget fallback,
}) {
  return switch (attachment) {
    BytesBillAttachment(:final bytes) when _isImage(fileName) => Image.memory(
      bytes,
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: fileName,
      errorBuilder: (context, error, stackTrace) => fallback,
    ),
    PathBillAttachment(:final path) when _isImage(fileName) => Image.file(
      File(path),
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: fileName,
      errorBuilder: (context, error, stackTrace) => fallback,
    ),
    _ => fallback,
  };
}

bool _isImage(String name) =>
    lookupMimeType(name)?.startsWith('image/') ?? false;
