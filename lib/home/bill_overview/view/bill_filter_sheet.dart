import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fortuneboot/home/bill_overview/models/bill_item.dart';
import 'package:fortuneboot/home/bill_overview/models/fortune_bill_query.dart';
import 'package:fortuneboot/home/bill_overview/view/bills_overview_page.dart';

class BillFilterSheet extends StatefulWidget {
  final FortuneBillQuery? initialQuery;

  const BillFilterSheet({super.key, this.initialQuery});

  @override
  State<BillFilterSheet> createState() => _BillFilterSheetState();
}

class _BillFilterSheetState extends State<BillFilterSheet> {
  late FortuneBillQuery _query;
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // 【修复 2】拆分标题和备注的独立输入框，精准对应后端逻辑
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? const FortuneBillQuery();
    _minAmountController.text = _query.amountMin?.toString() ?? '';
    _maxAmountController.text = _query.amountMax?.toString() ?? '';
    _titleController.text = _query.title ?? '';
    _remarkController.text = _query.remark ?? '';
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _titleController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();

    // 【修复 1.2】提交时的兜底校验：开始时间不能大于结束时间
    if (_query.tradeTimeStartTime != null && _query.tradeTimeEndTime != null) {
      final start = _dateFormat.parse(_query.tradeTimeStartTime!);
      final end = _dateFormat.parse(_query.tradeTimeEndTime!);
      if (start.isAfter(end)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('开始日期不能晚于结束日期',
                style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return; // 拦截执行，不关闭弹窗
      }
    }

    final titleText = _titleController.text.trim();
    final remarkText = _remarkController.text.trim();

    final finalQuery = _query.copyWith(
      amountMin: () => _minAmountController.text.isNotEmpty
          ? double.tryParse(_minAmountController.text)
          : null,
      amountMax: () => _maxAmountController.text.isNotEmpty
          ? double.tryParse(_maxAmountController.text)
          : null,
      title: () => titleText.isNotEmpty ? titleText : null,
      remark: () => remarkText.isNotEmpty ? remarkText : null,
    );
    Navigator.pop(context, finalQuery);
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _query = const FortuneBillQuery();
      _minAmountController.clear();
      _maxAmountController.clear();
      _titleController.clear();
      _remarkController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    // 【修复 1.1】对日历选择器进行强约束联动
    if (isStart) {
      if (_query.tradeTimeStartTime != null) {
        initialDate = _dateFormat.parse(_query.tradeTimeStartTime!);
      }
      // 如果选开始时间，最大不能超过已选的结束时间
      if (_query.tradeTimeEndTime != null) {
        lastDate = _dateFormat.parse(_query.tradeTimeEndTime!);
        if (initialDate.isAfter(lastDate)) initialDate = lastDate;
      }
    } else {
      if (_query.tradeTimeEndTime != null) {
        initialDate = _dateFormat.parse(_query.tradeTimeEndTime!);
      }
      // 如果选结束时间，最小不能早于已选的开始时间
      if (_query.tradeTimeStartTime != null) {
        firstDate = _dateFormat.parse(_query.tradeTimeStartTime!);
        if (initialDate.isBefore(firstDate)) initialDate = firstDate;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF007AFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _query = _query.copyWith(
              tradeTimeStartTime: () => _dateFormat.format(picked));
        } else {
          _query = _query.copyWith(
              tradeTimeEndTime: () => _dateFormat.format(picked));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: FintechTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部 Handle 条与标题
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: FintechTheme.divider,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('取消',
                            style: TextStyle(
                                fontSize: 16,
                                color: FintechTheme.textSecondary)),
                      ),
                      const Text('筛选账单',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: FintechTheme.textPrimary)),
                      GestureDetector(
                        onTap: _resetFilters,
                        child: const Text('重置',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFFFF3B30))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 表单滚动区
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('交易类型'),
                _buildCardGroup(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildTypeChip('全部', null),
                      _buildTypeChip('支出', BillType.expenditure.value),
                      _buildTypeChip('收入', BillType.income.value),
                      _buildTypeChip('转账', BillType.transfer.value),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('日期区间'),
                _buildCardGroup(
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildDateButton(
                              '开始日期', _query.tradeTimeStartTime, true)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('至',
                            style:
                                TextStyle(color: FintechTheme.textSecondary)),
                      ),
                      Expanded(
                          child: _buildDateButton(
                              '结束日期', _query.tradeTimeEndTime, false)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('金额区间'),
                _buildCardGroup(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _minAmountController,
                          placeholder: '最低金额',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _textFieldDecoration(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-',
                            style:
                                TextStyle(color: FintechTheme.textSecondary)),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _maxAmountController,
                          placeholder: '最高金额',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _textFieldDecoration(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('文本搜索'),
                // 【修复 2】独立的输入框组合，优雅又清晰
                _buildCardGroup(
                    child: Column(
                  children: [
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: '请输入标题...',
                      clearButtonMode: OverlayVisibilityMode.editing,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: FintechTheme.bg,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Colors.white),
                    // 分割线伪装
                    CupertinoTextField(
                      controller: _remarkController,
                      placeholder: '请输入备注...',
                      clearButtonMode: OverlayVisibilityMode.editing,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        color: FintechTheme.bg,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12)),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),

          // 底部悬浮按钮
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4))
              ],
            ),
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF), // 苹果蓝
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('确认查询',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: FintechTheme.textSecondary)),
    );
  }

  Widget _buildCardGroup({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildTypeChip(String label, int? typeValue) {
    final isSelected = _query.billType == typeValue;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _query = _query.copyWith(billType: () => typeValue));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007AFF).withOpacity(0.1)
              : FintechTheme.bg,
          border: Border.all(
              color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
              width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color:
                isSelected ? const Color(0xFF007AFF) : FintechTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String placeholder, String? dateStr, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: _textFieldDecoration(),
        child: Text(
          dateStr ?? placeholder,
          style: TextStyle(
            fontSize: 15,
            color: dateStr != null
                ? FintechTheme.textPrimary
                : CupertinoColors.placeholderText,
          ),
        ),
      ),
    );
  }

  BoxDecoration _textFieldDecoration() {
    return BoxDecoration(
      color: FintechTheme.bg,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
