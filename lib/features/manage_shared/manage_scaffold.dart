import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/feedback/fx_feedback.dart';
import 'package:fortuneboot/core/session/session_cubit.dart';
import 'package:fortuneboot/core/session/session_permission.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

/// 管理类模块的生命周期筛选：全部 / 启用 / 停用。
///
/// 回收站是独立入口，不参与生命周期分段；[recycleBin] 仅用于服务端查询维度。
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
/// 顶部 [←] 标题 [🔍搜索][+新增] + 全部/启用/停用分段 + 回收站独立入口 + body 槽。
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
  final String? backTooltip;
  final String? searchTooltip;
  final String? closeSearchTooltip;
  final String? addTooltip;

  const ManageScaffold({
    super.key,
    required this.title,
    required this.onAdd,
    required this.onSearch,
    required this.tab,
    required this.onTabChanged,
    required this.body,
    this.searchHint,
    this.backTooltip,
    this.searchTooltip,
    this.closeSearchTooltip,
    this.addTooltip,
  });

  @override
  State<ManageScaffold> createState() => _ManageScaffoldState();
}

class _ManageScaffoldState extends State<ManageScaffold> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _searching = false;
  ManageTab _lastLifecycleTab = ManageTab.all;

  @override
  void initState() {
    super.initState();
    if (widget.tab != ManageTab.recycleBin) _lastLifecycleTab = widget.tab;
  }

  @override
  void didUpdateWidget(ManageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tab != ManageTab.recycleBin) _lastLifecycleTab = widget.tab;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onAddPressed() {
    final group = context.read<SessionCubit>().state.currentGroup;
    if (!SessionPermission.canWrite(group)) {
      FxFeedback.info(
        context,
        message: S.of(context).permissionVisitorNoAccess,
      );
      return;
    }
    widget.onAdd();
  }

  void _toggleSearch() {
    setState(() => _searching = !_searching);
    if (!_searching && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
      widget.onSearch('');
    }
  }

  void _openRecycleBin() {
    if (widget.tab == ManageTab.recycleBin) return;
    _lastLifecycleTab = widget.tab;
    widget.onTabChanged(ManageTab.recycleBin);
  }

  void _closeRecycleBin() {
    widget.onTabChanged(_lastLifecycleTab);
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
              child: widget.tab == ManageTab.recycleBin
                  ? _buildRecycleBinBar()
                  : _buildLifecycleFilter(),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleFilter() {
    final palette = FxPalette.of(context);
    return Row(
      children: [
        Expanded(
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
            ],
          ),
        ),
        const SizedBox(width: FxSpacing.sm),
        FxIconButton(
          icon: Icons.delete_outline_rounded,
          tooltip: S.of(context).manageSharedTabRecycleBin,
          color: palette.textSecondary,
          onPressed: _openRecycleBin,
        ),
      ],
    );
  }

  /// 回收站是工具入口，不占用生命周期分段；进入后以单行返回条替代分段。
  Widget _buildRecycleBinBar() {
    final palette = FxPalette.of(context);
    final backLabel = MaterialLocalizations.of(context).backButtonTooltip;
    return Material(
      color: palette.surfaceMuted,
      borderRadius: FxRadius.tileBorder,
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: _closeRecycleBin,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg,
              FxSpacing.sm,
              FxSpacing.sm,
              FxSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: FxSpacing.sm),
                Expanded(
                  child: Text(
                    S.of(context).manageSharedTabRecycleBin,
                    style: FxTypography.label.copyWith(
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                Text(
                  backLabel,
                  style: FxTypography.label.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(width: FxSpacing.xs),
                Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final localizations = MaterialLocalizations.of(context);
    final searchHint =
        widget.searchHint ?? S.of(context).manageSharedSearchHint;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.sm,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: Row(
        children: [
          FxIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: widget.backTooltip ?? localizations.backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: Text(widget.title, style: FxTypography.title)),
          FxIconButton(
            icon: _searching ? Icons.search_off_rounded : Icons.search_rounded,
            tooltip: _searching
                ? widget.closeSearchTooltip ?? localizations.closeButtonTooltip
                : widget.searchTooltip ?? searchHint,
            onPressed: _toggleSearch,
          ),
          if (widget.tab != ManageTab.recycleBin) ...[
            const SizedBox(width: FxSpacing.xs),
            FxIconButton(
              icon: Icons.add_rounded,
              tooltip: widget.addTooltip ?? widget.title,
              onPressed: _onAddPressed,
            ),
          ],
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
}
