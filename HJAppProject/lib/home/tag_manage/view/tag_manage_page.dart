import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/util/dio_client.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';

import '../data/tag_service.dart';
import '../model/tag_node.dart';
import 'widgets/tag_delete_confirm_dialog.dart';
import 'tag_edit_page.dart';
import 'tag_add_page.dart';
import 'widgets/tag_list_view.dart';
import 'widgets/tag_manage_appbar.dart';

class TagManagePage extends StatefulWidget {
  const TagManagePage({Key? key}) : super(key: key);

  @override
  State<TagManagePage> createState() => _TagManagePageState();
}

class _TagManagePageState extends State<TagManagePage> {
  int _currentPage = 1;
  int _total = 0;
  int _lastPageSize = 0;
  bool _loading = true;
  String? _error;
  List<TagNode> _roots = [];
  final Set<int> _expandedNodeIds = {};

  final TagPageService _service = TagPageService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final data = await _service.fetch(
        bookId: bookId,
        pageNum: _currentPage,
      );
      setState(() {
        _total = data.total;
        _roots = data.rows;
        _lastPageSize = data.rows.length;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool get _hasPrev => _currentPage > 1;

  bool get _hasNext {
    if (_lastPageSize <= 0) return false;
    return _currentPage * _lastPageSize < _total;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double gap = width < 600 ? 8 : 12;
    return Scaffold(
      appBar: TagManageAppBar(
        onAddPressed: () => _openAddPage(initialParentId: -1),
      ),
      body: Column(
        children: [
          SizedBox(height: gap),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _currentPage = 1;
                await _load();
              },
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return TagListView<TagNode>(
      loading: _loading,
      error: _error,
      onRetry: _load,
      typeText: '标签',
      total: _total,
      currentPage: _currentPage,
      roots: _roots,
      expandedNodeIds: _expandedNodeIds,
      childrenOf: (n) => n.children,
      nameOf: (n) => n.tagName,
      remarkOf: (n) => n.remark,
      idOf: (n) => n.tagId,
      enableOf: (n) => n.enable,
      canExpenseOf: (n) => n.canExpense,
      canIncomeOf: (n) => n.canIncome,
      canTransferOf: (n) => n.canTransfer,
      iconOf: (n) => n.icon,
      onToggleNode: (node, expanded) {
        setState(() {
          if (expanded) {
            _expandedNodeIds.add(node.tagId);
          } else {
            _expandedNodeIds.remove(node.tagId);
          }
        });
      },
      onModify: (node) => _openEditPage(node),
      onMoveToRecycle: (node) => _confirmMoveToRecycle(node),
      onAddChild: (node) => _openAddPage(initialParentId: node.tagId),
      hasPrev: _hasPrev,
      hasNext: _hasNext,
      onPrev: () {
        setState(() => _currentPage -= 1);
        _load();
      },
      onNext: () {
        setState(() => _currentPage += 1);
        _load();
      },
    );
  }

  Future<void> _confirmMoveToRecycle(TagNode node) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return TagDeleteConfirmDialog(
          tagName: node.tagName,
          onConfirm: () async {
            final bookId = context.read<BillsRepository>().bookId() ?? 1;
            await _service.moveToRecycleBin(
              bookId: bookId,
              tagId: node.tagId,
            );
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
      await _load();
    }
  }

String? _findTagNameById(int id) {
    if (id == -1) return null;
    String? result;
    void dfs(List<TagNode> nodes) {
      for (final n in nodes) {
        if (n.tagId == id) {
          result = n.tagName;
          return;
        }
        if (n.children.isNotEmpty) {
          dfs(n.children);
          if (result != null) return;
        }
      }
    }
    dfs(_roots);
    return result;
  }
  Future<void> _openEditPage(TagNode node) async {
    final int bookId = context.read<BillsRepository>().bookId() ?? 1;
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TagEditPage(
          tagId: node.tagId,
          name: node.tagName,
          enable: node.enable,
          sort: node.sort,
          remark: node.remark,
          canExpense: node.canExpense,
          canIncome: node.canIncome,
          canTransfer: node.canTransfer,
          parentId: node.parentId,
          bookId: bookId,
          parentName: _findTagNameById(node.parentId),
          icon: node.icon,
        ),
      ),
    );
    if (ok == true) {
      await _load();
    }
  }

  Future<void> _openAddPage({required int initialParentId}) async {
    final int bookId = context.read<BillsRepository>().bookId() ?? 1;
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TagAddPage(
          initialParentId: initialParentId,
          bookId: bookId,
          initialParentName: _findTagNameById(initialParentId),
        ),
      ),
    );
    if (ok == true) {
      await _load();
    }
  }
}