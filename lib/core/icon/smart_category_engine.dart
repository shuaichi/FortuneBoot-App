import 'package:flutter/material.dart';
import 'package:fortuneboot/core/icon/category_domain.dart';
import 'package:fortuneboot/core/icon/category_rules.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';

/// 引擎输入：从账单提炼的轻量结构，不依赖任何 model 类型。
class BillIconInput {
  /// 1支出 2收入 3转账 4调整 7垫付 8报销。
  final int? billType;
  final String? title;
  final String? payeeName;
  final String? remark;
  final String? accountName;

  /// categoryAmountPair 的 categoryName 列表；调用方应按金额降序排列（首个即主分类）。
  final List<String> categoryNames;
  final List<String> tagNames;

  /// 转账方向判断：非空表示有转入账户。
  final int? toAccountId;

  const BillIconInput({
    this.billType,
    this.title,
    this.payeeName,
    this.remark,
    this.accountName,
    this.categoryNames = const [],
    this.tagNames = const [],
    this.toAccountId,
  });
}

// ============ 字典树（多 domain 挂载 + 最长匹配扫描）============

class _TrieNode {
  final Map<String, _TrieNode> children = {};
  final List<CategoryDomain> domains = [];
  String? keyword;
}

class _TrieMatch {
  final String keyword;
  final List<CategoryDomain> domains;
  const _TrieMatch(this.keyword, this.domains);
}

class _KeywordTrie {
  final _TrieNode root = _TrieNode();

  void insert(String keyword, CategoryDomain domain) {
    if (keyword.isEmpty) return;
    final lower = keyword.toLowerCase();
    var current = root;
    for (var i = 0; i < lower.length; i++) {
      current = current.children.putIfAbsent(lower[i], _TrieNode.new);
    }
    if (!current.domains.contains(domain)) current.domains.add(domain);
    current.keyword = lower;
  }

  List<_TrieMatch> scan(String text) {
    final results = <_TrieMatch>[];
    if (text.isEmpty) return results;
    final lower = text.toLowerCase();
    for (var i = 0; i < lower.length; i++) {
      var current = root;
      var j = i;
      List<CategoryDomain>? lastDomains;
      String? lastKeyword;
      while (j < lower.length && current.children.containsKey(lower[j])) {
        current = current.children[lower[j]]!;
        if (current.domains.isNotEmpty) {
          lastDomains = current.domains;
          lastKeyword = current.keyword;
        }
        j++;
      }
      if (lastDomains != null && lastKeyword != null) {
        results.add(_TrieMatch(lastKeyword, lastDomains));
        i += lastKeyword.length - 1;
      }
    }
    return results;
  }
}

/// 智能图标匹配引擎（单例）。三级打分 + billType 预过滤 + 用户分类加权。
class SmartCategoryEngine {
  factory SmartCategoryEngine() => _instance;

  SmartCategoryEngine._internal() {
    _init();
  }

  static final SmartCategoryEngine _instance = SmartCategoryEngine._internal();

  final Map<String, List<CategoryDomain>> _merchantIndex = {};
  final Map<String, List<CategoryDomain>> _keywordIndex = {};
  final _KeywordTrie _trie = _KeywordTrie();
  bool _ready = false;

  void _init() {
    if (_ready) return;
    for (final rule in kCategoryRules) {
      for (final m in rule.merchants) {
        _merchantIndex.putIfAbsent(m.toLowerCase(), () => []).add(rule.domain);
        _trie.insert(m, rule.domain);
      }
      for (final kw in rule.keywords) {
        _keywordIndex.putIfAbsent(kw.toLowerCase(), () => []).add(rule.domain);
        _trie.insert(kw, rule.domain);
      }
    }
    _ready = true;
  }

  bool _isIncomeDomain(String id) => id.startsWith('income_');
  bool _isTransferDomain(String id) =>
      id.startsWith('transfer_') || id.startsWith('adjust_');

  /// billType 预过滤：支出/垫付账单屏蔽收入域，收入/报销账单屏蔽支出/转账域。
  bool _allowed(int? billType, String domainId) {
    switch (billType) {
      case 2: // 收入
      case 8: // 报销（分类关联收入）
        return _isIncomeDomain(domainId) || domainId == 'misc_others';
      case 1: // 支出
      case 7: // 垫付（分类关联支出）
        return !_isIncomeDomain(domainId) && !_isTransferDomain(domainId);
      case 3: // 转账
      case 4: // 调整
        return true;
      default:
        return true;
    }
  }

  CategoryMatch match(BillIconInput input) => _score(input).match;

