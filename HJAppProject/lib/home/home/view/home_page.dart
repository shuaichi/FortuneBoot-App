import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/home/edit_bill/view/edit_bill_page.dart';
import 'package:fortuneboot/home/home/cubit/home_cubit.dart';
import 'package:fortuneboot/home/setting_page/view/setting_page.dart';
import 'package:fortuneboot/home/stats/view/stats_page.dart';
import 'package:fortuneboot/home/bill_overview/view/bills_overview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [BillsOverviewPage() /**, StatsPage() */, MinePage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        key: const Key('homeView_addTodo_floatingActionButton'),
        onPressed: () => Navigator.of(context).push(EditBillPage.route()),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  _HomeTabButton(
                    groupValue: selectedTab,
                    value: HomeTab.todos,
                    icon: const Icon(Icons.list_rounded),
                  ),
                  // const SizedBox(
                  //   width: 16,
                  // ),
                  // _HomeTabButton(
                  //   groupValue: selectedTab,
                  //   value: HomeTab.stats,
                  //   icon: const Icon(Icons.show_chart_rounded),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _HomeTabButton(
                    groupValue: selectedTab,
                    value: HomeTab.mine,
                    icon: const Icon(Icons.account_circle_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.groupValue,
    required this.value,
    required this.icon,
  });

  final HomeTab groupValue;
  final HomeTab value;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<HomeCubit>().setTab(value),
      iconSize: 32,
      color:
          groupValue != value ? null : Theme.of(context).colorScheme.secondary,
      icon: icon,
    );
  }
}
