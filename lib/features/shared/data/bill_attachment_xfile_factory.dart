import 'package:image_picker/image_picker.dart' show XFile;
import 'package:cryptography/cryptography.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';

Future<BillAttachment?> billAttachmentFromXFile(
  XFile file, {
  required int selectionIndex,
  required int remainingBytes,
}) async {
  try {
    final sizeBytes = await file.length();
    if (sizeBytes == 0 ||
        sizeBytes > BillAttachmentValidator.maxSingleBytes ||
        sizeBytes > remainingBytes) {
      return null;
    }
    final bytes = await file.readAsBytes();
    return BytesBillAttachment(
      id: 'memory:${file.name}:${bytes.length}:${await _contentHash(bytes)}',
      name: file.name,
      bytes: bytes,
    );
  } on Object {
    return null;
  }
}

Future<String> _contentHash(List<int> bytes) async {
  final hash = await Sha256().hash(bytes);
  return hash.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}
