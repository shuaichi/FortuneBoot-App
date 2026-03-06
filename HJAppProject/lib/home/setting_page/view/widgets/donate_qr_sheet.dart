import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';
import 'package:hjproject/home/design_system/hjds_theme.dart';

class DonateQrSheet extends StatelessWidget {
  final VoidCallback onLongPressWechat;
  final VoidCallback onLongPressAlipay;

  const DonateQrSheet(
      {super.key,
      required this.onLongPressWechat,
      required this.onLongPressAlipay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: HJColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: HJColors.divider,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('给作者加个油',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: HJColors.textPrimary)),
          const SizedBox(height: 12),
          const Text('如果这个开源项目对你有帮助，欢迎打赏一杯咖啡。',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: HJColors.textSecondary, fontSize: 15, height: 1.5)),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _buildQrCard(
                      context,
                      'assets/images/donate_wechat.jpg',
                      '微信收款码',
                      onLongPressWechat,
                      HJColors.income)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildQrCard(
                      context,
                      'assets/images/donate_alipay.jpg',
                      '支付宝收款码',
                      onLongPressAlipay,
                      HJColors.primary)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
              width: double.infinity,
              child: HJButton.secondary(
                  text: '关闭', onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String assetPath, String label,
      VoidCallback onLongPress, Color accentColor) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            HapticFeedback.lightImpact();
            onLongPress();
          },
          child: Container(
            height: 160,
            decoration: BoxDecoration(
                color: HJColors.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: accentColor.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
                border:
                    Border.all(color: accentColor.withOpacity(0.1), width: 1)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.qr_code_2,
                          color: accentColor.withOpacity(0.5), size: 48))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor)),
        ),
      ],
    );
  }
}
