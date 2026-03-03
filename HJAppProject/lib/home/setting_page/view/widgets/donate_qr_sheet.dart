import 'package:flutter/material.dart';
import 'package:hjproject/home/design_system/hjds_components.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('给作者加个油',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Text('如果这个开源项目对你有帮助，欢迎打赏一杯咖啡。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _buildQrCard(
                      context,
                      'assets/images/donate_wechat.jpg',
                      '微信收款码',
                      onLongPressWechat)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildQrCard(
                      context,
                      'assets/images/donate_alipay.jpg',
                      '支付宝收款码',
                      onLongPressAlipay)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: HJButton.secondary(
                  text: '关闭', onPressed: () => Navigator.pop(context))),
        ],
      ),
    );
  }

  Widget _buildQrCard(BuildContext context, String assetPath, String label,
      VoidCallback onLongPress) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey))),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}
