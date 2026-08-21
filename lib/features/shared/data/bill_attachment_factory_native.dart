import 'package:file_picker/file_picker.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';

Future<BillAttachment?> billAttachmentFromPlatformFile(
  PlatformFile file, {
  required int selectionIndex,
}) async {
  final path = file.path;
  if (path == null) return null;
  return PathBillAttachment(name: file.name, sizeBytes: file.size, path: path);
}
