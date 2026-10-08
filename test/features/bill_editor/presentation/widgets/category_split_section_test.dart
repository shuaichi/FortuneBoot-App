import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fortuneboot/features/bill_editor/data/editor_options_service.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_args.dart';
import 'package:fortuneboot/features/bill_editor/presentation/bill_editor_bloc.dart';
import 'package:fortuneboot/features/bill_editor/presentation/widgets/category_split_section.dart';
import 'package:fortuneboot/features/shared/data/bill_models.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/generated/l10n.dart';

void main() {
  testWidgets('advance bill offers expense categories', (tester) async {
    final bloc = await _readyBloc(FxBillType.advance);

    await _openCategoryPicker(tester, bloc);

    expect(find.text('餐饮支出'), findsOneWidget);
    expect(find.text('报销收入'), findsNothing);
  });

  testWidgets('reimburse bill offers income categories', (tester) async {
    final bloc = await _readyBloc(FxBillType.reimburse);

    await _openCategoryPicker(tester, bloc);

    expect(find.text('报销收入'), findsOneWidget);
    expect(find.text('餐饮支出'), findsNothing);
  });
}

Future<BillEditorBloc> _readyBloc(FxBillType billType) async {
  final bloc = BillEditorBloc(
    bookId: 1,
    groupId: 1,
    optionsService: _FakeEditorOptionsService(),
  );
  final ready = bloc.stream.firstWhere(
    (state) => state.status == EditorStatus.ready,
  );
  bloc.add(const BillEditorInitialized(BillEditorArgs(mode: 'new')));
  await ready;
  bloc.add(BillTypeChanged(billType));
  await bloc.stream.firstWhere((state) => state.billType == billType);
  return bloc;
}

Future<void> _openCategoryPicker(
  WidgetTester tester,
  BillEditorBloc bloc,
) async {
  await tester.pumpWidget(_app(bloc));
  await tester.tap(find.text('选择分类'));
  await tester.pumpAndSettle();
}

Widget _app(BillEditorBloc bloc) {
  return MaterialApp(
    theme: FxTheme.light,
    locale: const Locale('zh'),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      S.delegate,
    ],
    supportedLocales: S.delegate.supportedLocales,
    home: Scaffold(
      body: BlocProvider.value(
        value: bloc,
        child: CategorySplitSection(
          state: bloc.state,
          currencyCode: 'CNY',
        ),
      ),
    ),
  );
}

class _FakeEditorOptionsService extends EditorOptionsService {
  @override
  Future<EditorOptions> loadAll({
    required int bookId,
    required int groupId,
  }) async {
    return const EditorOptions(
      expenseCategories: [
        CategoryNode(categoryId: 1, categoryName: '餐饮支出', categoryType: 1),
      ],
      incomeCategories: [
        CategoryNode(categoryId: 2, categoryName: '报销收入', categoryType: 2),
      ],
    );
  }
}
