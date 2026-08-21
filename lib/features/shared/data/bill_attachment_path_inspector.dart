import 'package:fortuneboot/features/shared/data/bill_attachment_path_inspector_native.dart'
    if (dart.library.html) 'package:fortuneboot/features/shared/data/bill_attachment_path_inspector_web.dart'
    as implementation;

Future<int?> inspectBillAttachmentPath(String path) =>
    implementation.inspectBillAttachmentPath(path);
