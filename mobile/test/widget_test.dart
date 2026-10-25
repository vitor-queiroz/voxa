import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('VoxaApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const VoxaApp());

    expect(find.byType(VoxaApp), findsOneWidget);
  });
}
