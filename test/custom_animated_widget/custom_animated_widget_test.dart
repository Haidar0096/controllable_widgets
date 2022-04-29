import 'package:controllable_widgets/src/custom_animated_widget/custom_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomAnimatedWidget', () {
    testWidgets(
        'Should animate when inserted to a tree if initiallyAnimating is not provided.',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: CustomAnimatedWidgetController(),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 33));

      expect(
          tester
              .widget<ScaleTransition>(find.byType(ScaleTransition).first)
              .scale
              .value,
          0.33);

      await tester.pumpAndSettle();

      expect(
          tester
              .widget<ScaleTransition>(find.byType(ScaleTransition).first)
              .scale
              .value,
          1);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets(
        'Should not animate when inserted into a tree if initiallyAnimating is false.',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: CustomAnimatedWidgetController(),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 100),
              initiallyAnimating: false,
            ),
          ),
        ),
      );

      expect(
          tester
              .widget<ScaleTransition>(find.byType(ScaleTransition).first)
              .scale
              .value,
          1);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('Can control a custom animated widget with the controller.',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController controller =
          CustomAnimatedWidgetController();

      const ValueKey key = ValueKey('transition');

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: controller,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                    key: key, scale: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 100),
              reverseTransitionDuration: const Duration(milliseconds: 100),
              transitionCurve: Curves.linear,
              reverseTransitionCurve: Curves.linear,
            ),
          ),
        ),
      );

      // animation goes forward by default
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 33));

      expect(
        tester.widget<ScaleTransition>(find.byKey(key)).scale.value,
        0.33,
      );

      // finish the animation
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsOneWidget);
      expect(
        tester.widget<ScaleTransition>(find.byKey(key)).scale.value,
        1,
      );

      // animation reverse using the controller
      controller.animationController!.reverse();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 33));

      expect(
          tester
              .widget<ScaleTransition>(find.byKey(key))
              .scale
              .value
              .toStringAsFixed(2),
          '0.67');

      // finish the animation
      await tester.pumpAndSettle();

      expect(tester.widget<ScaleTransition>(find.byKey(key)).scale.value, 0);
      expect(find.byType(Container), findsOneWidget);

      // animation forward using the controller
      controller.animationController!.forward();

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 47));

      expect(tester.widget<ScaleTransition>(find.byKey(key)).scale.value, 0.47);

      // finish the animation
      await tester.pumpAndSettle();
      expect(tester.widget<ScaleTransition>(find.byKey(key)).scale.value, 1);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('Widget should dispose the animationController',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController customAnimatedWidgetController =
          CustomAnimatedWidgetController();

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: customAnimatedWidgetController,
            ),
          ),
        ),
      );

      // hold a reference to the animationController so that garbage collector does not collect it later
      final AnimationController controller =
          customAnimatedWidgetController.animationController!;

      // force dispose the widget
      await tester.pumpWidget(const MaterialApp());

      expect(() => controller.forward(), throwsAssertionError);
    });

    testWidgets(
        'Should register the animationController when attached to a CustomAnimatedWidget.',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController customAnimatedWidgetController =
          CustomAnimatedWidgetController();

      expect(customAnimatedWidgetController.animationController, isNull);

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: customAnimatedWidgetController,
            ),
          ),
        ),
      );

      expect(customAnimatedWidgetController.animationController, isNotNull);
    });

    testWidgets(
        'Can not use the same controller with more than one widget at same time.',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController customAnimatedWidgetController =
          CustomAnimatedWidgetController();

      expect(customAnimatedWidgetController.animationController, isNull);

      const String errorMessage =
          'A GlobalKey can only be specified on one widget at a time in the widget tree.';
      String? expectedMessage;

      final currentHandler = FlutterError.onError;

      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exceptionAsString().contains(errorMessage)) {
          expectedMessage = errorMessage;
        }
      };

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomAnimatedWidget(
                  child: Container(),
                  controller: customAnimatedWidgetController,
                ),
                CustomAnimatedWidget(
                  child: Container(),
                  controller: customAnimatedWidgetController,
                ),
              ],
            ),
          ),
        ),
      );

      FlutterError.onError = currentHandler;
      expect(errorMessage, expectedMessage);
    });

    testWidgets(
        'Using the same controller on another widget does not control that widget.',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController customAnimatedWidgetController =
          CustomAnimatedWidgetController();

      expect(customAnimatedWidgetController.animationController, isNull);

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: customAnimatedWidgetController,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(customAnimatedWidgetController.animationController!.value, 1);

      // create another widget with same controller
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: customAnimatedWidgetController,
              transitionDuration: const Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 30));

      // animationController's value doesn't change because the new widget is not registered with this controller
      expect(customAnimatedWidgetController.animationController!.value, 1);
    });

    testWidgets('Must set animationController correctly',
        (WidgetTester tester) async {
      // when the controller is attached to a widget in the tree
      final CustomAnimatedWidgetController controller =
          CustomAnimatedWidgetController();

      expect(controller.animationController, isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              child: Container(),
              controller: controller,
              transitionDuration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
            ),
          ),
        ),
      );

      final AnimationController animationController1 =
          controller.animationController!;

      // make sure the controller is animating
      await tester.pump(const Duration(milliseconds: 33));

      expect(animationController1.value, 0.33);

      // wait for animations to finish
      await tester.pumpAndSettle();

      expect(animationController1.value, 1.0);

      // when the controller is not attached to a widget
      final CustomAnimatedWidgetController controller2 =
          CustomAnimatedWidgetController();

      expect(controller2.animationController, null);

      // when the controller is attached to a widget not in the widget tree
      final CustomAnimatedWidgetController controller3 =
          CustomAnimatedWidgetController();

      CustomAnimatedWidget(
        child: Container(),
        controller: controller3,
      );

      expect(controller3.animationController, null);
    });
  });
}
