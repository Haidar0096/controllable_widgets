#### Tired of writing the same logic everytime you want to animate entrance and leaving of a widget? Or when controlling the position of a widget? Or moreover when you want to show a popup? Relax, we've got you covered 😊😊 !

## Features

### Popup:
- Show **any** widget (popup) **anywhere** on the screen.
- Customize entrance and leaving transitions of the popup content, as well as the durations and curves.
- Support for limiting your popup inside the visible screen area if you choose to do so.
  ![Alt Text](https://github.com/Haidar0096/controllable_widgets/blob/master/screenshots/demo.gif?raw=true)

### Custom Animated Widget:
- A widget that animates, and is controllable! Specify your child widget and animations, and Voila, you've got a controllable animated widget!
- Control the animated widget from anywhere by using an animated widget controller.
- Disposing of the animation controller is taken care of for you by the widget itself.
  ![Alt Text](https://github.com/Haidar0096/controllable_widgets/blob/master/screenshots/custom_animated_widget_demo.gif?raw=true)

### Custom Positioned Widget:
- Why only custom animated widget? Here comes custom positioned widget! This is also controllable widget, just call the custom positioned widget controller and change the offset.
- Again, disposing is taken care of for you by the widget itself.
  ![Alt Text](https://github.com/Haidar0096/controllable_widgets/blob/master/screenshots/custom_positioned_widget_demo.gif?raw=true)




### What Else?
- The package is tested and documented.
##### Coming Soon: Attach your popup to a widget and move it anywhere with this widget !


## Usage

- Popup:
```dart
              final PopupController _controller = PopupController();
_controller.create(
context: context,
builder: (context) {
return StatefulBuilder(
builder: (context, state) => GestureDetector(
onPanUpdate: (d) {
// 🚨🚨🚨 be careful here, if you set the child of the positioned widget to be bounded, then you must update the offset such that
// you discard updated offsets that are outside the "container" bounds. Because although the child will not be painted outside the 
// parent, but the offset will still be updated.🚨🚨🚨
final currentOffsetBuilder =
_controller.popupPositionController!.offsetBuilder;
_controller.popupPositionController!.offsetBuilder =
(Size contentSize) {
return (currentOffsetBuilder.call(contentSize) +
d.delta);
};
},
onTap: () {
setState(() {
if (_likes > 8) {
_likes = double.infinity;
return;
}
_likes++; // to update the normal widgets
});
state(
() {}); // to update the popup, because it is on the overlay (different context)
},
child: _card(),
),
);
},
offsetBuilder: (size) => const Offset(500, 10),
transitionBuilder: (child, animation) => ScaleTransition(
scale: animation,
child: child,
),
canGoOffScreen: true,
);
```

- Custom Animated Widget:
```dart
              final CustomAnimatedWidgetController _controller = CustomAnimatedWidgetController();
CustomAnimatedWidget(
child: Container(
color: Colors.amber,
child: const Text('I am Controllable Animated widget',
style: TextStyle(fontSize: 50)),
),
controller: _controller,
initiallyAnimating: true,
transitionCurve: Curves.easeInOutBack,
reverseTransitionCurve: Curves.easeInOutBack,
transitionDuration: const Duration(milliseconds: 1000),
reverseTransitionDuration: const Duration(milliseconds: 1000),
transitionBuilder: (child, animation) {
// child is the above container
// return any transition here, your widget will be wrapped with it
return ScaleTransition(
scale: animation,
child: child,
);
},
)
```

- Custom Positioned Widget:
  See the example in the [github repo](https://github.com/Haidar0096/controllable_widgets/blob/master/example/lib/custom_positioned_widget.dart) for a complete working showcase example.

See examples in the [github repo](https://github.com/Haidar0096/controllable_widgets/tree/master/example) for full working example apps.

## Notes

- This is the first release of the package, any suggestions or bug reports are welcomed in the issues section in the github repo 😃.

## Additional information

You are welcome to contribute to the package. Just add a PR with the feature or fix you think will add value to the package.
