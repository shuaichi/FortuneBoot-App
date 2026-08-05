import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/features/books/data/books_manage_models.dart';
import 'package:fortuneboot/features/books/presentation/bloc/books_bloc.dart';
import 'package:fortuneboot/features/books/presentation/widgets/group_card.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/components/fx_tag_chip.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/generated/l10n.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({
    super.key,
    required this.currentGroupId,
    required this.onOpenDetail,
    required this.onOpenMenu,
  });

  final int? currentGroupId;
  final ValueChanged<ManagedGroup> onOpenDetail;
  final ValueChanged<ManagedGroup> onOpenMenu;

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
        return Column(
          children: [
            _SearchField(
              hintText: S.of(context).booksGroupSearchHint,
              onChanged: (value) =>
                  context.read<BooksBloc>().add(BooksGroupSearchChanged(value)),
            ),
            _FilterChips(state: state),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<BooksBloc>().add(const BooksMutated());
                },
                child: state.visibleGroups.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: FxStateView.empty(
                              message: S.of(context).booksNoMatchingGroups,
                              icon: Icons.folder_off_rounded,
                            ),
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
                          final group = state.visibleGroups[index];
                          final capabilities = state.capabilitiesFor(
                            group.groupId,
                          );
                          return GroupCard(
                            group: group,
                            capabilities: capabilities,
                            isDefault: group.groupId == state.defaultGroupId,
                            isCurrent: group.groupId == currentGroupId,
                            onTap: () => onOpenDetail(group),
                            onMenu: () => onOpenMenu(group),
                          );
                        },
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FxSpacing.md),
                        itemCount: state.visibleGroups.length,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.state});

  final BooksState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FxSpacing.lg),
      child: Wrap(
        spacing: FxSpacing.sm,
        children: [
          FxTagChip(
            label: S.of(context).booksFilterAll,
            selected: state.groupFilter == GroupFilter.all,
            onTap: () => context.read<BooksBloc>().add(
              const BooksGroupFilterChanged(GroupFilter.all),
            ),
          ),
          FxTagChip(
            label: S.of(context).booksFilterEnabled,
            selected: state.groupFilter == GroupFilter.enabled,
            onTap: () => context.read<BooksBloc>().add(
              const BooksGroupFilterChanged(GroupFilter.enabled),
            ),
          ),
          FxTagChip(
            label: S.of(context).booksFilterDisabled,
            selected: state.groupFilter == GroupFilter.disabled,
            onTap: () => context.read<BooksBloc>().add(
              const BooksGroupFilterChanged(GroupFilter.disabled),
            ),
          ),
          if (state.hasMoreGroups)
            FxTagChip(
              label: S.of(context).booksHasMore,
              dotColor: Colors.orange,
            ),
        ],
      ),
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
        FxSpacing.md,
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
