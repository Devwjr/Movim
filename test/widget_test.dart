import 'package:flutter_test/flutter_test.dart';
import 'package:mobilevim/app.dart';

void main() {
  testWidgets('MobileVim app should render', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileVimApp());
    expect(find.text('MobileVim'), findsOneWidget);
  });
}
