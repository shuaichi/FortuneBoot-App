import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fortuneboot/core/network/fx_api.dart';
import 'package:fortuneboot/features/goods/data/goods_models.dart';
import 'package:fortuneboot/features/goods/data/goods_service.dart';
import 'package:fortuneboot/fx/components/fx_button.dart';
import 'package:fortuneboot/fx/tokens/fx_colors.dart';
import 'package:fortuneboot/fx/tokens/fx_radius.dart';
import 'package:fortuneboot/fx/tokens/fx_spacing.dart';
import 'package:fortuneboot/fx/tokens/fx_typography.dart';
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
  State<GoodsFormSheet> createState() => _GoodsFormSheetState();
}

class _GoodsFormSheetState extends State<GoodsFormSheet> {
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
    _status = widget.isEdit ? GoodsStatus.fromValue(g?.status) : GoodsStatus.active;
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
      });
    } on Object {
      // 选项拉取失败不阻塞表单；用户仍可不选分类/标签提交。
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
    if (_categoryId != null) body['categoryId'] = _categoryId;
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

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '请输入物品名称');
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      setState(() => _error = '请输入有效价格');
      return;
    }
    if (_statusForSubmit == null) {
      setState(() => _error = '请选择物品状态');
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
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result == null) return;
    final files =
        result.paths.whereType<String>().map((p) => File(p)).toList();
    if (files.isNotEmpty) setState(() => _files.addAll(files));
  }

  @override
  Widget build(BuildContext context) {
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
          _label('物品名称'),
          TextField(controller: _nameCtrl, decoration: _dec('如：iPhone 15')),
          const SizedBox(height: FxSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('购买价格'),
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
                    _label('购买日期'),
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
          const SizedBox(height: FxSpacing.md),
          _label('保修日期（可选）'),
          _dateField(
            _warrantyDate,
            () => _pickDate(
              _warrantyDate,
              (d) => setState(() => _warrantyDate = d),
            ),
            hint: '未设置',
            onClear: _warrantyDate == null
                ? null
                : () => setState(() => _warrantyDate = null),
          ),
          const SizedBox(height: FxSpacing.md),
          _label('分类（可选）'),
          _optionSelector(
            _categories,
            _categoryId,
            (id) => setState(() => _categoryId = id),
            empty: '无分类',
          ),
          const SizedBox(height: FxSpacing.md),
          _label('标签（可选）'),
          _optionSelector(
            _tags,
            _tagId,
            (id) => setState(() => _tagId = id),
            empty: '无标签',
          ),
          const SizedBox(height: FxSpacing.md),
          _label('状态'),
          _statusSelector(),
          if (widget.isEdit && _status == null)
            Padding(
              padding: const EdgeInsets.only(top: FxSpacing.xs),
              child: Text(
                '当前状态「${widget.goods?.statusDesc ?? '未知'}」暂不可识别，'
                '如需修改请重新选择；不选则保留原状态。',
                style: FxTypography.caption.copyWith(
                  color: FxColors.textTertiary,
                ),
              ),
            ),
          const SizedBox(height: FxSpacing.sm),
          Row(
            children: [
              const Expanded(child: Text('按次使用', style: FxTypography.body)),
              Switch.adaptive(
                value: _useByTimes,
                activeColor: FxColors.primary,
                onChanged: (v) => setState(() => _useByTimes = v),
              ),
            ],
          ),
          if (_useByTimes) ...[
            _label('使用次数'),
            TextField(
              controller: _usageNumCtrl,
              keyboardType: TextInputType.number,
              decoration: _dec('如：120'),
            ),
            const SizedBox(height: FxSpacing.md),
          ],
          if (_isRetiredOrSold) ...[
            _label('退役日期'),
            _dateField(
              _retiredDate,
              () => _pickDate(
                _retiredDate,
                (d) => setState(() => _retiredDate = d),
              ),
              hint: '未设置',
              onClear: _retiredDate == null
                  ? null
                  : () => setState(() => _retiredDate = null),
            ),
            const SizedBox(height: FxSpacing.md),
          ],
          if (_isSold) ...[
            _label('出售价格'),
            TextField(
              controller: _soldPriceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _dec('0.00'),
            ),
            const SizedBox(height: FxSpacing.md),
          ],
          _label('备注（可选）'),
          TextField(controller: _remarkCtrl, decoration: _dec('备注')),
          const SizedBox(height: FxSpacing.md),
          _attachments(),
          if (_error != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text(
              _error!,
              style: FxTypography.caption.copyWith(color: FxColors.danger),
            ),
          ],
          const SizedBox(height: FxSpacing.xl),
          FxButton(
            label: widget.isEdit ? '保存修改' : '添加物品',
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _dateField(
    DateTime? value,
    VoidCallback onTap, {
    String? hint,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: FxRadius.tileBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.md,
        ),
        decoration: BoxDecoration(
          color: FxColors.surfaceMuted,
          borderRadius: FxRadius.tileBorder,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: FxColors.textSecondary,
            ),
            const SizedBox(width: FxSpacing.sm),
            Expanded(
              child: Text(
                value == null ? (hint ?? '选择日期') : _day.format(value),
                style: FxTypography.body.copyWith(
                  color: value == null
                      ? FxColors.textTertiary
                      : FxColors.textPrimary,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: FxColors.textTertiary,
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
  }) {
    if (options.isEmpty) {
      return Text(
        '$empty（无可选项）',
        style: FxTypography.caption.copyWith(color: FxColors.textTertiary),
      );
    }
    return Wrap(
      spacing: FxSpacing.sm,
      runSpacing: FxSpacing.sm,
      children: [
        _chip('不选', selected == null, () => onChanged(null)),
        for (final o in options)
          _chip(o.name, selected == o.id, () => onChanged(o.id)),
      ],
    );
  }

  Widget _statusSelector() {
    return Wrap(
      spacing: FxSpacing.sm,
      children: GoodsStatus.values
          .map((s) => _chip(s.label, _status == s, () {
                setState(() => _status = s);
              }))
          .toList(),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FxSpacing.md,
          vertical: FxSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? FxColors.primaryContainer : FxColors.surfaceMuted,
          borderRadius: FxRadius.pillBorder,
          border: Border.all(
            color: selected ? FxColors.primary : FxColors.border,
          ),
        ),
        child: Text(
          label,
          style: FxTypography.label.copyWith(
            color: selected ? FxColors.primary : FxColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _attachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('附件（可选）'),
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
                  color: FxColors.surfaceMuted,
                  borderRadius: FxRadius.tileBorder,
                  border: Border.all(color: FxColors.border),
                ),
                child: const Icon(
                  Icons.add_a_photo_outlined,
                  color: FxColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _thumb(File file, VoidCallback onRemove) {
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
                color: FxColors.surfaceMuted,
                child: const Icon(
                  Icons.insert_drive_file_rounded,
                  color: FxColors.textTertiary,
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
                decoration: const BoxDecoration(
                  color: FxColors.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: Colors.white,
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
    child: Text(text, style: FxTypography.label),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: FxColors.surfaceMuted,
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
