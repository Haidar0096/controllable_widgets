import 'package:flutter/material.dart';

part 'custom_positioned_widget_controller.dart';

/// A custom widget with controllable offset and padding. The provided controller can be used to control these properties.
///
/// Considering this widget as the "container", then by default, the child parameter will be bounded inside this "container"
/// (provided it is smaller than it), and the "container" will fill its parent, if it can, otherwise [maxSize] will be used,
/// and if [maxSize] is not provided, then the size returned by [MediaQuery.of(context).size] will be used.
/// For example:
/// ```dart
///        Stack(
///         children: [
///           Positioned( // parent
///             child: CustomPositionedWidget( // container
///               child: SizedBox( // child
///                 width: 100,
///                 height: 100,
///               ),
///               // other params...
///             ),
///           ),
///         ],
///       );
/// ```
/// In the above snippet, since parent has no constraints and maxSize is not provided then size returned by [MediaQuery.of(context).size]
/// will be used for container.
///
/// This widget will take care of disposing the provided [CustomPositionedWidgetController].
class CustomPositionedWidget extends StatefulWidget {
  /// The controller of this widget.
  final CustomPositionedWidgetController controller;

  /// The child of this widget, controllable by the [controller].
  final Widget child;

  /// The max size of this widget. This is not the size of the child, this is rather the size of the "container" that will
  /// contain the child.
  final Size? maxSize;

  const CustomPositionedWidget({
    Key? key,
    required this.child,
    required this.controller,
    this.maxSize,
  }) : super(key: key);

  @override
  State<CustomPositionedWidget> createState() => CustomPositionedWidgetState();
}

class CustomPositionedWidgetState extends State<CustomPositionedWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller._registerWidgetCallback(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: widget.maxSize?.width ?? MediaQuery.of(context).size.width,
      maxHeight: widget.maxSize?.height ?? MediaQuery.of(context).size.height,
      child: CustomSingleChildLayout(
        child: widget.child,
        delegate: _CustomPositionedDelegate(
          padding: widget.controller.padding,
          offsetBuilder: widget.controller.offsetBuilder,
          canGoOffParentBounds: widget.controller.canGoOffParentBounds,
        ),
      ),
    );
  }
}

// delegate for custom layout and positioning of a widget
class _CustomPositionedDelegate extends SingleChildLayoutDelegate {
  final OffsetBuilder offsetBuilder;
  final EdgeInsets padding;
  final bool canGoOffParentBounds;

  _CustomPositionedDelegate({
    required this.offsetBuilder,
    required this.padding,
    required this.canGoOffParentBounds,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The content can be at most the size of the parent minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest).deflate(padding);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // childSize: size of the content
    Offset childTopLeft = offsetBuilder.call(childSize);

    if (canGoOffParentBounds) {
      // no more checks on the position needed
      return childTopLeft;
    }

    // make sure the child does not go off screen in all directions
    // and respects the padding
    if (childTopLeft.dx + childSize.width > size.width - padding.right) {
      final distance =
          -(childTopLeft.dx - (size.width - padding.right - childSize.width));
      childTopLeft = childTopLeft.translate(distance, 0);
    }
    if (childTopLeft.dx < padding.left) {
      final distance = padding.left - childTopLeft.dx;
      childTopLeft = childTopLeft.translate(distance, 0);
    }
    if (childTopLeft.dy + childSize.height > size.height - padding.bottom) {
      final distance = -(childTopLeft.dy -
          (size.height - padding.bottom - childSize.height));
      childTopLeft = childTopLeft.translate(0, distance);
    }
    if (childTopLeft.dy < padding.top) {
      final distance = padding.top - childTopLeft.dy;
      childTopLeft = childTopLeft.translate(0, distance);
    }
    return childTopLeft;
  }

  @override
  bool shouldRelayout(_CustomPositionedDelegate oldDelegate) {
    return oldDelegate.offsetBuilder != offsetBuilder;
  }
}
