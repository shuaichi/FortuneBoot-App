import 'package:flutter/material.dart';

/// 打赏作者二维码底部弹窗组件 - Refactored for Design Skill
/// - Surface: White BottomSheet (Radius Top 20)
/// - Background: Colors.white
class DonateQrSheet extends StatelessWidget {
  final VoidCallback onLongPressWechat;
  final VoidCallback onLongPressAlipay;

  const DonateQrSheet({
    super.key,
    required this.onLongPressWechat,
    required this.onLongPressAlipay,
  });

  @override
  Widget build(BuildContext context) {
    // Design Token: Background
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Handle Bar (Visual Cue)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '给作者加个油',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '如果这个开源项目对你有帮助，欢迎打赏一杯咖啡（10元），你的支持是我持续维护与迭代的最大动力。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildQrCard(
                          context, 
                          'assets/images/donate_wechat.jpg', 
                          onLongPressWechat,
                        ),
                        const SizedBox(height: 12),
                        const Text('微信收款码', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildQrCard(
                          context, 
                          'assets/images/donate_alipay.jpg', 
                          onLongPressAlipay,
                        ),
                        const SizedBox(height: 12),
                        const Text('支付宝收款码', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '提示：长按二维码可保存，或直接打开微信/支付宝“扫一扫”。感谢你的每一份支持！',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('关闭'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String assetPath, VoidCallback onLongPress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Image.asset(
            assetPath,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 160,
                color: Colors.grey[100],
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_outlined, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('加载失败', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}