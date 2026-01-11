import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final bool enableHoverEffect;
  final bool enableTapEffect;
  final Gradient? gradient;

  const AnimatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableHoverEffect = true,
    this.enableTapEffect = true,
    this.gradient,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _shadowAnimation;

  bool _isHovered = false;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 4.0,
      end: (widget.elevation ?? 4.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = ColorTween(
      begin: Colors.black.withValues(alpha:0.1),
      end: Colors.black.withValues(alpha:0.2),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered && !_isTapped) {
      _controller.forward();
    } else if (!isHovered && !_isTapped) {
      _controller.reverse();
    }
  }

  void _handleTapDown() {
    if (!widget.enableTapEffect) return;
    
    setState(() {
      _isTapped = true;
    });
    _controller.reverse();
  }

  void _handleTapUp() {
    if (!widget.enableTapEffect) return;
    
    setState(() {
      _isTapped = false;
    });
    
    if (_isHovered) {
      _controller.forward();
    }
  }

  void _handleTapCancel() {
    if (!widget.enableTapEffect) return;
    
    setState(() {
      _isTapped = false;
    });
    
    if (_isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) {
                _handleTapUp();
                widget.onTap?.call();
              },
              onTapCancel: _handleTapCancel,
              child: Container(
                margin: widget.margin ?? const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  color: widget.gradient == null ? 
                      (widget.backgroundColor ?? Theme.of(context).cardColor) : null,
                  borderRadius: widget.borderRadius is BorderRadius ? widget.borderRadius as BorderRadius : BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _shadowAnimation.value ?? Colors.black.withValues(alpha:0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: widget.borderRadius is BorderRadius ? widget.borderRadius as BorderRadius : BorderRadius.circular(16),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: widget.borderRadius is BorderRadius ? widget.borderRadius as BorderRadius : BorderRadius.circular(16),
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(16.0),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Specialized animated card for statistics/metrics
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      gradient: gradient,
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Specialized animated card for alerts/notifications
class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getAlertColors(type);
    
    return AnimatedCard(
      backgroundColor: colors['background'],
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors['icon']!.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAlertIcon(type),
              color: colors['icon'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors['text'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors['text']!.withValues(alpha:0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                size: 16,
                color: colors['text']!.withValues(alpha:0.6),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Map<String, Color> _getAlertColors(AlertType type) {
    switch (type) {
      case AlertType.success:
        return {
          'background': const Color(0xFFE8F5E8),
          'icon': const Color(0xFF4CAF50),
          'text': const Color(0xFF2E7D32),
        };
      case AlertType.warning:
        return {
          'background': const Color(0xFFFFF3E0),
          'icon': const Color(0xFFFF9800),
          'text': const Color(0xFFE65100),
        };
      case AlertType.error:
        return {
          'background': const Color(0xFFFFEBEE),
          'icon': const Color(0xFFF44336),
          'text': const Color(0xFFC62828),
        };
      case AlertType.info:
        return {
          'background': const Color(0xFFE3F2FD),
          'icon': const Color(0xFF2196F3),
          'text': const Color(0xFF1565C0),
        };
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.error:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
    }
  }
}

enum AlertType { success, warning, error, info }

