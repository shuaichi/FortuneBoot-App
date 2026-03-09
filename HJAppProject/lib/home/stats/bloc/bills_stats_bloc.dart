import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hjproject/login/model/login_model.dart';
import 'package:intl/intl.dart';

import 'package:hjproject/request/include_request.dart';
import '../models/stats_models.dart';

/// --- EVENTS ---
abstract class BillsStatsEvent extends Equatable {
  const BillsStatsEvent();
  @override
  List<Object?> get props =>[];
}

class BillsStatsRequested extends BillsStatsEvent {
  final int groupId;
  final int bookId;
  final DateTime startDate;
  final DateTime endDate;

  const BillsStatsRequested({
    required this.groupId,
    required this.bookId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [groupId, bookId, startDate, endDate];
}

/// --- STATES ---
enum BillsStatsStatus { initial, loading, success, failure }

class BillsStatsState extends Equatable {
  final BillsStatsStatus status;
  final DateTime? startDate;
  final DateTime? endDate;

  final BillStatisticsVo? statistics;
  final FortuneAssetsLiabilitiesVo? assetsLiabilities;
  final List<FortuneLineVo> incomeTrends;
  final List<FortuneLineVo> expenseTrends;
  final List<FortunePieVo> categoryIncome;
  final List<FortunePieVo> categoryExpense;
  final List<FortuneBarVo> tagExpense;

  const BillsStatsState({
    this.status = BillsStatsStatus.initial,
    this.startDate,
    this.endDate,
    this.statistics,
    this.assetsLiabilities,
    this.incomeTrends = const [],
    this.expenseTrends = const[],
    this.categoryIncome = const [],
    this.categoryExpense = const [],
    this.tagExpense = const[],
  });

  BillsStatsState copyWith({
    BillsStatsStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    BillStatisticsVo? statistics,
    FortuneAssetsLiabilitiesVo? assetsLiabilities,
    List<FortuneLineVo>? incomeTrends,
    List<FortuneLineVo>? expenseTrends,
    List<FortunePieVo>? categoryIncome,
    List<FortunePieVo>? categoryExpense,
    List<FortuneBarVo>? tagExpense,
  }) {
    return BillsStatsState(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      statistics: statistics ?? this.statistics,
      assetsLiabilities: assetsLiabilities ?? this.assetsLiabilities,
      incomeTrends: incomeTrends ?? this.incomeTrends,
      expenseTrends: expenseTrends ?? this.expenseTrends,
      categoryIncome: categoryIncome ?? this.categoryIncome,
      categoryExpense: categoryExpense ?? this.categoryExpense,
      tagExpense: tagExpense ?? this.tagExpense,
    );
  }

  @override
  List<Object?> get props =>[
    status, startDate, endDate, statistics, assetsLiabilities,
    incomeTrends, expenseTrends, categoryIncome, categoryExpense, tagExpense
  ];
}

/// --- BLOC ---
class BillsStatsBloc extends Bloc<BillsStatsEvent, BillsStatsState> {
  final IncludeService includeService;

  BillsStatsBloc({required this.includeService}) : super(const BillsStatsState()) {
    on<BillsStatsRequested>(_onSubscriptionRequested);
  }

  dynamic _extractData(HJResponse response) {
    if (response.code == 0 && response.data != null) {
      return response.data;
    }
    return null;
  }

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data == null || data is! List) return[];
    // 修复：增加了 as Map 进行安全强转
    return data.map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _onSubscriptionRequested(BillsStatsRequested event, Emitter<BillsStatsState> emit) async {
    emit(state.copyWith(status: BillsStatsStatus.loading, startDate: event.startDate, endDate: event.endDate));

    try {
      final dateFormater = DateFormat('yyyy-MM-dd');
      final timePointFormater = DateFormat('yyyy-MM-dd HH:mm:ss');

      final startStr = dateFormater.format(event.startDate);
      final endStr = dateFormater.format(event.endDate);
      final timePointStr = timePointFormater.format(event.endDate);

      final results = await Future.wait([
        includeService.getBillStatistics(event.bookId, startStr, endStr),
        includeService.getFortuneAssetsLiabilities(event.groupId),
        includeService.getIncomeTrends(event.bookId, 3, timePointStr),
        includeService.getExpenseTrends(event.bookId, 3, timePointStr),
        includeService.getCategoryIncome(event.bookId, startStr, endStr),
        includeService.getCategoryExpense(event.bookId, startStr, endStr),
        includeService.getTagExpense(event.bookId, startStr, endStr),
      ]);

      final statData = _extractData(results[0]);
      final assetData = _extractData(results[1]);

      emit(state.copyWith(
        status: BillsStatsStatus.success,
        // 修复：增加了 as Map 进行安全强转
        statistics: statData != null
            ? BillStatisticsVo.fromJson(Map<String, dynamic>.from(statData as Map))
            : const BillStatisticsVo(),
        assetsLiabilities: assetData != null
            ? FortuneAssetsLiabilitiesVo.fromJson(Map<String, dynamic>.from(assetData as Map))
            : const FortuneAssetsLiabilitiesVo(),
        incomeTrends: _parseList(_extractData(results[2]), FortuneLineVo.fromJson),
        expenseTrends: _parseList(_extractData(results[3]), FortuneLineVo.fromJson),
        categoryIncome: _parseList(_extractData(results[4]), FortunePieVo.fromJson),
        categoryExpense: _parseList(_extractData(results[5]), FortunePieVo.fromJson),
        tagExpense: _parseList(_extractData(results[6]), FortuneBarVo.fromJson),
      ));
    } catch (e) {
      print('加载失败: $e');
      emit(state.copyWith(status: BillsStatsStatus.failure));
    }
  }
}