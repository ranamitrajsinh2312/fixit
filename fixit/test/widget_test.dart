import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fixit/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders FixItApp splash screen and transitions', (WidgetTester tester) async {
    await tester.pumpWidget(const FixItApp());
    expect(find.text('FixIt'), findsOneWidget);
    expect(find.text('Home repairs, sorted.'), findsOneWidget);

    // Let the splash screen timer and storage resolution complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify it transitions to Select City Screen
    expect(find.text('Select your city'), findsOneWidget);
  });
}
