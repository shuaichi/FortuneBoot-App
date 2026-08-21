import 'package:flutter/material.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/bill_attachment_preview_native.dart'
    if (dart.library.html) 'package:fortuneboot/features/bill_editor/presentation/widgets/bill_attachment_preview_web.dart'
    as implementation;
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';

Widget buildBillAttachmentPreview({
  required BillAttachment attachment,
  required double size,
  required String fileName,
  required Widget fallback,
}) => implementation.buildBillAttachmentPreview(
  attachment: attachment,
  size: size,
  fileName: fileName,
  fallback: fallback,
);
