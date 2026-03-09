import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repository/repository/bills_repository.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

import '../data/tag_service.dart';
import '../model/tag_node.dart';
import '../../edit_bill/models/edit_select_item.dart';

class ParentTagSelectPage extends StatefulWidget {
  final int initialParentId;
  final int? currentTagId;

  const ParentTagSelectPage({
    Key? key,
    required this.initialParentId,
    this.currentTagId,
  }) : super(key: key);

  @override
  State<ParentTagSelectPage> createState() => _ParentTagSelectPageState();
}

class _ParentTagSelectPageState extends State<ParentTagSelectPage> {
  final TagPageService _service = TagPageService();
  List<TagSelectItem> _allTags =[];
  bool _loading = true;
  String? _error;

  List<int> _selectedPath =[];
  int _selectedParentId = -1;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _loading = true);
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final roots = await _service.fetchList(bookId: bookId, recycleBin: false);

      _allTags = _convertToSelectItems(roots);

      if (widget.initialParentId != -1) {
        _selectedParentId = widget.initialParentId;
        final path = _findPathTo(widget.initialParentId, _allTags);
        _selectedPath = path ??[];
      } else {
        _selectedParentId = -1;
        _selectedPath =[];
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<TagSelectItem> _convertToSelectItems(List<TagNode> nodes) {
    List<TagSelectItem> items =[];
    for (var node in nodes) {
      if (widget.currentTagId != null && node.id == widget.currentTagId) continue;
      var item = TagSelectItem(node.tagName, node.id);
      if (node.children.isNotEmpty) {
        item.children = _convertToSelectItems(node.children);
      }
      items.add(item);
    }
    return items;
  }

  List<int>? _findPathTo(int targetId, List<TagSelectItem> items) {
    for (var item in items) {
      if (item.id == targetId) return [item.id];
      if (item.children != null && item.children!.isNotEmpty) {
        var childPath = _findPathTo(targetId, item.children!);
        if (childPath != null) return[item.id, ...childPath];
      }
    }
    return null;
  }

  TagSelectItem? _findByIdInTree(List<TagSelectItem> items, int id) {
    for (var item in items) {
      if (item.id == id) return item;
      if (item.children != null && item.children!.isNotEmpty) {
        var found = _findByIdInTree(item.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _onTagTap(TagSelectItem node, int depth) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedPath.length > depth) {
        _selectedPath = _selectedPath.sublist(0, depth);
      }
      _selectedPath.add(node.id);
      _selectedParentId = node.id;
    });
  }

  void _onClearSelection() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedPath =[];
      _selectedParentId = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HJColors.background,
      appBar: AppBar(
        title: const Text('选择父级标签', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: HJColors.textPrimary)),
        centerTitle: true,
        backgroundColor: HJColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: HJColors.textPrimary),
        actions:[
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, _selectedParentId);
            },
            child: const Text('确定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HJColors.primary)),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: HJColors.primary))
          : _error != null
          ? Center(child: Text('加载失败: $_error', style: const TextStyle(color: HJColors.textSecondary)))
          : Column(
        children:[
          Padding(
            padding: const EdgeInsets.all(HJSpacing.md),
            child: HJPremiumCard(
              padding: const EdgeInsets.all(HJSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      const Text('当前选择路径', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: HJColors.textSecondary)),
                      if (_selectedParentId != -1)
                        GestureDetector(
                          onTap: _onClearSelection,
                          child: const Text('设为根标签', style: TextStyle(fontSize: 13, color: HJColors.primary, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: HJSpacing.sm),
                  Text(
                    _selectedParentId == -1 ? '根标签 (一级标签)' : _getPathString(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: HJColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(top: 8, bottom: HJSpacing.xl),
              child: _buildTagSelector(_allTags),
            ),
          ),
        ],
      ),
    );
  }

  String _getPathString() {
    if (_selectedPath.isEmpty) return '根标签';
    List<String> names =[];
    for (var id in _selectedPath) {
      var item = _findByIdInTree(_allTags, id);
      if (item != null) names.add(item.title);
    }
    return names.join('  ›  ');
  }

  Widget _buildTagSelector(List<TagSelectItem> tags) {
    if (tags.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('暂无标签可选', style: TextStyle(color: HJColors.textSecondary))));
    }
    final List<Widget> levelWidgets =[];
    if (tags.isNotEmpty) levelWidgets.add(_buildLevelSection(tags, 0));
    int depth = 1;
    while (depth <= _selectedPath.length) {
      final int parentId = _selectedPath[depth - 1];
      final TagSelectItem? parentNode = _findByIdInTree(tags, parentId);
      if (parentNode == null || parentNode.children == null || parentNode.children!.isEmpty) break;
      levelWidgets.add(_buildLevelSection(parentNode.children!, depth));
      depth++;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: levelWidgets);
  }

  Widget _buildLevelSection(List<TagSelectItem> nodes, int depth) {
    String title = depth == 0 ? '一级标签' : '子标签';
    if (depth > 0) {
      int parentId = _selectedPath[depth - 1];
      var parent = _findByIdInTree(_allTags, parentId);
      if (parent != null) title = '${parent.title} 的子类';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: HJColors.textSecondary)),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: HJSpacing.md),
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];
              final isSelected = _selectedPath.length > depth && _selectedPath[depth] == node.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(node.title),
                  selected: isSelected,
                  onSelected: (bool selected) => _onTagTap(node, depth),
                  backgroundColor: HJColors.surface,
                  selectedColor: HJColors.primary.withOpacity(0.12),
                  labelStyle: TextStyle(
                    color: isSelected ? HJColors.primary : HJColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isSelected ? HJColors.primary : HJColors.divider, width: 1),
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}