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
  final PopupController _controller = PopupController();

  final Size _cardSize = const Size(500, 300);

  double _likes = 0;

  @override
  void dispose() {
    _controller.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            width: 300,
            child: _controlPanel(),
          ),
          Positioned(
            left: 300,
            top: 10,
            child: _details(),
          )
        ],
      ),
    );
  }

  Widget _details() {
    return Text('${_likes.toStringAsFixed(0)} Likes !!',
        style: const TextStyle(fontSize: 50));
  }

  Column _controlPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('create popup'),
            onPressed: () {
              _controller.create(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, state) => GestureDetector(
                      onPanUpdate: (d) {
                        // 🚨🚨🚨 be careful here, if you set the child of the positioned widget to be bounded, then you must update the offset such that
                        // you discard updated offsets that are outside the "container" bounds.🚨🚨🚨
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
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('dismiss popup'),
            onPressed: () {
              _controller.dismiss();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('forward animation'),
            onPressed: () {
              _controller.popupAnimationController?.forward();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('reverse animation'),
            onPressed: () {
              _controller.popupAnimationController?.reverse();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('force stay inside parent'),
            onPressed: () {
              _controller.popupPositionController?.canGoOffParentBounds = false;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('don\'t force stay inside parent'),
            onPressed: () {
              _controller.popupPositionController?.canGoOffParentBounds = true;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: const Text('navigate'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Scaffold(appBar: AppBar())));
            },
          ),
        ),
      ],
    );
  }

  Widget _card() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 200,
        shadowColor: Colors.pink,
        child: SizedBox(
          width: 500,
          height: 300,
          child: Column(
            children: [
              Expanded(
                flex: 30,
                child: RichText(
                  text:
                      TextSpan(style: const TextStyle(fontSize: 20), children: [
                    const TextSpan(text: 'Name:\t'),
                    const TextSpan(
                        text: 'Dash', style: TextStyle(color: Colors.yellow)),
                    const TextSpan(text: '\nAddress:\t'),
                    const TextSpan(
                        text: 'My Heart',
                        style: TextStyle(color: Colors.yellow)),
                    const TextSpan(text: '\nLikes:\t'),
                    TextSpan(
                        text: _likes.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.yellow)),
                  ]),
                ),
              ),
              Expanded(
                flex: 80,
                child: FlutterLogo(size: _cardSize.longestSide),
              ),
            ],
          ),
        ),
        color: Colors.pinkAccent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(100))),
      ),
    );
  }
}
