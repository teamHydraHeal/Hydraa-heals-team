import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final LoadingType type;

  const LoadingAnimation({
    super.key,
    this.size = 50.0,
    this.color,
    this.message,
    this.type = LoadingType.circular,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoadingWidget(color),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  widget.message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget(Color color) {
    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularLoader(color);
      case LoadingType.dots:
        return _buildDotsLoader(color);
      case LoadingType.wave:
        return _buildWaveLoader(color);
      case LoadingType.pulse:
        return _buildPulseLoader(color);
      case LoadingType.waterDrop:
        return _buildWaterDropLoader(color);
    }
  }

  Widget _buildCircularLoader(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: CircularLoadingPainter(
            progress: _animation.value,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = (_animation.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1 - (progress - 0.5).abs() * 2));
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size * 0.2,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.5 + 0.5 * scale),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWaveLoader(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.15;
            final progress = (_animation.value + delay) % 1.0;
            final height = widget.size * (0.3 + 0.7 * (1 - (progress - 0.5).abs() * 2));
            
            return Container(
              width: widget.size * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(widget.size * 0.075),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _pulseAnimation.value,
          height: widget.size * _pulseAnimation.value,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterDropLoader(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WaterDropPainter(
            progress: _animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class CircularLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;

    // Background circle
    paint.color = color.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = color;
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WaterDropPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaterDropPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Animated water drop shape
    final path = Path();
    final dropHeight = radius * (1.5 + 0.5 * progress);
    
    // Bottom circle
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx, center.dy + dropHeight * 0.2),
      radius: radius,
    ));

    // Top teardrop
    path.moveTo(center.dx, center.dy - dropHeight * 0.8);
    path.quadraticBezierTo(
      center.dx - radius * 0.8,
      center.dy - dropHeight * 0.2,
      center.dx - radius * 0.6,
      center.dy + dropHeight * 0.2,
    );
    path.quadraticBezierTo(
      center.dx + radius * 0.6,
      center.dy + dropHeight * 0.2,
      center.dx + radius * 0.8,
      center.dy - dropHeight * 0.2,
    );
    path.quadraticBezierTo(
      center.dx,
      center.dy - dropHeight * 0.8,
      center.dx,
      center.dy - dropHeight * 0.8,
    );

    canvas.drawPath(path, paint);

    // Add shimmer effect
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * progress)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCircle(
        center: Offset(
          center.dx - radius * 0.3,
          center.dy - dropHeight * 0.2,
        ),
        radius: radius * 0.2,
      ),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

enum LoadingType {
  circular,
  dots,
  wave,
  pulse,
  waterDrop,
}

// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.type = LoadingType.waterDrop,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: LoadingAnimation(
                  size: 60,
                  message: message,
                  type: type,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

