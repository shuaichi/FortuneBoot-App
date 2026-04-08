import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_file_item.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:fortuneboot/login/model/login_model.dart';
import 'package:fortuneboot/request/bill_request.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';

part 'bill_detail_event.dart';

part 'bill_detail_state.dart';

class BillDetailBloc extends Bloc<BillDetailEvent, BillDetailState> {
  BillDetailBloc({
    required BillItem initialBill,
  }) : super(
          BillDetailState(
            initialBill: initialBill,
          ),
        ) {
    on<BillLoadFile>(_onLoadFileData);
  }

  final BillService _billService = BillService();

  FutureOr<void> _onLoadFileData(
      BillLoadFile event, Emitter<BillDetailState> emit) async {
    HJResponse response = await _billService.getByBillFileId(event.billId);
    if (response.code == 0) {
      final list = response.data as List? ?? [];
      List<BillFileItem> files = [];
      for (final item in list) {
        files.add(BillFileItem.fromJson(
            Map<String, dynamic>.from(item as Map? ?? {})));
      }
      if (!fileEqual(files, state.initialBill.fileList)) {
        state.initialBill.fileList = files;
        emit(state.copyWith(initialBill: state.initialBill));
      }
    }
  }

  bool fileEqual(List<BillFileItem>? filesA, List<BillFileItem>? filesB) {
    if (filesA == null || filesB == null) {
      return false;
    }
    if (filesA.length != filesB.length) {
      return false;
    }
    return !filesA.any((ele) {
      return !filesB.contains(ele);
    });
  }
}
