import 'package:flutter/material.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 管理类模块统一 tab：全部 / 启用 / 停用 / 回收站。
///
/// - [recycleBin]：是否查询回收站（决定服务端 recycleBin 维度）。
/// - [enableFilter]：本地按 enable 过滤（null 表示不过滤）。
enum ManageTab { all, enabled, disabled, recycleBin }

extension ManageTabX on ManageTab {
  String get label => switch (this) {
    ManageTab.all => '全部',
    ManageTab.enabled => '启用',
    ManageTab.disabled => '停用',
    ManageTab.recycleBin => '回收站',
  };

  bool get recycleBin => this == ManageTab.recycleBin;

  /// 本地 enable 过滤：全部/回收站不过滤；启用=true；停用=false。
  bool? get enableFilter => switch (this) {
    ManageTab.enabled => true,
    ManageTab.disabled => false,
    _ => null,
  };
}

/// 四个管理类模块共用的页面骨架：
/// 顶部 [←] 标题 [🔍搜索][+新增] + 全部/启用/停用/回收站 tab + body 槽。
///
/// 树形/列表内容由 [body] 注入；搜索输入通过 [onSearch] 上抛（页面/ bloc 处理过滤）。
class ManageScaffold extends StatefulWidget {
  final String title;
  final VoidCallback onAdd;
  final ValueChanged<String> onSearch;
  final String? searchHint;
  final ManageTab tab;
  final ValueChanged<ManageTab> onTabChanged;
  final Widget body;

  const ManageScaffold({
    super.key,
    required this.title,
    required this.onAdd,
    required this.onSearch,
    required this.tab,
    required this.onTabChanged,
    required this.body,
    this.searchHint,
  });

  @override
  State<ManageScaffold> createState() => _ManageScaffoldState();
}

class _ManageScaffoldState extends State<ManageScaffold> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
      widget.onSearch('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            if (_searching) _buildSearchField(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: FxSegmented<ManageTab>(
                value: widget.tab,
                onChanged: widget.onTabChanged,
                segments: [
                  FxSegment(ManageTab.all, S.of(context).manageSharedTabAll),
                  FxSegment(
                    ManageTab.enabled,
                    S.of(context).manageSharedTabEnabled,
                  ),
                  FxSegment(
                    ManageTab.disabled,
                    S.of(context).manageSharedTabDisabled,
                  ),
                  FxSegment(
                    ManageTab.recycleBin,
                    S.of(context).manageSharedTabRecycleBin,
                  ),
                ],
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          _iconButton(
            Icons.chevron_left_rounded,
            () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: Text(widget.title, style: FxTypography.title)),
          _iconButton(
            _searching ? Icons.search_off_rounded : Icons.search_rounded,
            _toggleSearch,
          ),
          const SizedBox(width: FxSpacing.xs),
          _iconButton(Icons.add_rounded, widget.onAdd),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? S.of(context).manageSharedSearchHint,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: palette.surfaceMuted,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: FxSpacing.md,
            vertical: FxSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: FxRadius.tileBorder,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    final palette = FxPalette.of(context);
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(FxSpacing.xs),
        child: Icon(icon, size: 26, color: palette.textPrimary),
      ),
    );
  }
}
