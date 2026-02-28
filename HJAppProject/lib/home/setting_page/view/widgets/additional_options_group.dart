import 'package:flutter/material.dart';
import 'package:hjproject/home/setting_page/view/widgets/setting_group_card.dart';

/// 更多操作分组组件 - Refactored for Design Skill
/// - Uses SettingGroupCard for standard options
/// - Separates Logout into a standalone destructive card
class AdditionalOptionsGroup extends StatelessWidget {
  final VoidCallback onDonate;
  final VoidCallback onFeedback;
  final VoidCallback onRate;
  final VoidCallback onLogout;

  const AdditionalOptionsGroup({
    super.key,
    required this.onDonate,
    required this.onFeedback,
    required this.onRate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard Options Group
        SettingGroupCard(
          title: '更多',
          children: [
            _buildItem(
              context,
              icon: Icons.favorite_outline,
              title: '打赏作者',
              onTap: onDonate,
            ),
            _buildItem(
              context,
              icon: Icons.feedback_outlined,
              title: '意见反馈',
              onTap: onFeedback,
            ),
            _buildItem(
              context,
              icon: Icons.star_outline,
              title: '给应用评分',
              onTap: onRate,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Destructive Action: Logout (Isolated)
        GestureDetector(
          onTap: onLogout,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white, // Token: Surface
              borderRadius: BorderRadius.circular(16), // Token: Radius 16
              // Token: Elevation 0
            ),
            child: const Text(
              '退出登录',
              style: TextStyle(
                color: Colors.red, // Semantic: Destructive
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              
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