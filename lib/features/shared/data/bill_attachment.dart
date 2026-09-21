import 'dart:typed_data';

sealed class BillAttachment {
  const BillAttachment({
    required this.id,
    required this.name,
    required this.sizeBytes,
  });

  final String id;
  final String name;
  final int sizeBytes;
}

final class BytesBillAttachment extends BillAttachment {
  const BytesBillAttachment({
    required super.id,
    required super.name,
    required this.bytes,
  }) : super(sizeBytes: bytes.length);

  final Uint8List bytes;
}

final class PathBillAttachment extends BillAttachment {
  const PathBillAttachment({
    required super.name,
    required super.sizeBytes,
    required this.path,
  }) : super(id: 'path:$path');

  final String path;
}
