part of 'popup_controller.dart';

class PopupControllerImpl implements PopupController {
  OverlayEntry? popupEntry;
  CustomAnimatedWidgetController? animatedWidgetController;
  CustomPositionedWidgetController? positionedWidgetController;

  @override
  AnimationController? get popupAnimationController =>
      animatedWidgetController?.animationController;

  @override
  CustomPositionedWidgetController? get popupPositionController =>
      positionedWidgetController;

  @override
  void create({
    required BuildContext context,
    required ContentBuilder builder,
    OffsetBuilder? offsetBuilder,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    TransitionBuilder? transitionBuilder,
    Curve? transitionCurve,
    Curve? reverseTransitionCurve,
    EdgeInsets? padding,
    bool? canGoOffScreen,
  }) {
    if (popupEntry == null) {
      animatedWidgetController = CustomAnimatedWidgetController();
      positionedWidgetController = CustomPositionedWidgetController(
        offsetBuilder: offsetBuilder,
        padding: padding,
        canGoOffParentBounds: canGoOffScreen,
      );
      popupEntry = OverlayEntry(
        builder: (context) {
          // we also wrap the popup content with a CustomSingleChildLayout to control its position and layout
          return CustomPositionedWidget(
            controller: positionedWidgetController!,
            child: CustomAnimatedWidget(
              child: builder.call(context),
              controller: animatedWidgetController!,
              transitionBuilder: transitionBuilder,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              transitionCurve: transitionCurve,
              reverseTransitionCurve: reverseTransitionCurve,
            ),
          );
        },
      );
      Overlay.of(context)!.insert(popupEntry!);
    }
  }

  @override
  void dismiss() {
    popupEntry?.remove();
    popupEntry = null;
    animatedWidgetController = null;
    positionedWidgetController = null;
  }

  @override
  void changeOffset(OffsetBuilder updated) {
    positionedWidgetController?.offsetBuilder = updated;
  }
}
