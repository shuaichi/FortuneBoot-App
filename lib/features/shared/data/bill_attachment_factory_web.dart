import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';

Future<BillAttachment?> billAttachmentFromPlatformFile(
  PlatformFile file, {
  required int selectionIndex,
}) async {
  final bytes = file.bytes;
  if (bytes == null) return null;
  return BytesBillAttachment(
    id: 'memory:${file.name}:${file.size}:${await _contentHash(bytes)}',
    name: file.name,
    bytes: bytes,
  );
}

Future<String> _contentHash(List<int> bytes) async {
  final hash = await Sha256().hash(bytes);
  return hash.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}