  ({CategoryMatch match, List<CategoryScore> top3}) matchWithDebug(
    BillIconInput input,
  ) {
    final r = _score(input);
    return (match: r.match, top3: r.top3);
  }

  ({CategoryMatch match, List<CategoryScore> top3}) _score(
    BillIconInput input,
  ) {
    final board = <CategoryDomain, int>{};
    final billType = input.billType;

    void add(List<CategoryDomain> domains, int score) {
      for (final d in domains) {
        if (!_allowed(billType, d.id)) continue;
        board[d] = (board[d] ?? 0) + score;
      }
    }

    final payee = (input.payeeName ?? '').toLowerCase();
    final title = (input.title ?? '').toLowerCase();
    final remark = (input.remark ?? '').toLowerCase();
    final account = (input.accountName ?? '').toLowerCase();

    // 阶段 1：商户精确匹配（500/400/350）
    if (payee.isNotEmpty && _merchantIndex.containsKey(payee)) {
      add(_merchantIndex[payee]!, 500);
    }
    var merchantMatched = false;
    for (final m in _merchantIndex.keys) {
      if (payee.isNotEmpty && payee.contains(m)) {
        add(_merchantIndex[m]!, 400);
        merchantMatched = true;
      }
    }
    if (!merchantMatched && title.isNotEmpty) {
      for (final m in _merchantIndex.keys) {
        if (title.contains(m)) add(_merchantIndex[m]!, 350);
      }
    }
    if (!merchantMatched && remark.isNotEmpty) {
      for (final m in _merchantIndex.keys) {
        if (remark.contains(m)) add(_merchantIndex[m]!, 350);
      }
    }

    // 阶段 2：结构化分类/标签匹配。
    // 用户已选分类加权 350（首个 = 金额最大的主分类，最可信）。
    for (var i = 0; i < input.categoryNames.length; i++) {
      final name = input.categoryNames[i].toLowerCase();
      if (name.isEmpty) continue;
      final weight = i == 0 ? 350 : 300;
      if (_merchantIndex.containsKey(name)) {
        add(_merchantIndex[name]!, weight);
      } else if (_keywordIndex.containsKey(name)) {
        add(_keywordIndex[name]!, weight);
      }
    }
    for (final tag in input.tagNames) {
      final name = tag.toLowerCase();
      if (name.isEmpty) continue;
      if (_merchantIndex.containsKey(name)) {
        add(_merchantIndex[name]!, 150);
      } else if (_keywordIndex.containsKey(name)) {
        add(_keywordIndex[name]!, 100);
      }
    }

    // 阶段 3：Trie 全文兜底扫描。title 权重 > payee > accountName(弱特征 10)。
    final scanTexts = <String, int>{};
    if (title.isNotEmpty) scanTexts[title] = 30;
    if (payee.isNotEmpty) scanTexts[payee] = 15;
    if (account.isNotEmpty) scanTexts[account] = 10;
    for (final entry in scanTexts.entries) {
      for (final m in _trie.scan(entry.key)) {
        if (m.keyword.length <= 1) continue; // 防投毒
        add(m.domains, entry.value + m.keyword.length * 5);
      }
    }

    final top3 = board.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debug = top3
        .take(3)
        .map((e) => CategoryScore(domainId: e.key.id, score: e.value))
        .toList();

    if (board.isEmpty) {
      return (match: _fallback(input), top3: debug);
    }
    final best = top3.first.key;
    return (
      match: CategoryMatch(icon: best.icon, color: best.color),
      top3: debug,
    );
  }

  /// 兜底：按 billType 给语义色（切 FxColors）+ 细化图标。
  CategoryMatch _fallback(BillIconInput input) {
    switch (input.billType) {
      case 2: // 收入
        return const CategoryMatch(
          icon: Icons.savings_rounded,
          color: FxColors.income,
        );
      case 3: // 转账
        final icon = input.toAccountId != null
            ? Icons.sync_alt_rounded
            : Icons.call_made_rounded;
        return CategoryMatch(icon: icon, color: FxColors.transfer);
      case 4: // 调整
        return const CategoryMatch(
          icon: Icons.tune_rounded,
          color: FxColors.adjust,
        );
      case 7: // 垫付
        return const CategoryMatch(
          icon: Icons.payment_rounded,
          color: FxColors.expense,
        );
      case 8: // 报销
        return const CategoryMatch(
          icon: Icons.assignment_return_rounded,
          color: FxColors.income,
        );
      case 1: // 支出
      default:
        return const CategoryMatch(
          icon: Icons.receipt_rounded,
          color: FxColors.expense,
        );
    }
  }
}
