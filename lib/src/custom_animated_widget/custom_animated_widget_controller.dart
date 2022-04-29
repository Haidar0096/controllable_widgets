part of 'custom_animated_widget.dart';

/// A controller used to control a [CustomAnimatedWidget]. The controller must not be used with more than one widget.
/// If you want to control another widget, create another controller.
///
/// It is the responsibility of the attached [CustomAnimatedWidget] to dispose the [animationController]. Do not call dispose on it.
class CustomAnimatedWidgetController {
  GlobalKey<CustomAnimatedWidgetState_>? _key;

  /// The [AnimationController] of the associated [CustomAnimatedWidget]. It is available (not null) only if the controller has been
  /// attached to a widget and that widget has been mounted in a tree.
  ///
  /// The attached [CustomAnimatedWidget] is responsible of disposing this [AnimationController]. Do not call dispose on it.
  AnimationController? get animationController =>
      _key?.currentState?.animationController;

  GlobalKey<CustomAnimatedWidgetState_> _registerKey(
      GlobalKey<CustomAnimatedWidgetState_> key) {
    if (_key != null) {
      return _key!;
    }
    _key = key;
    return _key!;
  }
}
