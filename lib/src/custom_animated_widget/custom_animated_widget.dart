import 'package:flutter/material.dart' hide TransitionBuilder;

part 'custom_animated_widget_controller.dart';

const Duration _defaultTransitionDuration = Duration(milliseconds: 200);

const Duration _defaultReverseTransitionDuration = Duration(milliseconds: 200);

const _defaultTransitionCurve = Curves.linear;

const _defaultReverseTransitionCurve = Curves.linear;

Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
  return child;
}

/// A callback that determines the transition animation of the popup.
///
/// [child] is the content of the popup.
typedef TransitionBuilder = Widget Function(
  Widget child,
  Animation<double> animation,
);

/// A Widget that handles animations for its child. Transition durations and curves can be provided to customize the animation.
///
/// The provided [CustomAnimatedWidgetController] can be used to control the animation programmatically.
class CustomAnimatedWidget extends StatefulWidget {
  /// The widget to be animated.
  final Widget child;

  /// The controller of this widget's animations.
  final CustomAnimatedWidgetController controller;

  /// builder for child's entrance and leaving animations
  final TransitionBuilder transitionBuilder;

  /// Forward animation duration.
  final Duration transitionDuration;

  /// Reverse animation duration.
  final Duration reverseTransitionDuration;

  /// Forward animation curve.
  final Curve transitionCurve;

  /// Reverse animation curve.
  final Curve reverseTransitionCurve;

  /// Whether the widget starts with animation when inserted into the tree.
  final bool initiallyAnimating;

  const CustomAnimatedWidget({
    Key? key,
    required this.child,
    required this.controller,
    TransitionBuilder? transitionBuilder,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Curve? transitionCurve,
    Curve? reverseTransitionCurve,
    bool? initiallyAnimating,
  })  : transitionBuilder = transitionBuilder ?? _defaultTransitionBuilder,
        transitionDuration = transitionDuration ?? _defaultTransitionDuration,
        reverseTransitionDuration =
            reverseTransitionDuration ?? _defaultReverseTransitionDuration,
        transitionCurve = transitionCurve ?? _defaultTransitionCurve,
        reverseTransitionCurve =
            reverseTransitionCurve ?? _defaultReverseTransitionCurve,
        initiallyAnimating = initiallyAnimating ?? true,
        super(key: key);

  @override
  State<CustomAnimatedWidget> createState() => CustomAnimatedWidgetState();
}

class CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        duration: widget.transitionDuration,
        reverseDuration: widget.reverseTransitionDuration);

    if (widget.initiallyAnimating) {
      animationController.forward();
    } else {
      animationController.value = 1.0;
    }

    widget.controller._setAnimationController(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.transitionBuilder.call(
      widget.child,
      CurvedAnimation(
        parent: animationController,
        curve: widget.transitionCurve,
        reverseCurve: widget.reverseTransitionCurve,
      ),
    );
  }
}
