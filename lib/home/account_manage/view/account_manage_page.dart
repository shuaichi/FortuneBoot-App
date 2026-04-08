import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fortuneboot/Home/account_manage/models/fortune_account.dart';
import 'package:fortuneboot/repository/repository/bills_repository.dart';
import 'package:fortuneboot/Request/account_request.dart';
import 'package:fortuneboot/Home/category_manage/view/widgets/category_summary_bar.dart';
import 'package:fortuneboot/Home/tag_manage/view/widgets/tag_pager.dart';

import 'package:fortuneboot/request/group_request.dart';

// 导入新的Page版本
import 'package:fortuneboot/Home/account_manage/view/account_add_page.dart';
import 'package:fortuneboot/Home/account_manage/view/account_edit_page.dart';
import 'package:fortuneboot/Home/account_manage/view/account_balance_adjust_page.dart';

// 导入增强版组件
import 'package:fortuneboot/Home/account_manage/constants/design_system.dart' as ds;
import 'package:fortuneboot/Home/account_manage/view/widgets/account_card.dart';
import 'package:fortuneboot/Home/account_manage/view/widgets/empty_state.dart';
import 'package:fortuneboot/Home/account_manage/view/widgets/loading_state.dart';
import 'package:fortuneboot/Home/account_manage/view/widgets/type_selector.dart';
import 'package:fortuneboot/Home/account_manage/view/widgets/account_move_to_recycle_dialog.dart';

class AccountManagePage extends StatefulWidget {
  const AccountManagePage({Key? key}) : super(key: key);

  @override
  State<AccountManagePage> createState() => _AccountManagePageState();
}

class _AccountManagePageState extends State<AccountManagePage> {
  final AccountQueryService _service = AccountQueryService();

  bool _loading = true;
  String? _error;
  List<FortuneAccount> _rows = const <FortuneAccount>[];

  // 顶部类型切换：1活期、2信用、3资产、4贷款；默认资产(3)
  int _accountType = 1;

  // 分页状态
  int _pageNum = 1;
  int _pageSize = 20;
  int _total = 0;

  // 导航去抖，避免快速连点导致 navigator 锁冲突
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
      final int? groupId = context.read<BillsRepository>().groupId();
      if (groupId == null) {
        throw Exception('获取账本ID失败，请重新登录');
      }

