import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/logs/data/logs_models.dart';
import 'package:fortuneboot/features/logs/data/logs_service.dart';
import 'package:fortuneboot/fx/components/fx_icon_button.dart';
import 'package:fortuneboot/fx/components/fx_list_item.dart';
import 'package:fortuneboot/fx/components/fx_segmented.dart';
import 'package:fortuneboot/fx/components/fx_sheet.dart';
import 'package:fortuneboot/fx/components/fx_state_view.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';

enum _LogsTab { operation, login }

/// 系统日志只读页：操作日志 / 登录日志。无写权限接口，缺权限时展示接口返回文案。
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogsService _service = LogsService();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _searchDebounce;

  _LogsTab _tab = _LogsTab.operation;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _total = 0;
  String _username = '';
  int _requestId = 0;
  List<OperationLog> _operations = const [];
  List<LoginLog> _logins = const [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  int get _count =>
      _tab == _LogsTab.operation ? _operations.length : _logins.length;

  bool get _hasMore => _count < _total;

  void _onScroll() {
    if (!_scroll.hasClients || _loading || _loadingMore || !_hasMore) return;
    if (_scroll.position.extentAfter < 240) {
      _load(reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final next = value.trim();
      if (next == _username) return;
      _username = next;
      _load(reset: true);
    });
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loading || _loadingMore || !_hasMore)) return;
    final page = reset ? 1 : _page + 1;
    final tab = _tab;
    final username = _username;
    final requestId = ++_requestId;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      if (tab == _LogsTab.operation) {
        final result = await _service.operationLogs(
          pageNum: page,
          username: username,
        );
        if (!mounted || requestId != _requestId) return;
        setState(() {
          _operations = reset ? result.rows : [..._operations, ...result.rows];
          _total = result.total;
          _page = page;
          _loading = false;
          _loadingMore = false;
        });
      } else {
        final result = await _service.loginLogs(
          pageNum: page,
          username: username,
        );
        if (!mounted || requestId != _requestId) return;
        setState(() {
          _logins = reset ? result.rows : [..._logins, ...result.rows];
          _total = result.total;
          _page = page;
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (reset) _error = _messageOf(e);
      });
    }
  }

  String _messageOf(Object error) {
    if (error is FxApiException) return error.message;
    return error.toString();
  }

  void _switchTab(_LogsTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    final s = S.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(s.profileLogs),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                FxSpacing.xs,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: FxSegmented<_LogsTab>(
                value: _tab,
                onChanged: _switchTab,
                segments: [
                  FxSegment(_LogsTab.operation, s.logsOperation),
                  FxSegment(_LogsTab.login, s.logsLogin),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FxSpacing.lg,
                0,
                FxSpacing.lg,
                FxSpacing.sm,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: s.logsSearchHint,
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
            ),
            Expanded(child: _body(s)),
          ],
        ),
      ),
    );
  }

  Widget _header(String title) {
    final localizations = MaterialLocalizations.of(context);
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
            tooltip: localizations.backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: Text(title, style: FxTypography.title)),
        ],
      ),
    );
  }

  Widget _body(S s) {
    if (_loading && _count == 0) {
      return FxStateView.loading();
    }
    if (_error != null && _count == 0) {
      return FxStateView.error(
        message: _error,
        retryLabel: s.commonRetry,
        onRetry: () => _load(reset: true),
      );
    }
    if (_count == 0) {
      return FxStateView.empty(
        message: s.logsEmpty,
        icon: Icons.history_rounded,
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _count + (_loadingMore ? 1 : 0),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: FxSpacing.lg),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: FxPalette.of(context).border,
          ),
        ),
        itemBuilder: (context, index) {
          if (index >= _count) {
            return const Padding(
              padding: EdgeInsets.all(FxSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          if (_tab == _LogsTab.operation) {
            final item = _operations[index];
            return FxListItem(
              title: item.title,
              subtitle: _subtitle(
                item.username,
                item.timeLabel,
                item.statusStr,
              ),
              trailing: _statusDot(item.status),
              showChevron: true,
              onTap: () => _showDetail(
                title: item.title,
                rows: [
                  (s.logsModule, item.requestModule),
                  (s.logsBusinessType, item.businessTypeStr),
                  (s.logsMethod, item.requestMethod),
                  (s.logsUrl, item.requestUrl),
                  (s.logsUsername, item.username),
                  (s.logsIp, item.operatorIp),
                  (s.logsLocation, item.operatorLocation),
                  (s.logsStatus, item.statusStr),
                  (s.logsTime, item.timeLabel),
                  (s.logsParam, item.operationParam),
                  (s.logsResult, item.operationResult),
                  (s.logsError, item.errorStack),
                ],
              ),
            );
          }
          final item = _logins[index];
          return FxListItem(
            title: item.title,
            subtitle: _subtitle(item.msg, item.timeLabel, item.statusStr),
            trailing: _statusDot(item.status),
            showChevron: true,
            onTap: () => _showDetail(
              title: item.title,
              rows: [
                (s.logsUsername, item.username),
                (s.logsStatus, item.statusStr),
                (s.logsMessage, item.msg),
                (s.logsIp, item.ipAddress),
                (s.logsLocation, item.loginLocation),
                (s.logsSystem, item.operationSystem),
                (s.logsBrowser, item.browser),
                (s.logsTime, item.timeLabel),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _subtitle(String? left, String? time, String? status) {
    final parts = <String>[
      if (left != null && left.trim().isNotEmpty) left.trim(),
      if (time != null && time.trim().isNotEmpty) time.trim(),
      if (status != null && status.trim().isNotEmpty) status.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  Widget _statusDot(int? status) {
    final palette = FxPalette.of(context);
    final color = switch (status) {
      1 => palette.success,
      0 => palette.danger,
      _ => palette.info,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showDetail({
    required String title,
    required List<(String, String?)> rows,
  }) {
    final visible = rows
        .where((row) => row.$2 != null && row.$2!.trim().isNotEmpty)
        .toList();
    final palette = FxPalette.of(context);
    FxSheet.show<void>(
      context,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FxSpacing.xxl,
          FxSpacing.sm,
          FxSpacing.xxl,
          FxSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FxTypography.title.copyWith(color: palette.textPrimary),
            ),
            const SizedBox(height: FxSpacing.xl),
            for (final row in visible) ...[
              Text(
                row.$1,
                style: FxTypography.caption.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: FxSpacing.xs),
              SelectableText(row.$2!.trim(), style: FxTypography.body),
              const SizedBox(height: FxSpacing.lg),
            ],
          ],
        ),
      ),
    );
  }
}
