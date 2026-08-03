// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';

// Temporary placeholder until Task 7 creates MainScaffold and PlaceholderScreen
class _TempPlaceholder extends StatelessWidget {
  final String title;
  const _TempPlaceholder({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title)),
      );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/inicio',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/esqueci-senha';

      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && state.matchedLocation == '/login') return '/inicio';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/esqueci-senha',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/inicio',
            builder: (_, __) => const _TempPlaceholder(title: 'Início'),
          ),
          GoRoute(
            path: '/clientes',
            builder: (_, __) => const _TempPlaceholder(title: 'Clientes'),
          ),
          GoRoute(
            path: '/prontuario',
            builder: (_, __) => const _TempPlaceholder(title: 'Prontuário'),
          ),
          GoRoute(
            path: '/pedidos',
            builder: (_, __) => const _TempPlaceholder(title: 'Pedidos'),
          ),
          GoRoute(
            path: '/estoque',
            builder: (_, __) => const _TempPlaceholder(title: 'Estoque'),
          ),
          GoRoute(
            path: '/caixa',
            builder: (_, __) => const _TempPlaceholder(title: 'Caixa'),
          ),
          GoRoute(
            path: '/agenda',
            builder: (_, __) => const _TempPlaceholder(title: 'Agenda'),
          ),
          GoRoute(
            path: '/configuracoes',
            builder: (_, __) =>
                const _TempPlaceholder(title: 'Configurações'),
          ),
        ],
      ),
    ],
  );
});
