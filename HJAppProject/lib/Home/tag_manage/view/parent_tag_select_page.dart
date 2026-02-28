import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repository/repository/bills_repository.dart';
import '../data/tag_service.dart';
import '../model/tag_node.dart';
import '../../edit_bill/models/edit_select_item.dart';

class ParentTagSelectPage extends StatefulWidget {
  final int initialParentId; // -1 represents Root
  final int? currentTagId; // Current tag ID (if editing), to prevent selecting itself as parent

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
  List<TagSelectItem> _allTags = [];
  bool _loading = true;
  String? _error;

  // Selected path (list of tag IDs)
  List<int> _selectedPath = [];
  int _selectedParentId = -1; // -1 represents Root

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _loading = true);
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final roots = await _service.fetchList(
        bookId: bookId,
        recycleBin: false,
      );

      // Convert TagNode to TagSelectItem for UI compatibility
      // Also filter out current tag to prevent cycles if needed
      _allTags = _convertToSelectItems(roots);

      // Initialize selection
      if (widget.initialParentId != -1) {
        _selectedParentId = widget.initialParentId;
        final path = _findPathTo(widget.initialParentId, _allTags);
        _selectedPath = path ?? [];
      } else {
        _selectedParentId = -1;
        _selectedPath = [];
      }

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Convert service model to UI model
  List<TagSelectItem> _convertToSelectItems(List<TagNode> nodes) {
    List<TagSelectItem> items = [];
    for (var node in nodes) {
      // If we are editing a tag, don't include itself or its children as potential parents
      if (widget.currentTagId != null && node.id == widget.currentTagId) {
        continue;
      }

      var item = TagSelectItem(node.tagName, node.id);
      if (node.children.isNotEmpty) {
        item.children = _convertToSelectItems(node.children);
      }
      items.add(item);
    }
    return items;
  }

  // Find path to a specific tag ID
  List<int>? _findPathTo(int targetId, List<TagSelectItem> items) {
    for (var item in items) {
      if (item.id == targetId) return [item.id];
      if (item.children != null && item.children!.isNotEmpty) {
        var childPath = _findPathTo(targetId, item.children!);
        if (childPath != null) {
          return [item.id, ...childPath];
        }
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
    setState(() {
      // 1. Update Path
      // If tapping a node at depth X, truncate path to X then add new node
      if (_selectedPath.length > depth) {
        _selectedPath = _selectedPath.sublist(0, depth);
      }
      _selectedPath.add(node.id);

      // 2. Update Selected ID
      _selectedParentId = node.id;
    });
  }

  void _onClearSelection() {
    setState(() {
      _selectedPath = [];
      _selectedParentId = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Design Tokens
    const Color bgColor = Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('选择父级标签', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedParentId);
            },
            child: const Text('确定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('加载失败: $_error'))
              : Column(
                  children: [
                    // Selected State Display
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '当前选择',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              if (_selectedParentId != -1)
                                GestureDetector(
                                  onTap: _onClearSelection,
                                  child: const Text(
                                    '设为根标签',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedParentId == -1
                                ? '根标签 (一级标签)'
                                : _getPathString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Tag Tree Selector
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildTagSelector(_allTags),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _getPathString() {
    if (_selectedPath.isEmpty) return '根标签';
    List<String> names = [];
    for (var id in _selectedPath) {
      var item = _findByIdInTree(_allTags, id);
      if (item != null) names.add(item.title);
    }
    return names.join(' > ');
  }

  Widget _buildTagSelector(List<TagSelectItem> tags) {
    if (tags.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('暂无标签可选', style: TextStyle(color: Colors.grey)),
      ));
    }

    final List<Widget> levelWidgets = [];

    // Level 0 (Roots)
    if (tags.isNotEmpty) {
      levelWidgets.add(_buildLevelSection(tags, 0));
    }

    // Dynamic Levels based on selection
    int depth = 1;
    while (depth <= _selectedPath.length) {
      final int parentId = _selectedPath[depth - 1];
      final TagSelectItem? parentNode = _findByIdInTree(tags, parentId);

      if (parentNode == null ||
          parentNode.children == null ||
          parentNode.children!.isEmpty) {
        break;
      }

      levelWidgets.add(_buildLevelSection(parentNode.children!, depth));
      depth++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: levelWidgets,
    );
  }

  Widget _buildLevelSection(List<TagSelectItem> nodes, int depth) {
    String title = depth == 0 ? '一级标签' : '子标签';
    if (depth > 0) {
      // Find parent name for better context
      int parentId = _selectedPath[depth - 1];
      var parent = _findByIdInTree(_allTags, parentId);
      if (parent != null) title = '${parent.title} 的子类';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];
              final isSelected = _selectedPath.length > depth &&
                  _selectedPath[depth] == node.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(node.title),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    _onTagTap(node, depth);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
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