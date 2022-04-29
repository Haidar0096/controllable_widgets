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
      final GlobalKey<CustomAnimatedWidgetState> key = GlobalKey();

      late final AnimationController controller;

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              key: key,
              child: Container(),
              controller: CustomAnimatedWidgetController(),
            ),
          ),
        ),
      );

      controller = key.currentState!.animationController;

      // force dispose the widget
      await tester.pumpWidget(const MaterialApp());

      expect(key.currentState, null);
      expect(() => controller.forward(), throwsAssertionError);
    });
    testWidgets(
        'Should register the animationController when attached to a CustomAnimatedWidget.',
        (WidgetTester tester) async {
      final GlobalKey<CustomAnimatedWidgetState> key = GlobalKey();

      final CustomAnimatedWidgetController customAnimatedWidgetController =
          CustomAnimatedWidgetController();

      late final AnimationController animationController;

      // create the app
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              key: key,
              child: Container(),
              controller: customAnimatedWidgetController,
            ),
          ),
        ),
      );

      animationController = key.currentState!.animationController;

      expect(customAnimatedWidgetController.animationController,
          animationController);
    });
  });

  group('CustomAnimatedWidgetController', () {
    testWidgets('Must not be used with more than one widget.',
        (WidgetTester tester) async {
      final CustomAnimatedWidgetController controller =
          CustomAnimatedWidgetController();

      const String expectedErrorMessage =
          'The CustomAnimatedWidgetController must only be used with one widget. Use a new controller if you want to control another widget.';
      String? errorMessage;

      FlutterError.onError = (FlutterErrorDetails details){
        if(details.exceptionAsString().contains(expectedErrorMessage)){
          errorMessage = expectedErrorMessage;
        }
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              CustomAnimatedWidget(
                child: Container(),
                controller: controller,
              ),
              CustomAnimatedWidget(
                child: Container(),
                controller: controller,
              ),
            ],
          ),
        ),
      );

      expect(errorMessage,expectedErrorMessage);

    });
    testWidgets('Must return the correct animationController',
        (WidgetTester tester) async {
      // when the controller is attached to a widget in the tree
      final CustomAnimatedWidgetController controller =
          CustomAnimatedWidgetController();

      final GlobalKey<CustomAnimatedWidgetState> key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedWidget(
              key: key,
              child: Container(),
              controller: controller,
            ),
          ),
        ),
      );

      expect(key.currentState!.animationController,
          controller.animationController!);

      // wait for animations to finish
      await tester.pumpAndSettle();

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
