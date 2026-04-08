import 'package:flutter/material.dart';
import 'package:fortuneboot/home/payee_manage/constants/design_system.dart' as ds;

/// 增强版交易对象加载状态组件
/// 提供更好的视觉反馈和用户体验
class EnhancedPayeeLoadingState extends StatefulWidget {
  const EnhancedPayeeLoadingState({
    super.key,
    this.message = '正在加载交易对象...',
    this.showProgress = false,
    this.progress = 0.0,
  });

  final String message;
  final bool showProgress;
  final double progress;

  @override
  State<EnhancedPayeeLoadingState> createState() => _EnhancedPayeeLoadingStateState();
}

class _EnhancedPayeeLoadingStateState extends State<EnhancedPayeeLoadingState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: ds.Durations.verySlow,
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: ds.Durations.slow,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: ds.AnimationCurves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: ds.AnimationCurves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: ds.AnimationCurves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ds.Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(theme),
          SizedBox(height: ds.Spacing.lg),
          _buildMessage(theme),
          if (widget.showProgress) ...[
            SizedBox(height: ds.Spacing.md),
            _buildProgressBar(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈脉动效果
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // 旋转的加载指示器
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: _PayeeLoadingPainter(
                    color: primaryColor,
                    progress: _rotateAnimation.value,
                  ),
                ),
              );
            },
          ),
          // 中心图标
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ds.PayeeStatusIcons.payee,
              size: 16,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            widget.message,
            style: ds.PayeeTextStyles.emptyStateDescription.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widget.progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        SizedBox(height: ds.Spacing.sm),
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: ds.PayeeTextStyles.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 自定义绘制器用于创建交易对象加载动画
class _PayeeLoadingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _PayeeLoadingPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // 绘制多个弧段创建动态效果
    for (int i = 0; i < 3; i++) {
      final startAngle = (progress * 2 * 3.14159) + (i * 2.1);
      final sweepAngle = 1.0;
      
      final segmentPaint = Paint()
        ..color = color.withOpacity(1.0 - (i * 0.3))
        ..strokeWidth = 3 - (i * 0.5)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (i * 2)),
        startAngle,
        sweepAngle,
        false,
        segmentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _PayeeLoadingPainter && oldDelegate.progress != progress;
  }
}

/// 交易对象骨架屏加载组件
class PayeeSkeletonLoader extends StatefulWidget {
  const PayeeSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  State<PayeeSkeletonLoader> createState() => _PayeeSkeletonLoaderState();
}

class _PayeeSkeletonLoaderState extends State<PayeeSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: ds.AnimationCurves.easeInOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: context.responsiveHorizontalPadding,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  Widget _buildSkeletonCard() {
    final theme = Theme.of(context);
    
    return Container(
      margin: ds.Paddings.cardMargin,
      child: Material(
        elevation: 1.0,
        borderRadius: ds.BorderRadii.card,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: ds.BorderRadii.card,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: ds.Paddings.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonHeader(),
                SizedBox(height: ds.Spacing.sm),
                _buildSkeletonStatusChips(),
                SizedBox(height: ds.Spacing.sm),
                _buildSkeletonRemark(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonHeader() {
    return Row(
      children: [
        _buildShimmerBox(40, 40, isCircular: true),
        SizedBox(width: ds.Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(120, 20),
              SizedBox(height: ds.Spacing.xs),
              _buildShimmerBox(80, 14),
            ],
          ),
        ),
        _buildShimmerBox(24, 24, isCircular: true),
      ],
    );
  }

  Widget _buildSkeletonStatusChips() {
    return Wrap(
      spacing: ds.Spacing.xs,
      runSpacing: ds.Spacing.xs,
      children: [
        _buildShimmerBox(60, 24, borderRadius: ds.BorderRadiusValues.pill),
        _buildShimmerBox(70, 24, borderRadius: ds.BorderRadiusValues.pill),
        _buildShimmerBox(50, 24, borderRadius: ds.BorderRadiusValues.pill),
      ],
    );
  }

  Widget _buildSkeletonRemark() {
    return _buildShimmerBox(double.infinity, 40, borderRadius: ds.BorderRadiusValues.sm);
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    bool isCircular = false,
    double? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width == double.infinity ? null : width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: isCircular 
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(borderRadius ?? ds.BorderRadiusValues.xs),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}