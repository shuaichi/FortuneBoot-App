import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/preferences/preferences_cubit.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/shell/main_shell.dart';
import 'package:fortuneboot/features/bills/presentation/bills_page.dart';
import 'package:fortuneboot/features/bills/presentation/bloc/bills_bloc.dart';

/// 把 Bills feature 注入 MainShell 的账单 tab。在 main() runApp 前调用。
void registerBillsSlot() {
  MainShellSlots.bills = (context) {
    final bookId = context.read<SessionCubit>().state.currentBookId;
    final monthStartDay = context
        .read<PreferencesCubit>()
        .state
        .billing
        .monthStartDay;
    return BlocProvider<BillsBloc>(
      create: (_) => BillsBloc(bookId: bookId, monthStartDay: monthStartDay),
      child: const BillsPage(),
    );
  };
}
