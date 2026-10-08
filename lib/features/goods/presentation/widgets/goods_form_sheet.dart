import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/data/goods_service.dart';
import 'package:fortuneboot/fx/components/fx_card.dart';
import 'package:fortuneboot/fx/components/fx_chip.dart';
import 'package:fortuneboot/fx/components/fx_date_picker.dart';
import 'package:fortuneboot/fx/theme/fx_theme.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
import 'package:fortuneboot/generated/l10n.dart';
import 'package:intl/intl.dart';

/// 归物新增/编辑表单（FxSheet 内滚动）。multipart（data + files）提交。
class GoodsFormSheet extends StatefulWidget {
  final GoodsService service;
  final int bookId;
  final FortuneGoodsKeeperVo? goods; // null=新增

  const GoodsFormSheet({
    super.key,
    required this.service,
    required this.bookId,
    this.goods,
  });

  bool get isEdit => goods != null;

  @override
  State<GoodsFormSheet> createState() => GoodsFormSheetState();
}

class GoodsFormSheetState extends State<GoodsFormSheet> {
  static final DateFormat _day = DateFormat('yyyy-MM-dd');

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _usageNumCtrl;
  late final TextEditingController _soldPriceCtrl;
  late final TextEditingController _remarkCtrl;

  DateTime? _purchaseDate;
  DateTime? _warrantyDate;
  DateTime? _retiredDate;

  /// 已识别的状态枚举；编辑时后端 status 若不在已知映射内则为 null。
  GoodsStatus? _status;

  /// 后端返回的原始 status int。用户未主动改状态时按原值回传，避免覆盖未知状态。
  int? _originalStatus;
  bool _useByTimes = false;
  int? _categoryId;
  int? _tagId;

  final List<File> _files = [];

  List<GoodsOption> _categories = const [];
  List<GoodsOption> _tags = const [];

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.goods;
    _nameCtrl = TextEditingController(text: g?.goodsName ?? '');
    _priceCtrl = TextEditingController(
      text: g?.price == null ? '' : g!.price!.toStringAsFixed(2),
    );
    _usageNumCtrl = TextEditingController(
      text: g?.usageNum == null ? '' : '${g!.usageNum}',
    );
    _soldPriceCtrl = TextEditingController(
      text: g?.soldPrice == null ? '' : g!.soldPrice!.toStringAsFixed(2),
    );
    _remarkCtrl = TextEditingController(text: g?.remark ?? '');

    _purchaseDate = _parse(g?.purchaseDate) ?? DateTime.now();
    _warrantyDate = _parse(g?.warrantyDate);
    _retiredDate = _parse(g?.retiredDate);
    _originalStatus = g?.status;
    // 新增默认在役；编辑按后端 int 识别，识别不出则 _status 为 null（选择器不高亮）。
    _status = widget.isEdit
        ? GoodsStatus.fromValue(g?.status)
        : GoodsStatus.active;
    _useByTimes = g?.useByTimes ?? false;
    _categoryId = g?.categoryId;
    _tagId = g?.tagId;

