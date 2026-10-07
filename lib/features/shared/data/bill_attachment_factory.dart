import 'package:file_picker/file_picker.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_factory_native.dart'
    if (dart.library.html) 'package:fortuneboot/features/shared/data/bill_attachment_factory_web.dart'
    as implementation;

Future<BillAttachment?> billAttachmentFromPlatformFile(
  PlatformFile file, {
  required int selectionIndex,
}) => implementation.billAttachmentFromPlatformFile(
  file,
  selectionIndex: selectionIndex,
);
