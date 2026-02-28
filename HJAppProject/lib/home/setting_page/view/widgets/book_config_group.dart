import 'package:flutter/material.dart';
import 'package:hjproject/Home/payee_manage/view/payee_manage_page.dart';
import 'package:hjproject/home/category_manage/view/category_manage_page.dart';
import 'package:hjproject/Home/tag_manage/view/tag_manage_page.dart';
import 'package:hjproject/Home/account_manage/view/account_manage_page.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_group_card.dart';

/// 账本配置分组组件 - Refactored for Design Skill
/// - Uses standard SettingGroupCard for consistency
/// - Standardized Icons & Typography
class BookConfigGroup extends StatelessWidget {
  const BookConfigGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingGroupCard(
      title: '账本配置',
      children: [
        _buildItem(
          context,
          icon: Icons.category_outlined,
          title: '分类管理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CategoryManagePage()),
          ),
        ),
        _buildItem(
          context,
          icon: Icons.label_outline,
          title: '标签管理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TagManagePage()),
          ),
        ),
        _buildItem(
          context,
          icon: Icons.people_outline,
          title: '交易对象',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PayeeManagePage()),
          ),
        ),
        _buildItem(
          context,
          icon: Icons.account_balance_outlined,
          title: '账户管理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AccountManagePage()),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // Standardize Item Style (Match SettingItemTile)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56, // Component Standard: Min height 56
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Standard Icon Container
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 16),
              
              // Standard Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87, // Token: Primary Text
                  ),
                ),
              ),
              
              // Standard Trailing
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}