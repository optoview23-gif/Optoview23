// test/shared/widgets/app_drawer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otica_yuri/shared/widgets/app_drawer.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';

void main() {
  testWidgets('Drawer instancia sem erro', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(builder: (ctx) => const AppDrawer(location: '/inicio')),
      ),
    ));
    expect(find.byType(AppDrawer), findsOneWidget);
  });
}
