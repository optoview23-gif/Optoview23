// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/placeholder_screen.dart';

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
        builder: (context, state, child) =>
            MainScaffold(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
              path: '/inicio',
              builder: (_, __) =>
                  const PlaceholderScreen(title: 'Início', icon: Icons.home)),
          GoRoute(
              path: '/clientes',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Clientes', icon: Icons.people)),
          GoRoute(
              path: '/prontuario',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Prontuário', icon: Icons.visibility)),
          GoRoute(
              path: '/pedidos',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Pedidos', icon: Icons.shopping_bag)),
          GoRoute(
              path: '/estoque',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Estoque', icon: Icons.inventory)),
          GoRoute(
              path: '/caixa',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Caixa', icon: Icons.attach_money)),
          GoRoute(
              path: '/agenda',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Agenda', icon: Icons.calendar_today)),
          GoRoute(
              path: '/configuracoes',
              builder: (_, __) => const PlaceholderScreen(
                  title: 'Configurações', icon: Icons.settings)),
        ],
      ),
    ],
  );
});
