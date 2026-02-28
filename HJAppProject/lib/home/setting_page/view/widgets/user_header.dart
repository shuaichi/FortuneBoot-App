import 'package:flutter/material.dart';

/// 用户头部区域组件 - Refactored for Design Skill
/// - Surface: White Card (Radius 16)
/// - Hierarchy: Avatar > Name > Action
/// - No complex gradients
class MineUserHeader extends StatelessWidget {
  final String username;
  final VoidCallback onViewProfile;
  final VoidCallback onShowQRCode;

  const MineUserHeader({
    super.key,
    required this.username,
    required this.onViewProfile,
    required this.onShowQRCode,
  });

  @override
  Widget build(BuildContext context) {
    final initials = (username.isNotEmpty ? username.substring(0, 1) : '?').toUpperCase();
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Design Token: Card Surface
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Token: Elevation 0 implied
      ),
      child: Row(
        children: [
          // Avatar Area
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Info Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Token: Primary Text
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onViewProfile,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看个人资料',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600], // Token: Secondary Text
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action (QR Code)
          IconButton(
            icon: Icon(
              Icons.qr_code, 
              color: Colors.grey[600]
            ),
            onPressed: onShowQRCode,
            tooltip: '打赏/二维码',
          ),
        ],
      ),
    );
  }
}