import 'package:controllable_widgets/src/custom_positioned_widget/custom_positioned_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomPositionedWidget', () {
    testWidgets('The widget is placed according to the correct default values.',
        (WidgetTester tester) async {
      final GlobalKey<CustomPositionedWidgetState> key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPositionedWidget(
              key: key,
              controller: CustomPositionedWidgetController(),
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      // widget is placed correctly
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(0, 0));

      // the offset builder returns Offset.zero
      expect(key.currentState!.widget.controller.offsetBuilder.call(Size.zero),
          Offset.zero);
      expect(
          key.currentState!.widget.controller.offsetBuilder.call(Size.infinite),
          Offset.zero);
      expect(
          key.currentState!.widget.controller.offsetBuilder
              .call(const Size(100, 100)),
          Offset.zero);

      // padding
      expect(key.currentState!.widget.controller.padding,
          const EdgeInsets.all(0.0));

      // bounded = true
      expect(key.currentState!.widget.controller.canGoOffParentBounds, true);
    });
    testWidgets('Can create widget with custom controller values.',
        (WidgetTester tester) async {
      Future<void> createWidget(bool bounded) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPositionedWidget(
                controller: CustomPositionedWidgetController(
                    canGoOffParentBounds: bounded,
                    padding: const EdgeInsets.all(10),
                    offsetBuilder: (Size size) {
                      return Offset(
                          size.width / 2, size.height / 2); // Offset(5,5)
                    }),
                child: const SizedBox(width: 10, height: 10),
              ),
            ),
          ),
        );
      }

      // create the the widget
      await createWidget(false);

      // widget is placed correctly, it is bounded
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(10, 10));

      // create the same widget but allow it to go off bounds
      await createWidget(true);

      // widget is placed correctly
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(5, 5));
    });
    testWidgets('Widget\'s container and child size tests.',
        (WidgetTester tester) async {
      // parent forces constrains, size is not set
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPositionedWidget(
              controller: CustomPositionedWidgetController(),
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );
      final Size parentSize1 = tester.getSize(find.byType(Scaffold));
      final Size positionedSize1 =
          tester.getSize(find.byType(CustomPositionedWidget));
      final Size childSize1 = tester.getSize(find.byType(SizedBox));

      // expands to fill parent by default
      expect(parentSize1, const Size(800, 600));
      expect(parentSize1, positionedSize1);
      expect(childSize1, const Size(10, 10));

      // parent forces constrains, size is set and less than parent's size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPositionedWidget(
              maxSize: const Size(400, 400),
              controller: CustomPositionedWidgetController(),
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );
      final Size parentSize2 = tester.getSize(find.byType(Scaffold));
      final Size positionedSize2 =
          tester.getSize(find.byType(CustomPositionedWidget));
      final Size childSize2 = tester.getSize(find.byType(SizedBox));

      // expands to fill parent
      expect(parentSize2, const Size(800, 600));
      expect(parentSize2, positionedSize2);
      expect(childSize2, const Size(10, 10));

      // parent forces constrains, size is set and larger than parent's size
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPositionedWidget(
              maxSize: const Size(1000, 1000),
              controller: CustomPositionedWidgetController(),
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );
      final Size parentSize3 = tester.getSize(find.byType(Scaffold));
      final Size positionedSize3 =
          tester.getSize(find.byType(CustomPositionedWidget));
      final Size childSize3 = tester.getSize(find.byType(SizedBox));

      // expands to fill parent
      expect(parentSize3, const Size(800, 600));
      expect(parentSize3, positionedSize3);
      expect(childSize3, const Size(10, 10));

      // parent does not force constraints, size is set
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 50,
                  top: 50,
                  child: CustomPositionedWidget(
                    maxSize: const Size(400, 400),
                    controller: CustomPositionedWidgetController(),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final Size parentSize4 = tester.getSize(find.byType(Positioned));
      final Size positionedSize4 =
          tester.getSize(find.byType(CustomPositionedWidget));
      final Size childSize4 = tester.getSize(find.byType(SizedBox));

      // size of the app
      expect(tester.getSize(find.byType(Scaffold)), const Size(800, 600));
      // expands to fill parent
      expect(parentSize4, const Size(400, 400));
      expect(positionedSize4, const Size(400, 400));
      expect(childSize4, const Size(10, 10));
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(50, 50));

      // parent does not force constraints, size is not set
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 50,
                  top: 50,
                  child: CustomPositionedWidget(
                    controller: CustomPositionedWidgetController(),
                    child: const SizedBox(width: 10, height: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final Size parentSize5 = tester.getSize(find.byType(Positioned));
      final Size positionedSize5 =
          tester.getSize(find.byType(CustomPositionedWidget));
      final Size childSize5 = tester.getSize(find.byType(SizedBox));

      // size of the app
      expect(tester.getSize(find.byType(Scaffold)), const Size(800, 600));
      // expands to fill parent
      final BuildContext context = tester.element(find.byType(Scaffold));
      expect(MediaQuery.of(context).size, const Size(800, 600));
      expect(parentSize5, const Size(800, 600));
      expect(positionedSize5, const Size(800, 600));
      expect(childSize5, const Size(10, 10));
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(50, 50));
    });

    testWidgets('Can change the widget properties using the controller.',
        (WidgetTester tester) async {
      final CustomPositionedWidgetController controller =
          CustomPositionedWidgetController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPositionedWidget(
              controller: controller,
              child: const SizedBox(width: 10, height: 20),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(0, 0));

      // offset
      controller.offsetBuilder =
          (Size size) => Offset(size.width + 100, size.height + 100);
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(110, 120));

      // padding
      controller.canGoOffParentBounds = false; // to make it respect padding
      controller.padding = const EdgeInsets.all(10);
      controller.offsetBuilder = (Size size) => const Offset(0, 0);
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(10, 10));

      // canGoOffParentBounds
      controller.canGoOffParentBounds = true;
      controller.offsetBuilder = (Size size) => const Offset(0, 0);
      await tester.pumpAndSettle();

      // padding is still 10, but should be ignored
      expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(0, 0));
    });
  });
}