    _loadOptions();
  }

  DateTime? _parse(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        widget.service.getCategoryOptions(widget.bookId),
        widget.service.getTagOptions(widget.bookId),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0];
        _tags = results[1];
        // 新增且未选分类时，默认选中第一个，避免漏传 category_id。
        if (!widget.isEdit &&
            _categoryId == null &&
            _categories.isNotEmpty) {
          _categoryId = _categories.first.id;
        }
      });
    } on Object {
      // 选项拉取失败不阻塞表单；提交时仍会校验分类必选。
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _usageNumCtrl.dispose();
    _soldPriceCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  bool get _isSold => _status == GoodsStatus.sold;
  bool get _isRetiredOrSold =>
      _status == GoodsStatus.retired || _status == GoodsStatus.sold;

  /// 提交用 status：用户选中了已知状态则用它，否则回传后端原始 int（编辑未改时），
  /// 避免把无法识别的后端状态覆盖成猜测值。
  int? get _statusForSubmit => _status?.value ?? _originalStatus;

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{
      'bookId': widget.bookId,
      'goodsName': _nameCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'purchaseDate': _day.format(_purchaseDate ?? DateTime.now()),
      'useByTimes': _useByTimes,
    };
    final status = _statusForSubmit;
    if (status != null) body['status'] = status;
    if (widget.isEdit) body['goodsKeeperId'] = widget.goods!.goodsKeeperId;
    // 后端 fortune_goods_keeper.category_id 非空且无默认值，必须提交。
    body['categoryId'] = _categoryId;
    if (_tagId != null) body['tagId'] = _tagId;
    if (_warrantyDate != null) {
      body['warrantyDate'] = _day.format(_warrantyDate!);
    }
    if (_useByTimes) {
      final n = int.tryParse(_usageNumCtrl.text.trim());
      if (n != null) body['usageNum'] = n;
    }
    if (_isRetiredOrSold && _retiredDate != null) {
      body['retiredDate'] = _day.format(_retiredDate!);
    }
    if (_isSold) {
      final sold = double.tryParse(_soldPriceCtrl.text.trim());
      if (sold != null) body['soldPrice'] = sold;
    }
    final remark = _remarkCtrl.text.trim();
    if (remark.isNotEmpty) body['remark'] = remark;
    return body;
  }

  String get submitLabel => widget.isEdit
      ? S.of(context).goodsSaveChanges
      : S.of(context).goodsAddTitle;

  bool get isSubmitting => _submitting;

  Future<void> submit() {
    if (_submitting) return Future<void>.value();
    return _submit();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = S.of(context).goodsErrNameRequired);
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      setState(() => _error = S.of(context).goodsErrInvalidPrice);
      return;
    }
    if (_statusForSubmit == null) {
      setState(() => _error = S.of(context).goodsErrStatusRequired);
      return;
    }
    if (_categoryId == null) {
      setState(() => _error = S.of(context).goodsErrCategoryRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.service.submit(
        _buildBody(),
        modify: widget.isEdit,
        files: _files.isEmpty ? null : _files,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = e is FxApiException ? e.message : e.toString();
        });
      }
    }
  }

  Future<void> _pickDate(
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showFxDatePicker(
      context,
      initial: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 20),
      title: S.of(context).goodsPickDate,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null) return;
    final files = result.paths.whereType<String>().map((p) => File(p)).toList();
    if (files.isNotEmpty) setState(() => _files.addAll(files));
  }

  @override
  Widget build(BuildContext context) {
    final palette = FxPalette.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FxSpacing.lg,
        0,
        FxSpacing.lg,
        FxSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 基础信息
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(S.of(context).goodsSectionBasic),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsLabelName),
                TextField(
                  controller: _nameCtrl,
                  decoration: _dec(S.of(context).goodsHintName),
                ),
                const SizedBox(height: FxSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label(S.of(context).goodsLabelPrice),
                          TextField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _dec('0.00'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: FxSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label(S.of(context).goodsFieldPurchaseDate),
                          _dateField(
                            _purchaseDate,
                            () => _pickDate(
                              _purchaseDate,
                              (d) => setState(() => _purchaseDate = d),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          // 分类与标签
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(S.of(context).goodsSectionCategoryTag),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsLabelCategoryOptional),
                _optionSelector(
                  _categories,
                  _categoryId,
                  (id) => setState(() => _categoryId = id),
                  empty: S.of(context).goodsEmptyCategory,
                  allowNone: false,
                  emptyHint: S.of(context).goodsNoCategoryOptions,
                ),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsLabelTagOptional),
                _optionSelector(
                  _tags,
                  _tagId,
                  (id) => setState(() => _tagId = id),
                  empty: S.of(context).goodsEmptyTag,
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.md),
          // 保修与状态
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(S.of(context).goodsSectionWarrantyStatus),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsLabelWarrantyOptional),
                _dateField(
                  _warrantyDate,
                  () => _pickDate(
                    _warrantyDate,
                    (d) => setState(() => _warrantyDate = d),
                  ),
                  hint: S.of(context).goodsNotSet,
                  onClear: _warrantyDate == null
                      ? null
                      : () => setState(() => _warrantyDate = null),
                ),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsFieldStatus),
                _statusSelector(),
                if (widget.isEdit && _status == null)
                  Padding(
                    padding: const EdgeInsets.only(top: FxSpacing.xs),
                    child: Text(
                      S
                          .of(context)
                          .goodsStatusUnrecognized(
                            widget.goods?.statusDesc ??
                                S.of(context).goodsUnknown,
                          ),
                      style: FxTypography.caption.copyWith(
                        color: palette.textTertiary,
                      ),
                    ),
                  ),
                const SizedBox(height: FxSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).goodsUseByTimes,
                        style: FxTypography.body,
                      ),
                    ),
                    Switch.adaptive(
                      value: _useByTimes,
                      activeColor: palette.primary,
                      onChanged: (v) => setState(() => _useByTimes = v),
                    ),
                  ],
                ),
                if (_useByTimes) ...[
                  const SizedBox(height: FxSpacing.sm),
                  _label(S.of(context).goodsFieldUsageCount),
                  TextField(
                    controller: _usageNumCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _dec(S.of(context).goodsHintUsageNum),
                  ),
                ],
              ],
            ),
          ),
          if (_isRetiredOrSold) ...[
            const SizedBox(height: FxSpacing.md),
            // 处置
            FxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(S.of(context).goodsSectionDisposal),
                  const SizedBox(height: FxSpacing.md),
                  _label(S.of(context).goodsFieldRetiredDate),
                  _dateField(
                    _retiredDate,
                    () => _pickDate(
                      _retiredDate,
                      (d) => setState(() => _retiredDate = d),
                    ),
                    hint: S.of(context).goodsNotSet,
                    onClear: _retiredDate == null
                        ? null
                        : () => setState(() => _retiredDate = null),
                  ),
                  if (_isSold) ...[
                    const SizedBox(height: FxSpacing.md),
                    _label(S.of(context).goodsFieldSoldPrice),
                    TextField(
                      controller: _soldPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _dec('0.00'),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: FxSpacing.md),
          // 备注与附件
          FxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle(S.of(context).goodsSectionRemarkAttach),
                const SizedBox(height: FxSpacing.md),
                _label(S.of(context).goodsLabelRemarkOptional),
                TextField(
                  controller: _remarkCtrl,
                  decoration: _dec(S.of(context).goodsFieldRemark),
                ),
                const SizedBox(height: FxSpacing.md),
                _attachments(),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: palette.danger),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: FxTypography.bodyStrong.copyWith(
      color: FxPalette.of(context).textPrimary,
    ),
  );

  Widget _dateField(
    DateTime? value,
    VoidCallback onTap, {
    String? hint,
    VoidCallback? onClear,
  }) {
    final palette = FxPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FxRadius.tileBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: FxRadius.tileBorder,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: palette.textSecondary,
            ),
            const SizedBox(width: FxSpacing.sm),
            Expanded(
              child: Text(
                value == null
                    ? (hint ?? S.of(context).goodsPickDate)
                    : _day.format(value),
                style: FxTypography.body.copyWith(
                  color: value == null
                      ? palette.textTertiary
                      : palette.textPrimary,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: palette.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _optionSelector(
    List<GoodsOption> options,
    int? selected,
    ValueChanged<int?> onChanged, {
    required String empty,
    bool allowNone = true,
    String? emptyHint,
  }) {
    if (options.isEmpty) {
      return Text(
        emptyHint ?? S.of(context).goodsNoOptions(empty),
        style: FxTypography.caption.copyWith(
          color: FxPalette.of(context).textTertiary,
        ),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: [
        if (allowNone)
          _chip(
            S.of(context).goodsNone,
            selected == null,
            () => onChanged(null),
          ),
        for (final o in options)
          _chip(o.name, selected == o.id, () => onChanged(o.id)),
      ],
    );
  }

  Widget _statusSelector() {
    return Wrap(
      spacing: FxSpacing.sm,
      children: GoodsStatus.values
          .map(
            (s) => _chip(s.label, _status == s, () {
              setState(() => _status = s);
            }),
          )
          .toList(),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return FxChip(label: label, selected: selected, onTap: onTap);
  }

  Widget _attachments() {
    final palette = FxPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(S.of(context).goodsLabelAttachOptional),
        Wrap(
          spacing: FxSpacing.sm,
          runSpacing: FxSpacing.sm,
          children: [
            for (int i = 0; i < _files.length; i++)
              _thumb(_files[i], () => setState(() => _files.removeAt(i))),
            InkWell(
              onTap: _pickFiles,
              borderRadius: FxRadius.tileBorder,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                  border: Border.all(color: palette.border),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: palette.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _thumb(File file, VoidCallback onRemove) {
    final palette = FxPalette.of(context);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: FxRadius.tileBorder,
            child: Image.file(
              file,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 72,
                height: 72,
                color: palette.surfaceMuted,
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  color: palette.textTertiary,
                ),
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: palette.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: palette.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: FxSpacing.xs),
    child: Text(
      text,
      style: FxTypography.label.copyWith(
        color: FxPalette.of(context).textSecondary,
      ),
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: FxPalette.of(context).surfaceMuted,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FxSpacing.md,
      vertical: FxSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: FxRadius.tileBorder,
      borderSide: BorderSide.none,
    ),
  );
}
