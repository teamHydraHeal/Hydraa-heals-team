import 'package:flutter/material.dart';

class PageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 300);

  // Slide transition from right
  static PageRouteBuilder slideFromRight<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: curve),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Slide transition from left
  static PageRouteBuilder slideFromLeft<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: curve),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Slide transition from bottom
  static PageRouteBuilder slideFromBottom<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween.chain(
          CurveTween(curve: curve),
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  // Fade transition
  static PageRouteBuilder fade<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            CurveTween(curve: curve),
          ),
          child: child,
        );
      },
    );
  }

  // Scale transition
  static PageRouteBuilder scale<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
    double beginScale = 0.0,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: beginScale,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: child,
        );
      },
    );
  }

  // Rotation transition
  static PageRouteBuilder rotation<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  // Custom elastic transition
  static PageRouteBuilder elastic<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
      },
    );
  }

  // Shared axis transition (Material Design)
  static PageRouteBuilder sharedAxis<T>({
    required Widget page,
    Duration duration = defaultDuration,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  // Through transition (for modal-like behavior)
  static PageRouteBuilder through<T>({
    required Widget page,
    Duration duration = defaultDuration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        
        final slideAnimation = Tween(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

class _SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const _SharedAxisTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _getSlideAnimation(),
      child: FadeTransition(
        opacity: _getFadeAnimation(),
        child: child,
      ),
    );
  }

  Animation<Offset> _getSlideAnimation() {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return Tween<Offset>(
          begin: const Offset(0.3, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));
      case SharedAxisTransitionType.vertical:
        return Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));
      case SharedAxisTransitionType.scaled:
        return Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(animation);
    }
  }

  Animation<double> _getFadeAnimation() {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));
  }
}

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

// Custom route for enhanced transitions
class EnhancedPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final PageTransitionBuilder transitionBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  EnhancedPageRoute({
    required this.page,
    required this.transitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => transitionDuration;

  @override
  Duration get reverseTransitionDuration => reverseTransitionDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

// Extension for easy navigation with transitions
extension NavigatorStateExtension on NavigatorState {
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    PageTransitionType transition = PageTransitionType.slideFromRight,
    Duration duration = PageTransitions.defaultDuration,
    Curve curve = Curves.easeInOut,
  }) {
    late PageRouteBuilder<T> route;

    switch (transition) {
      case PageTransitionType.slideFromRight:
        route = PageTransitions.slideFromRight<T>(
          page: page,
          duration: duration,
          curve: curve,
        );
        break;
      case PageTransitionType.slideFromLeft:
        route = PageTransitions.slideFromLeft<T>(
          page: page,
          duration: duration,
          curve: curve,
        );
        break;
      case PageTransitionType.slideFromBottom:
        route = PageTransitions.slideFromBottom<T>(
          page: page,
          duration: duration,
          curve: curve,
        );
        break;
      case PageTransitionType.fade:
        route = PageTransitions.fade<T>(
          page: page,
          duration: duration,
          curve: curve,
        );
        break;
      case PageTransitionType.scale:
        route = PageTransitions.scale<T>(
          page: page,
          duration: duration,
          curve: curve,
        );
        break;
      case PageTransitionType.elastic:
        route = PageTransitions.elastic<T>(
          page: page,
          duration: duration,
        );
        break;
    }

    return push(route);
  }
}

enum PageTransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fade,
  scale,
  elastic,
}

