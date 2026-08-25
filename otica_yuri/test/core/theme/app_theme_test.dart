import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';
import 'package:otica_yuri/core/constants/app_colors.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AppTheme.light tem cor primária correta', (WidgetTester tester) async {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary);
  });

  testWidgets('AppTheme.light tem cor secundária correta', (WidgetTester tester) async {
    final theme = AppTheme.light;
    expect(theme.colorScheme.secondary, AppColors.secondary);
  });
}
