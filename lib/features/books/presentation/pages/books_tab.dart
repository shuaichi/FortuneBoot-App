import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/core/session/session_models.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/widgets/book_card.dart';
import 'package:fortuneboot/features/books/presentation/widgets/manage_inline_banner.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';

class BooksTabView extends StatelessWidget {
  const BooksTabView({
    super.key,
    required this.currentBookId,
    required this.onOpenDetail,
    required this.onOpenMenu,
    required this.onMissingAccountTap,
  });

  final int? currentBookId;
  final ValueChanged<FortuneBookVo> onOpenDetail;
  final ValueChanged<FortuneBookVo> onOpenMenu;
  final ValueChanged<FortuneBookVo> onMissingAccountTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BooksBloc, BooksState>(
      builder: (context, state) {
        if (state.status == BooksStatus.loading && state.groups.isEmpty) {
          return FxStateView.loading();
        }
        if (state.status == BooksStatus.error && state.groups.isEmpty) {
          return FxStateView.error(
            message: state.errorMessage,
            onRetry: () => context.read<BooksBloc>().add(const BooksLoaded()),
          );
        }
        final selectedGroup = state.selectedManagedGroup;
        return Column(
          children: [
            _GroupSelector(state: state),
            if (selectedGroup != null && !selectedGroup.enable)
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  FxSpacing.lg,
                  FxSpacing.sm,
                  FxSpacing.lg,
                  0,
                ),
                child: ManageInlineBanner(message: '该分组已停用，仅可查看历史账本；启用分组后可编辑。'),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.md,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: FxSegmented<BooksSegment>(
                value: state.bookSegment,
                onChanged: (value) =>
                    context.read<BooksBloc>().add(BooksSegmentChanged(value)),
                segments: const [
                  FxSegment(BooksSegment.active, '在用'),
                  FxSegment(BooksSegment.recycleBin, '回收站'),
                ],
              ),
            ),
            _SearchField(
              hintText: '搜索账本名称 / 备注',
              onChanged: (value) =>
                  context.read<BooksBloc>().add(BooksSearchChanged(value)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<BooksBloc>().add(const BooksMutated());
                },
                child: state.visibleBooks.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          FxStateView.empty(
                            message:
                                state.bookSegment == BooksSegment.recycleBin
                                ? '回收站为空'
                                : '该分组暂无账本',
                            icon: Icons.menu_book_outlined,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          FxSpacing.lg,
                          FxSpacing.md,
                          FxSpacing.lg,
                          120,
                        ),
                        itemBuilder: (context, index) {
                          final book = state.visibleBooks[index];
                          return BookCard(
                            book: book,
                            isDefault:
                                book.bookId == selectedGroup?.defaultBookId,
                            isCurrent: book.bookId == currentBookId,
                            inRecycleBin:
                                state.bookSegment == BooksSegment.recycleBin,
                            onTap: () => onOpenDetail(book),
                            onMenu: () => onOpenMenu(book),
                            onMissingAccountTap: () =>
                                onMissingAccountTap(book),
                          );
                        },
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FxSpacing.md),
                        itemCount: state.visibleBooks.length,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GroupSelector extends StatelessWidget {
  const _GroupSelector({required this.state});

  final BooksState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final selected = state.selectedManagedGroup;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.md,
        FxSpacing.lg,
        0,
      ),
      child: InkWell(
        borderRadius: FxRadius.tileBorder,
        onTap: () => _showGroupPicker(context),
        child: Container(
          padding: const EdgeInsets.all(FxSpacing.md),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: FxRadius.tileBorder,
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: palette.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder_rounded, color: palette.primary),
              ),
              const SizedBox(width: FxSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected?.name ?? '请选择分组',
                      style: FxTypography.bodyStrong,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected?.enable == false ? '已停用 · 仅可查看' : '点击切换管理分组',
                      style: FxTypography.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.expand_more_rounded, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showGroupPicker(BuildContext context) async {
    final selectedId = await FxSheet.show<int>(
      context,
      title: '切换分组',
      child: _GroupPicker(state: state),
      expand: true,
    );
    if (selectedId == null || !context.mounted) return;
    context.read<BooksBloc>().add(BooksGroupSelected(selectedId));
  }
}

class _GroupPicker extends StatelessWidget {
  const _GroupPicker({required this.state});

  final BooksState state;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      itemBuilder: (context, index) {
        final group = state.groups[index];
        final selected = group.groupId == state.selectedGroupId;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? palette.primary : palette.textTertiary,
          ),
          title: Text(group.name, style: FxTypography.bodyStrong),
          subtitle: Text(group.defaultCurrency ?? 'CNY'),
          trailing: Wrap(
            spacing: FxSpacing.xs,
            children: [
              if (!group.enable)
                FxTagChip(label: '已停用', dotColor: palette.warning),
              if (group.groupId == state.defaultGroupId)
                const FxTagChip(label: '默认', selected: true),
            ],
          ),
          onTap: () => Navigator.of(context).pop(group.groupId),
        );
      },
      separatorBuilder: (_, _) => Divider(color: palette.border),
      itemCount: state.groups.length,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText, required this.onChanged});

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        FxSpacing.sm,
        FxSpacing.lg,
        FxSpacing.sm,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: palette.surfaceMuted,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: FxRadius.tileBorder,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
