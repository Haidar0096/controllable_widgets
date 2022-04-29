part of 'custom_animated_widget.dart';

/// A controller used to control a [CustomAnimatedWidget].
///
/// Must not be used with more than one widget.
abstract class CustomAnimatedWidgetController {
  /// The [AnimationController] of the associated [CustomAnimatedWidget]. It is available only if the widget has been mounted in a tree.
  /// The [CustomAnimatedWidget] is responsible of disposing this [AnimationController].
  AnimationController? get animationController;

  factory CustomAnimatedWidgetController() =>
      CustomAnimatedWidgetControllerImpl();

  void _setAnimationController(AnimationController controller);
}

class CustomAnimatedWidgetControllerImpl
    implements CustomAnimatedWidgetController {
  AnimationController? _animationController;

  @override
  AnimationController? get animationController => _animationController;

  @override
  void _setAnimationController(AnimationController controller) {
    assert(
        _animationController == null,
        'The CustomAnimatedWidgetController must only be used with one widget. Use a new controller if '
        'you want to control another widget.');
    _animationController = controller;
  }
}
