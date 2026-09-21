import 'package:fortuneboot/features/shared/data/bill_attachment_picker_config_native.dart'
    if (dart.library.html) 'package:fortuneboot/features/shared/data/bill_attachment_picker_config_web.dart'
    as implementation;

bool get shouldLoadBillAttachmentBytes =>
    implementation.shouldLoadBillAttachmentBytes;
