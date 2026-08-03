// test/features/auth/login_screen_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otica_yuri/features/auth/data/auth_repository.dart';
import 'package:otica_yuri/features/auth/presentation/login_screen.dart';
import 'package:otica_yuri/core/theme/app_theme.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> signIn(String email, String password) async {
    throw Exception('FakeAuthRepository: signIn not implemented');
  }

  @override
  Future<void> signOut() async {
    throw Exception('FakeAuthRepository: signOut not implemented');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw Exception(
        'FakeAuthRepository: sendPasswordResetEmail not implemented');
  }

  @override
  User? get currentUser => null;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();
}

Widget buildLoginScreen() => ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );

void main() {
  testWidgets('Exibe campos de e-mail e senha', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('Mostra erro se e-mail inválido ao submeter', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
  });

  testWidgets('Mostra erro se senha curta ao submeter', (tester) async {
    await tester.pumpWidget(buildLoginScreen());
    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Senha deve ter pelo menos 6 caracteres'), findsOneWidget);
  });
}