      final pageData = await _service.getPage(
        groupId: groupId,
        accountType: _accountType,
        pageNum: _pageNum,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _rows = pageData.rows;
          _total = pageData.total;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _onTypeChanged(int newType) {
    setState(() {
      _accountType = newType;
      _pageNum = 1; // 切换类型回到第一页
    });
    _load();
  }

  void _prevPage() {
    setState(() {
      _pageNum -= 1;
    });
    _load();
  }

  void _nextPage() {
    setState(() {
      _pageNum += 1;
    });
    _load();
  }

  Future<void> _onMoveToRecyclePressed(FortuneAccount item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AccountMoveToRecycleDialog(
          accountName: item.accountName ?? '未命名账户',
          onConfirm: () async {
            final int? groupId = context.read<BillsRepository>().groupId();
            final int? accountId = item.accountId;
            if (groupId == null || accountId == null) {
              throw Exception('缺少必要参数：groupId或accountId为空');
            }
            await _service.moveToRecycleBin(
              groupId: groupId,
              accountId: accountId,
            );
          },
        );
      },
    );
    if (ok == true) {
      setState(() {
        _total = (_total > 0) ? _total - 1 : 0;
      });

      final int startIndex = (_pageNum - 1) * _pageSize;
      if (_rows.isEmpty && _pageNum > 1 && startIndex >= _total) {
        setState(() {
          _pageNum -= 1;
        });
      }

      // 刷新当前页（同步顶部摘要/统计）
      _load();
    }
  }

  // 新增账户入口 - 改为Page导航
  Future<void> _onAddAccountPressed() async {
    if (_isNavigating) return;
    _isNavigating = true;
    await Future.delayed(Duration.zero);

    final int groupId = context.read<BillsRepository>().groupId() ?? 1;

    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AccountAddPage(
          groupId: groupId,
          accountType: _accountType,
        ),
      ),
    );

    _isNavigating = false;

    if (ok == true) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('新增成功'),
          backgroundColor: theme.colorScheme.secondary,
        ),
      );
      await _load(); // 刷新当前页与顶部摘要
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '账户管理',
          style: ds.TextStyles.pageTitle,
        ),
        actions: [
          IconButton(
            tooltip: '新增账户',
            icon: const Icon(Icons.add),
            onPressed: _onAddAccountPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部类型切换 - 使用增强版组件
          Container(
            padding: context.responsiveHorizontalPadding,
            child: EnhancedTypeSelector(
              selectedType: _accountType,
              onTypeChanged: _onTypeChanged,
              enabled: !_loading,
            ),
          ),
          SizedBox(height: ds.Spacing.sm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _buildEnhancedBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedBody(BuildContext context) {
    // 使用增强版组件的三态切换
    if (_loading) {
      return const EnhancedLoadingState(
        message: '正在加载账户数据...',
      );
    }
    
    if (_error != null) {
      return _buildErrorState(context);
    }

    if (_rows.isEmpty) {
      return EnhancedEmptyState(
        accountType: _accountType,
        onAddAccount: _onAddAccountPressed,
      );
    }

    return _buildAccountList(context);
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: context.responsiveHorizontalPadding,
      children: [
        SizedBox(height: ds.Spacing.xxxl),
        Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
          size: 48,
        ),
        SizedBox(height: ds.Spacing.md),
        Center(
          child: Text(
            _error ?? '加载失败',
            style: ds.TextStyles.emptyStateDescription.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: ds.Spacing.lg),
        Center(
          child: ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: ds.Spacing.lg,
                vertical: ds.Spacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountList(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 响应式网格布局
        final crossAxisCount = context.gridColumns;
        
        if (crossAxisCount == 1) {
          // 移动端：列表布局
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.responsiveHorizontalPadding,
            itemCount: _rows.length + 3,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: ds.Spacing.md,
                    bottom: ds.Spacing.sm,
                  ),
                  child: CategorySummaryBar(
                    typeText: _typeLabel(_accountType),
                    total: _total,
                    currentPage: _pageNum,
                  ),
                );
              }
              if (index == _rows.length + 1) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ds.Spacing.md),
                  child: TagPager(
                    total: _total,
                    hasPrev: _pageNum > 1,
                    hasNext: _pageNum * _pageSize < _total,
                    onPrev: _prevPage,
                    onNext: _nextPage,
                  ),
                );
              }
              if (index == _rows.length + 2) {
                return SizedBox(height: ds.Spacing.md);
              }
              
              final item = _rows[index - 1];
              return AccountCard(
                account: item,
                onTap: () {
                  // 可以添加账户详情页导航
                },
                onEdit: () => _onEditAccountPressed(item),
                onBalanceAdjust: () => _onBalanceAdjustPressed(item),
                onMoveToRecycle: () => _onMoveToRecyclePressed(item),
              );
            },
          );
        } else {
          // 平板/桌面端：网格布局
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: context.responsiveHorizontalPadding,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: ds.Spacing.md),
                      CategorySummaryBar(
                        typeText: _typeLabel(_accountType),
                        total: _total,
                        currentPage: _pageNum,
                      ),
                      SizedBox(height: ds.Spacing.lg),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: context.responsiveHorizontalPadding,
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: ds.Spacing.md,
                    mainAxisSpacing: ds.Spacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _rows[index];
                      return AccountCard(
                        account: item,
                        onTap: () {
                          // 可以添加账户详情页导航
                        },
                        onEdit: () => _onEditAccountPressed(item),
                        onBalanceAdjust: () => _onBalanceAdjustPressed(item),
                        onMoveToRecycle: () => _onMoveToRecyclePressed(item),
                      );
                    },
                    childCount: _rows.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: context.responsiveHorizontalPadding,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: ds.Spacing.lg),
                      TagPager(
                        total: _total,
                        hasPrev: _pageNum > 1,
                        hasNext: _pageNum * _pageSize < _total,
                        onPrev: _prevPage,
                        onNext: _nextPage,
                      ),
                      SizedBox(height: ds.Spacing.md),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  String _typeLabel(int type) {
    switch (type) {
      case 1:
        return '活期账户';
      case 2:
        return '信用账户';
      case 3:
        return '资产账户';
      case 4:
        return '贷款账户';
      default:
        return '账户';
    }
  }

  // 修改账户 - 改为Page导航
  Future<void> _onEditAccountPressed(FortuneAccount item) async {
    String groupName = '默认账本';
    try {
      final int? groupId = context.read<BillsRepository>().groupId();
      if (groupId != null) {
        final resp = await GroupService().getByGroupId(groupId);
        if (resp.code == 0) {
          final data = resp.data as Map? ?? {};
          final name = (data['groupName'] ?? '').toString();
          if (name.isNotEmpty) groupName = name;
        }
      }
    } catch (_) {
      // 忽略错误，使用默认值
    }

    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AccountEditPage(
          account: item,
          groupName: groupName,
        ),
      ),
    );
    if (ok == true) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('修改成功'),
          backgroundColor: theme.colorScheme.secondary,
        ),
      );
      await _load();
    }
  }

  // 余额调整 - 改为Page导航
  Future<void> _onBalanceAdjustPressed(FortuneAccount item) async {
    final bool? ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AccountBalanceAdjustPage(
          account: item,
        ),
      ),
    );
    if (ok == true) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('调整成功'),
          backgroundColor: theme.colorScheme.secondary,
        ),
      );
      await _load();
    }
  }
}
