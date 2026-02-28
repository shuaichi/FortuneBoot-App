import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/home/payee_manage/data/payee_service.dart';
import 'package:hjproject/home/payee_manage/model/payee.dart';
import 'package:hjproject/home/payee_manage/view/payee_add_page.dart';
import 'package:hjproject/home/payee_manage/view/payee_edit_page.dart';
import 'package:hjproject/home/payee_manage/view/widgets/enhanced_payee_type_selector.dart'; // For enum PayeeFilterType

// New Standard Components
import 'package:hjproject/home/payee_manage/view/widgets/payee_manage_appbar.dart';
import 'package:hjproject/home/payee_manage/view/widgets/payee_filter_bar.dart';
import 'package:hjproject/home/payee_manage/view/widgets/payee_list_view.dart';
import 'package:hjproject/Home/category_manage/view/widgets/category_delete_confirm_dialog.dart'; // Reuse dialog style

/// 交易对象管理页面 (Refactored to match CategoryManagePage)
class PayeeManagePage extends StatefulWidget {
  const PayeeManagePage({Key? key}) : super(key: key);

  @override
  State<PayeeManagePage> createState() => _PayeeManagePageState();
}

class _PayeeManagePageState extends State<PayeeManagePage> {
  final PayeeService _service = PayeeService();

  bool _loading = true;
  String? _error;
  List<Payee> _rows = const <Payee>[];
  int _total = 0;

  // Pagination
  int _pageNum = 1;
  final int _pageSize = 20;

  // Filter
  PayeeFilterType _selectedFilter = PayeeFilterType.all;

  // Navigation Debounce
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final data = await _service.fetch(
        bookId: bookId,
        pageNum: _pageNum,
        pageSize: _pageSize,
        filterType: _selectedFilter,
      );
      setState(() {
        _rows = data.rows;
        _total = data.total;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _onFilterChanged(PayeeFilterType type) {
    if (_selectedFilter == type) return;
    setState(() {
      _selectedFilter = type;
      _pageNum = 1;
    });
    _load();
  }

  bool get _hasPrev => _pageNum > 1;

  bool get _hasNext {
    return _pageNum * _pageSize < _total;
  }

  void _goPrev() {
    if (_hasPrev) {
      setState(() {
        _pageNum -= 1;
      });
      _load();
    }
  }

  void _goNext() {
    if (_hasNext) {
      setState(() {
        _pageNum += 1;
      });
      _load();
    }
  }

  Future<void> _onAddPressed() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Future.delayed(Duration.zero);

    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const PayeeAddPage(),
      ),
    );

    _isNavigating = false;

    if (ok == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('新增成功')),
      );
      await _load();
    }
  }

  Future<void> _onModify(Payee item) async {
    if (_isNavigating) return;
    _isNavigating = true;

    final bookId = context.read<BillsRepository>().bookId() ?? item.bookId;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PayeeEditPage(payee: item, bookId: bookId),
      ),
    );

    _isNavigating = false;

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('修改成功')),
      );
      await _load();
    }
  }

  Future<void> _onMoveToRecycle(Payee item) async {
    // Reuse CategoryDeleteConfirmDialog but adapted for Payee logic
    // We might need to make the dialog text generic or check if we can pass title
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CategoryDeleteConfirmDialog(
          categoryName: item.payeeName, // Display payee name
          onConfirm: () async {
            final bookId = context.read<BillsRepository>().bookId() ?? item.bookId;
            await _service.moveToRecycleBin(bookId: bookId, payeeId: item.payeeId);
          },
        );
      },
    );

    if (confirmed == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已移入回收站')),
      );
      
      // Update logic: if current page becomes empty, go back 1 page
      setState(() {
        _total = (_total > 0) ? _total - 1 : 0;
      });
      final int startIndex = (_pageNum - 1) * _pageSize;
      if (_rows.length <= 1 && _pageNum > 1 && startIndex >= _total) {
        setState(() {
          _pageNum -= 1;
        });
      }
      
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double gap = width < 600 ? 8 : 12;

    String typeText = '全部';
    if (_selectedFilter == PayeeFilterType.expenseEnabled) typeText = '支出';
    if (_selectedFilter == PayeeFilterType.incomeEnabled) typeText = '收入';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PayeeManageAppBar(
        onAddPressed: _onAddPressed,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: PayeeFilterBar(
              selectedType: _selectedFilter,
              onTypeChanged: _onFilterChanged,
            ),
          ),
          SizedBox(height: gap),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _pageNum = 1;
                await _load();
              },
              child: PayeeListView(
                loading: _loading,
                error: _error,
                onRetry: _load,
                total: _total,
                currentPage: _pageNum,
                rows: _rows,
                typeText: typeText,
                onModify: _onModify,
                onMoveToRecycle: _onMoveToRecycle,
                hasPrev: _hasPrev,
                hasNext: _hasNext,
                onPrev: _goPrev,
                onNext: _goNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}