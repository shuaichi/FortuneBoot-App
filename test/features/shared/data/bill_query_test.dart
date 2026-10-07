import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/shared/data/bill_service.dart';

void main() {
  group('BillQuery.toQueryParams', () {
    test('maps single billTypes entry to billType for backend', () {
      final params = const BillQuery(
        bookId: 1,
        billTypes: [2],
      ).toQueryParams();
      expect(params['billType'], 2);
      expect(params.containsKey('billTypes'), isFalse);
    });

    test('does not send billTypes array when multiple selected', () {
      final params = const BillQuery(
        bookId: 1,
        billTypes: [1, 2],
      ).toQueryParams();
      expect(params.containsKey('billType'), isFalse);
      expect(params.containsKey('billTypes'), isFalse);
    });

    test('prefers explicit billType over billTypes', () {
      final params = const BillQuery(
        bookId: 1,
        billType: 2,
        billTypes: [1],
      ).toQueryParams();
      expect(params['billType'], 2);
    });

    test('includes memberIds when provided', () {
      final params = const BillQuery(
        bookId: 1,
        memberIds: [7, 8],
      ).toQueryParams();
      expect(params['memberIds'], [7, 8]);
    });
  });
}
