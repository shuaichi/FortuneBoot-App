import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment.dart';
import 'package:fortuneboot/features/shared/data/bill_attachment_validator.dart';

void main() {
  group('BillAttachmentValidator', () {
    late Directory directory;
    late BillAttachmentValidator validator;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('bill_attachment_test');
      validator = const BillAttachmentValidator();
    });

    tearDown(() => directory.delete(recursive: true));

    test('accepts a readable non-empty path attachment', () async {
      final file = await _createFile(directory, 'invoice.pdf', 1024);
      final attachment = PathBillAttachment(
        name: 'invoice.pdf',
        sizeBytes: 1024,
        path: file.path,
      );

      final inspection = await validator.inspect(attachment);

      expect(inspection.attachment, attachment);
      expect(inspection.sizeBytes, 1024);
    });

    test('accepts a non-empty bytes attachment without path I/O', () async {
      final attachment = BytesBillAttachment(
        id: 'memory:1',
        name: 'invoice.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      final inspection = await validator.inspect(attachment);

      expect(inspection.attachment, attachment);
      expect(inspection.sizeBytes, 3);
    });

    test('rejects an empty bytes attachment', () async {
      final attachment = BytesBillAttachment(
        id: 'memory:empty',
        name: 'empty.zip',
        bytes: Uint8List(0),
      );

      await _expectReason(
        validator.inspect(attachment),
        BillAttachmentValidationReason.empty,
      );
    });

    test('rejects a path attachment larger than the per-file limit', () async {
      final file = await _createFile(
        directory,
        'large.bin',
        BillAttachmentValidator.maxSingleBytes + 1,
      );
      final attachment = PathBillAttachment(
        name: 'large.bin',
        sizeBytes: BillAttachmentValidator.maxSingleBytes + 1,
        path: file.path,
      );

      await _expectReason(
        validator.inspect(attachment),
        BillAttachmentValidationReason.fileTooLarge,
      );
    });

    test('rejects missing path attachments', () async {
      final attachment = PathBillAttachment(
        name: 'missing.txt',
        sizeBytes: 1,
        path: '${directory.path}/missing.txt',
      );

      await _expectReason(
        validator.inspect(attachment),
        BillAttachmentValidationReason.unreadable,
      );
    });

    test('rejects a collection exceeding the total limit', () async {
      final attachments = List.generate(
        5,
        (index) => BytesBillAttachment(
          id: 'memory:$index',
          name: '$index.bin',
          bytes: Uint8List(
            index == 4 ? 1 : BillAttachmentValidator.maxSingleBytes,
          ),
        ),
      );

      await _expectReason(
        validator.inspectAll(attachments),
        BillAttachmentValidationReason.totalTooLarge,
      );
    });
  });
}

Future<void> _expectReason(
  Future<Object> future,
  BillAttachmentValidationReason reason,
) {
  return expectLater(
    future,
    throwsA(
      isA<BillAttachmentValidationException>().having(
        (error) => error.reason,
        'reason',
        reason,
      ),
    ),
  );
}

Future<File> _createFile(Directory directory, String name, int bytes) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes(List<int>.filled(bytes, 1));
  return file;
}
