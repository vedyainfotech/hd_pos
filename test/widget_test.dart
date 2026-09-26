import 'package:flutter_test/flutter_test.dart';
import 'package:hd_pos/main.dart';

void main() {
  testWidgets('Settings page displays correctly', (WidgetTester tester) async {
    // Build the Home Delivery POS app.
    await tester.pumpWidget(const HDPosApp());

    // Main heading
    expect(find.text('Settings'), findsWidgets);

    // Settings items
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Subcategory'), findsOneWidget);
    expect(find.text('Item'), findsOneWidget);

    // Inventory Settings
    expect(find.text('Inventory Settings'), findsOneWidget);

    // Inventory items
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
  });
}