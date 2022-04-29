import 'package:controllable_widgets/controllable_widgets.dart';
import 'package:flutter/material.dart' hide TransitionBuilder;

part 'popup_controller_impl.dart';

/// A callback that determines the transition animations of the popup.
///
/// [child] is the content of the popup.
typedef TransitionBuilder = Widget Function(
  Widget child,
  Animation<double> animation,
);

/// A callback that determines the offset of the popup.
///
/// [contentSize] is the [Size] of the popup's content
typedef OffsetBuilder = Offset Function(Size contentSize);

/// A callback used for determining the content of the popup.
typedef ContentBuilder = Widget Function(BuildContext context);

/// A controller used to control the properties of a single popup.
/// The controller should be disposed when it is not going to be used anymore.
abstract class PopupController {
  factory PopupController() => PopupControllerImpl();

  /// The [AnimationController] associated with the popup.
  AnimationController? get popupAnimationController;

  /// The [CustomPositionedWidgetController] associated with the popup. It can control the offset and padding of the popup.
  CustomPositionedWidgetController? get popupPositionController;

  /// Creates a popup and displays it anywhere on the screen. Does nothing if the popup has already been created.
  /// If you want to control the popup, you can inspect the exposed properties of the [PopupController].
  /// A controller controls at most one popup at a time, for showing another popup at the same time,
  /// use another controller.
  ///
  /// The popup will be added to the navigator's overlay.
  ///
  /// Parameters:
  /// - [builder] : The builder of the widget to be displayed. See [transitionBuilder] for animating the popup.
  /// - [offsetBuilder] : A callback that provides the [Size] of the content to determine the coordinate
  /// of the top left of the popup's widget in the overlay coordinates system of the navigator, defaults to [Offset.zero].
  /// - [transitionDuration] : The entering transition duration.
  /// - [reverseTransitionDuration] : The leaving transition duration.
  /// - [transitionBuilder] : A callback that determines the transition animations of the popup. The
  /// content of the popup will be the wrapped with the returned widget.
  /// - [transitionCurve] : The curve to use upon entrance of the popup.
  /// - [reverseTransitionCurve] : The curve to use upon leaving of the popup.
  /// - [padding] : The minimum padding to use if the popup goes off the screen on any edge.
  /// - [canGoOffScreen] : If true, then the popup content may go off screen if its dimensions are larger
  /// than screen dimensions.
  void create({
    required BuildContext context,
    required ContentBuilder builder,
    OffsetBuilder offsetBuilder,
    EdgeInsets padding,
    bool canGoOffScreen,
    TransitionBuilder transitionBuilder,
    Duration transitionDuration,
    Duration reverseTransitionDuration,
    Curve transitionCurve,
    Curve reverseTransitionCurve,
  });

  /// Dismisses the popup. Does nothing if the popup is not created.
  /// This will remove the popup entirely from the overlay, so no animations will be shown.
  void dismiss();

  /// Changes the offset of the popup according to the returned result by the provided [OffsetBuilder].
  void changeOffset(OffsetBuilder offsetBuilder);
}
