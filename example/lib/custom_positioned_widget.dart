import 'package:controllable_widgets/controllable_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final CustomPositionedWidgetController _controller =
      CustomPositionedWidgetController(
    padding: const EdgeInsets.all(10),
    canGoOffParentBounds: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onPanUpdate: (details) {
              // get the current offset builder before we modify it
              // because we want to use it in the new offset builder
              final currentBuilder = _controller.offsetBuilder;

              // create the new offset builder
              _controller.offsetBuilder = (Size containerSize) {
                // the container size will be passed to you in this function
                // you can use it to place your widget
                // return the offset you like for the top left of the container
                // now we will return the current offset + the delta
                // Just be careful if you set canGoOffParentBounds to false, as this will prevent the widget from being painted outside the parent
                // but it WILL NOT prevent the offset from being updated to be outside parent, you should handle this in this case!
                return currentBuilder.call(containerSize) + details.delta;
              };
            },
            child: Container(
              // this container is just to show you the area that the custom positioned widget covers
              color: Colors.teal,
              child: CustomPositionedWidget(
                // you need to use a key here to force a rebuild, otherwise use stateful widget
                key: UniqueKey(),
                // maxSize WILL be used here since the Column above does not force any size constraints
                maxSize: const Size(500, 500),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.amber,
                ),
                controller: _controller,
              ),
            ),
          ),
          _button(
            'limit inside parent',
            () => _controller.canGoOffParentBounds = false,
          ),
          _button(
            'don\'t limit inside parent',
            () => _controller.canGoOffParentBounds = true,
          ),
        ],
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
