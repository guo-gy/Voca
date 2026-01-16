import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/main.dart';

void main() {
  testWidgets('VocaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaApp());
    expect(find.text('Voca 语刻'), findsOneWidget);
  });
}
