import 'package:controllable_widgets/controllable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PopupController', () {
    testWidgets('Can create and dismiss the popup',
        (WidgetTester tester) async {
      final PopupController controller = PopupController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Column(
                children: [
                  InkWell(
                    child: const Icon(Icons.add),
                    onTap: () {
                      controller.create(
                        context: context,
                        builder: (BuildContext context) => const Text('hi'),
                        offsetBuilder: (size) => const Offset(300, 300),
                      );
                    },
                  ),
                  InkWell(
                    child: const Icon(Icons.remove),
                    onTap: () {
                      controller.dismiss();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // create
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsOneWidget);
      expect(tester.getTopLeft(find.byType(Text)), const Offset(300, 300));

      // dismiss
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsNothing);
    });
    testWidgets('Can change offset of the popup', (WidgetTester tester) async {
      final PopupController controller = PopupController();
      const ValueKey key = ValueKey('child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => InkWell(
                child: const Icon(Icons.add),
                onTap: () {
                  controller.create(
                    context: context,
                    builder: (BuildContext context) =>
                        const SizedBox(key: key, width: 13, height: 14),
                    offsetBuilder: (size) => const Offset(300, 300),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      controller.changeOffset((Size contentSize) =>
          Offset(contentSize.width + 10, contentSize.height + 10));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byKey(key)), const Offset(23,24));
    });
  });
}
