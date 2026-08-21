import 'dart:io';

Future<int?> inspectBillAttachmentPath(String path) async {
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.length();
  } on FileSystemException {
    return null;
  }
}
