```dart
import 'package:controllable_widgets/controllable_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CustomAnimatedWidgetController _controller =
      CustomAnimatedWidgetController();

  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (visible)
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
              ),
            _button(
              'animation forward',
              () => _controller.animationController!.forward(),
            ),
            _button(
              'animation reverse',
              () => _controller.animationController!.reverse(),
            ),
            _button(
              'animation repeat',
              () => _controller.animationController!.repeat(reverse: true),
            ),
            _button(
              'animation stop',
              () => _controller.animationController!.stop(),
            ),
            _button(
              'animation reset',
              () => _controller.animationController!.reset(),
            ),
            _button(
              'Add/Remove Widget from tree',
              () => setState(() => visible = !visible),
            ),
          ],
        ),
      ),
    );
  }

  Padding _button(String text, VoidCallback action) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: action,
        child: Text(text),
      ),
    );
  }
}

```