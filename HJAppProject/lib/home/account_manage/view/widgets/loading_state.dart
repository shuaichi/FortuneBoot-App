import 'package:flutter/material.dart';
import 'package:fortuneboot/Home/account_manage/constants/design_system.dart' as ds;

/// 增强版加载状态组件
/// 提供更好的视觉反馈和用户体验
class EnhancedLoadingState extends StatefulWidget {
  const EnhancedLoadingState({
    super.key,
    this.message = '正在加载账户...',
    this.showProgress = false,
    this.progress = 0.0,
  });

  final String message;
  final bool showProgress;
  final double progress;

  @override
  State<EnhancedLoadingState> createState() => _EnhancedLoadingStateState();
}

class _EnhancedLoadingStateState extends State<EnhancedLoadingState>
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
                        color: theme.colorScheme.primary.withOpacity(0.3),
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
                  painter: _LoadingPainter(
                    color: theme.colorScheme.primary,
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
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
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
            style: ds.TextStyles.emptyStateDescription.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
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
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        SizedBox(height: ds.Spacing.sm),
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: ds.TextStyles.currencyCode.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 自定义绘制器用于创建加载动画
class _LoadingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LoadingPainter({
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
    return oldDelegate is _LoadingPainter && oldDelegate.progress != progress;
  }
}

/// 骨架屏加载组件
class AccountSkeletonLoader extends StatefulWidget {
  const AccountSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  State<AccountSkeletonLoader> createState() => _AccountSkeletonLoaderState();
}

class _AccountSkeletonLoaderState extends State<AccountSkeletonLoader>
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
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ds.Spacing.md),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: ds.Paddings.cardMargin,
          child: Material(
            elevation: 1,
            borderRadius: ds.BorderRadii.card,
            child: Container(
              padding: ds.Paddings.card,
              decoration: BoxDecoration(
                borderRadius: ds.BorderRadii.card,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonHeader(theme),
                  SizedBox(height: ds.Spacing.sm),
                  _buildSkeletonBalance(theme),
                  SizedBox(height: ds.Spacing.md),
                  _buildSkeletonChips(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonHeader(ThemeData theme) {
    return Row(
      children: [
        _buildShimmerBox(40, 40, isCircle: true, theme: theme),
        SizedBox(width: ds.Spacing.md),
        Expanded(
          child: _buildShimmerBox(120, 20, theme: theme),
        ),
        _buildShimmerBox(24, 24, theme: theme),
      ],
    );
  }

  Widget _buildSkeletonBalance(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildShimmerBox(160, 28, theme: theme),
        ),
        SizedBox(width: ds.Spacing.md),
        _buildShimmerBox(40, 20, theme: theme),
      ],
    );
  }

  Widget _buildSkeletonChips(ThemeData theme) {
    return Row(
      children: [
        _buildShimmerBox(60, 24, theme: theme),
        SizedBox(width: ds.Spacing.sm),
        _buildShimmerBox(50, 24, theme: theme),
        SizedBox(width: ds.Spacing.sm),
        _buildShimmerBox(70, 24, theme: theme),
      ],
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height, {
    bool isCircle = false,
    required ThemeData theme,
  }) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: isCircle 
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(ds.BorderRadiusValues.sm),
          ),
          child: ClipRRect(
            borderRadius: isCircle 
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(ds.BorderRadiusValues.sm),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  left: width * _shimmerAnimation.value,
                  top: 0,
                  bottom: 0,
                  width: width * 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.surface.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}