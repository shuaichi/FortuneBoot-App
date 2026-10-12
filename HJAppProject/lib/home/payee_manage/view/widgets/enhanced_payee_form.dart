import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/payee_manage/constants/design_system.dart' as ds;
import 'package:hjproject/Home/common/widgets/icon_form_field.dart';
import 'package:hjproject/util/app_icon.dart';

/// 增强版交易对象表单组件
/// 基于设计系统重构，提供现代化的表单体验
class EnhancedPayeeForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController sortController;
  final TextEditingController remarkController;

  final FocusNode nameNode;
  final FocusNode sortNode;
  final FocusNode remarkNode;

  final bool canExpense;
  final bool canIncome;
  final bool enable;

  /// 自定义图标名；为空时使用默认图标
  final String? icon;

  /// 图标选择回调；null 表示恢复默认
  final ValueChanged<String?> onIconChanged;

  final ValueChanged<bool> onCanExpenseChanged;
  final ValueChanged<bool> onCanIncomeChanged;
  final ValueChanged<bool> onEnableChanged;

  final VoidCallback onChanged;
  final bool isBusy;

  const EnhancedPayeeForm({
    Key? key,
    required this.nameController,
    required this.sortController,
    required this.remarkController,
    required this.nameNode,
    required this.sortNode,
    required this.remarkNode,
    required this.canExpense,
    required this.canIncome,
    required this.enable,
    required this.icon,
    required this.onIconChanged,
    required this.onCanExpenseChanged,
    required this.onCanIncomeChanged,
    required this.onEnableChanged,
    required this.onChanged,
    required this.isBusy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isBusy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 基本信息卡片
          _buildSectionCard(
            context: context,
            title: '基本信息',
            subtitle: '设置交易对象的名称和排序',
            child: Column(
              children: [
                _buildNameField(context),
                SizedBox(height: ds.Spacing.md),
                IconFormField(
                  title: '交易对象图标',
                  value: icon,
                  defaultIconName: AppIcon.payeeFallback,
                  onChanged: onIconChanged,
                ),
                SizedBox(height: ds.Spacing.md),
                _buildSortField(context),
              ],
            ),
          ),

          // 权限设置卡片
          _buildSectionCard(
            context: context,
            title: '权限设置',
            subtitle: '控制该交易对象的使用范围',
            child: Column(
              children: [
                _buildPermissionSwitch(
                  context: context,
                  title: '支出权限',
                  subtitle: '允许在支出记录中使用',
                  value: canExpense,
                  onChanged: onCanExpenseChanged,
                  activeColor: ds.PayeeColors.expenseEnabled,
                  icon: ds.PayeeStatusIcons.expenseEnabled,
                ),
                SizedBox(height: ds.Spacing.md),
                _buildPermissionSwitch(
                  context: context,
                  title: '收入权限',
                  subtitle: '允许在收入记录中使用',
                  value: canIncome,
                  onChanged: onCanIncomeChanged,
                  activeColor: ds.PayeeColors.incomeEnabled,
                  icon: ds.PayeeStatusIcons.incomeEnabled,
                ),
                SizedBox(height: ds.Spacing.md),
                _buildPermissionSwitch(
                  context: context,
                  title: '启用状态',
                  subtitle: '控制是否在列表中显示',
                  value: enable,
                  onChanged: onEnableChanged,
                  activeColor: ds.PayeeColors.enabled,
                  icon: enable 
                      ? ds.PayeeStatusIcons.enabled 
                      : ds.PayeeStatusIcons.disabled,
                ),
              ],
            ),
          ),

          // 备注信息卡片
          _buildSectionCard(
            context: context,
            title: '备注信息',
            subtitle: '可选的补充说明',
            child: _buildRemarkField(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: ds.Paddings.cardMargin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: ds.BorderRadii.card,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: ds.Shadows.elevation1,
      ),
      child: Padding(
        padding: EdgeInsets.all(ds.Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, title, subtitle),
            SizedBox(height: ds.Spacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String? subtitle) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ds.PayeeTextStyles.pageTitle.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: ds.Spacing.xs),
          Text(
            subtitle,
            style: ds.PayeeTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    required IconData icon,
    bool hasError = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      labelText: label,
      labelStyle: ds.PayeeTextStyles.remark.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      hintStyle: ds.PayeeTextStyles.remark.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      prefixIcon: Icon(
        icon,
        color: hasError
            ? ds.PayeeColors.expenseEnabled
            : theme.colorScheme.onSurfaceVariant,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError 
              ? ds.PayeeColors.expenseEnabled 
              : theme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: hasError 
              ? ds.PayeeColors.expenseEnabled 
              : ds.PayeeColors.primary,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ds.PayeeColors.expenseEnabled,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ds.PayeeColors.expenseEnabled,
          width: 2,
        ),
        borderRadius: ds.BorderRadii.button,
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ds.Spacing.md,
        vertical: ds.Spacing.md,
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      focusNode: nameNode,
      enabled: !isBusy,
      decoration: _buildInputDecoration(
        context,
        label: '名称',
        hint: '请输入交易对象名称（必填）',
        icon: ds.PayeeStatusIcons.payee,
      ),
      maxLength: 32,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(sortNode);
      },
      onChanged: (_) => onChanged(),
      validator: (value) {
        final text = (value ?? '').trim();
        if (text.isEmpty) return '名称不能为空';
        if (text.length > 32) return '名称长度不能超过32个字符';
        return null;
      },
    );
  }

  Widget _buildSortField(BuildContext context) {
    return TextFormField(
      controller: sortController,
      focusNode: sortNode,
      enabled: !isBusy,
      decoration: _buildInputDecoration(
        context,
        label: '排序',
        hint: '可选，用于控制显示顺序',
        icon: Icons.sort_outlined,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.end,
      maxLength: 9,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(remarkNode);
      },
      onChanged: (_) => onChanged(),
      validator: (value) {
        final text = (value ?? '').trim();
        if (text.isEmpty) return null;
        final number = int.tryParse(text);
        if (number == null) return '必须为整数';
        if (number < 0) return '必须为非负数';
        return null;
      },
    );
  }

  Widget _buildRemarkField(BuildContext context) {
    return TextFormField(
      controller: remarkController,
      focusNode: remarkNode,
      enabled: !isBusy,
      decoration: _buildInputDecoration(
        context,
        label: '备注',
        hint: '可选，最多200个字符',
        icon: Icons.note_outlined,
      ),
      maxLines: 3,
      maxLength: 200,
      textInputAction: TextInputAction.done,
      onChanged: (_) => onChanged(),
      validator: (value) {
        final text = value ?? '';
        if (text.length > 200) return '备注长度不能超过200个字符';
        return null;
      },
    );
  }

  Widget _buildPermissionSwitch({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(ds.Spacing.md),
      decoration: BoxDecoration(
        color: value 
            ? activeColor.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: ds.BorderRadii.button,
        border: Border.all(
          color: value 
              ? activeColor.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ds.Spacing.sm),
            decoration: BoxDecoration(
              color: value ? activeColor : theme.colorScheme.surfaceVariant,
              borderRadius: ds.BorderRadii.chip,
            ),
            child: Icon(
              icon,
              size: 20,
              color: value 
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: ds.Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ds.PayeeTextStyles.payeeName.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: ds.FontSizes.body,
                  ),
                ),
                Text(
                  subtitle,
                  style: ds.PayeeTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: isBusy ? null : (newValue) {
              onChanged(newValue);
            },
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}