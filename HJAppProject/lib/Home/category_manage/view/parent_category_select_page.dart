import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hjproject/repository/repository/bills_repository.dart';
import 'package:hjproject/Home/category_manage/data/category_service.dart';
import 'package:hjproject/home/edit_bill/models/edit_select_item.dart';

class ParentCategorySelectPage extends StatefulWidget {
  final int categoryType; // 1: 支出, 2: 收入
  final int initialParentId; // -1 表示根分类
  final int? currentCategoryId; // 当前编辑的分类ID（如果有），防止选自己为父类

  const ParentCategorySelectPage({
    Key? key,
    required this.categoryType,
    required this.initialParentId,
    this.currentCategoryId,
  }) : super(key: key);

  @override
  State<ParentCategorySelectPage> createState() => _ParentCategorySelectPageState();
}

class _ParentCategorySelectPageState extends State<ParentCategorySelectPage> {
  final CategoryPageService _service = CategoryPageService();
  List<CategorySelectItem> _allCategories = [];
  bool _loading = true;
  String? _error;

  // Selected path (list of category IDs)
  List<int> _selectedPath = [];
  int _selectedParentId = -1; // -1 represents Root

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final bookId = context.read<BillsRepository>().bookId() ?? 1;
      final roots = await _service.fetchList(
        bookId: bookId,
        categoryType: widget.categoryType,
        recycleBin: false,
      );

      // Convert CategoryNode to CategorySelectItem for UI compatibility
      // Also filter out current category to prevent cycles if needed
      _allCategories = _convertToSelectItems(roots);
      
      // Initialize selection
      if (widget.initialParentId != -1) {
        _selectedParentId = widget.initialParentId;
        _selectedPath = _findPathTo(widget.initialParentId, _allCategories) ?? [];
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
  List<CategorySelectItem> _convertToSelectItems(List<CategoryNode> nodes) {
    List<CategorySelectItem> items = [];
    for (var node in nodes) {
      // If we are editing a category, don't include itself or its children as potential parents
      if (widget.currentCategoryId != null && node.id == widget.currentCategoryId) {
        continue;
      }
      
      var item = CategorySelectItem(node.categoryName, node.id);
      if (node.children.isNotEmpty) {
        item.children = _convertToSelectItems(node.children);
      }
      items.add(item);
    }
    return items;
  }

  // Find path to a specific category ID
  List<int>? _findPathTo(int targetId, List<CategorySelectItem> items) {
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

  CategorySelectItem? _findByIdInTree(List<CategorySelectItem> items, int id) {
    for (var item in items) {
      if (item.id == id) return item;
      if (item.children != null && item.children!.isNotEmpty) {
        var found = _findByIdInTree(item.children!, id);
        if (found != null) return found;
      }
    }
    return null;
  }
  
  void _onCategoryTap(CategorySelectItem node, int depth) {
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
        title: const Text('选择父级分类', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                    '设为根分类',
                                    style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedParentId == -1 
                                ? '根分类 (一级分类)' 
                                : _getPathString(),
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1),
                    
                    // Category Tree Selector (Reused Interaction Logic)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildCategorySelector(_allCategories),
                      ),
                    ),
                  ],
                ),
    );
  }

  String _getPathString() {
    if (_selectedPath.isEmpty) return '根分类';
    List<String> names = [];
    for (var id in _selectedPath) {
      var item = _findByIdInTree(_allCategories, id);
      if (item != null) names.add(item.title);
    }
    return names.join(' > ');
  }

  // --- Reused Interaction Logic from CategorySelectField ---
  
  Widget _buildCategorySelector(List<CategorySelectItem> categories) {
    if (categories.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('暂无分类可选', style: TextStyle(color: Colors.grey)),
      ));
    }
    
    final List<Widget> levelWidgets = [];

    // Level 0 (Roots)
    levelWidgets.add(_buildLevelRow(categories, 0));

    // Dynamic Levels based on selection
    int depth = 1;
    while (true) {
      final int? parentId = depth - 1 < _selectedPath.length ? _selectedPath[depth - 1] : null;
      if (parentId == null) break;
      
      final CategorySelectItem? parentNode = _findByIdInTree(categories, parentId);
      if (parentNode == null || parentNode.children == null || parentNode.children!.isEmpty) {
        break;
      }
      
      levelWidgets.add(_buildLevelRow(parentNode.children!, depth));
      depth++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: levelWidgets,
    );
  }

  Widget _buildLevelRow(List<CategorySelectItem> nodes, int depth) {
    // Title for the level
    String title = depth == 0 ? '一级分类' : '子分类';
    if (depth > 0) {
      // Find parent name for better context
       int parentId = _selectedPath[depth-1];
       var parent = _findByIdInTree(_allCategories, parentId);
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
          height: 50, // Fixed height for horizontal list
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: nodes.length,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final node = nodes[index];
              final bool isSelected = _selectedPath.length > depth && _selectedPath[depth] == node.id;
              // Check if this node is the *current* selection (leaf of path)
              final bool isCurrentTarget = _selectedParentId == node.id;
              
              return _buildCategoryChip(node, isSelected, isCurrentTarget, depth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(CategorySelectItem node, bool isPathSelected, bool isTarget, int depth) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Style logic matching standard
    final bool isSelected = isPathSelected || isTarget;
    final Color bgColor = isSelected ? colorScheme.primaryContainer : Colors.white;
    final Color borderColor = isSelected ? colorScheme.primary : Colors.grey.shade300;
    final Color textColor = isSelected ? colorScheme.primary : Colors.black87;
    final FontWeight fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onCategoryTap(node, depth),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                node.title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: 14,
                ),
              ),
              if (node.children != null && node.children!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.arrow_right_alt,
                    size: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}