part of 'custom_positioned_widget.dart';

typedef OffsetBuilder = Offset Function(Size contentSize);

Offset defaultContentOffsetBuilder(Size contentSize) => Offset.zero;

const EdgeInsets defaultPadding = EdgeInsets.all(0.0);

/// A controller for controlling the position and padding of a widget. Must not be used with more than one widget.
///
/// The attached [CustomPositionedWidget] is responsible of disposing this controller.
abstract class CustomPositionedWidgetController extends ChangeNotifier {
  factory CustomPositionedWidgetController({
    OffsetBuilder? offsetBuilder,
    EdgeInsets? padding,
    bool? canGoOffParentBounds,
  }) =>
      CustomPositionedWidgetControllerImpl(
        offsetBuilder: offsetBuilder,
        padding: padding,
        canGoOffParentBounds: canGoOffParentBounds,
      );

  set offsetBuilder(OffsetBuilder offsetBuilder);

  set padding(EdgeInsets padding);

  set canGoOffParentBounds(bool canGoOffParentBounds);

  /// The offset builder of this controller. It determines the position of the child of the associated [CustomPositionedWidget]
  /// given the size of that child.
  OffsetBuilder get offsetBuilder;

  /// The padding of the child of the associated [CustomPositionedWidget].
  EdgeInsets get padding;

  /// The flag that allows or disallows the child of the [CustomPositionedWidget] to go off its bounds.
  /// Defaults to true, i.e. the child can go off parent bounds.
  bool get canGoOffParentBounds;

  void _registerWidgetCallback(VoidCallback callback);
}

class CustomPositionedWidgetControllerImpl extends ChangeNotifier
    implements CustomPositionedWidgetController {
  CustomPositionedWidgetControllerImpl({
    OffsetBuilder? offsetBuilder,
    EdgeInsets? padding,
    bool? canGoOffParentBounds,
  })  : _offsetBuilder = offsetBuilder ?? defaultContentOffsetBuilder,
        _padding = padding ?? defaultPadding,
        _canGoOffParentBounds = canGoOffParentBounds ?? true;

  OffsetBuilder _offsetBuilder;

  bool _canGoOffParentBounds;

  EdgeInsets _padding;

  @override
  set offsetBuilder(OffsetBuilder value) {
    _offsetBuilder = value;
    notifyListeners();
  }

  @override
  set canGoOffParentBounds(bool value) {
    _canGoOffParentBounds = value;
    notifyListeners();
  }

  @override
  set padding(EdgeInsets value) {
    _padding = value;
    notifyListeners();
  }

  @override
  OffsetBuilder get offsetBuilder => _offsetBuilder;

  @override
  bool get canGoOffParentBounds => _canGoOffParentBounds;

  @override
  EdgeInsets get padding => _padding;

  @override
  void _registerWidgetCallback(VoidCallback callback) {
    assert(
        !hasListeners,
        'The CustomPositionedWidgetController must only be used with one widget. Use a new controller if '
        'you want to control another widget.');
    addListener(callback);
  }
}
