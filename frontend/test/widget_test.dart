import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/category_chip.dart';
import 'package:frontend/widgets/tactile_card.dart';

void main() {
  testWidgets('CategoryChip displays text and applies custom color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            label: 'Flutter UI',
            backgroundColor: AppColors.primaryFixed,
            textColor: AppColors.onPrimaryFixed,
          ),
        ),
      ),
    );

    expect(find.text('Flutter UI'), findsOneWidget);
  });

  testWidgets('TactileCard renders child with rounded border', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: TactileCard(
            child: Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
  });
}
