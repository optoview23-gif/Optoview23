import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/clientes/data/cliente_model.dart';
import '../../features/clientes/presentation/clientes_screen.dart';
import '../../features/clientes/presentation/cliente_form_screen.dart';
import '../../features/clientes/presentation/cliente_perfil_screen.dart';
import '../../features/prontuario/data/receita_model.dart';
import '../../features/prontuario/presentation/prontuario_screen.dart';
import '../../features/prontuario/presentation/receitas_cliente_screen.dart';
import '../../features/prontuario/presentation/receita_form_screen.dart';
import '../../features/prontuario/presentation/receita_detalhe_screen.dart';
import '../../features/estoque/data/item_estoque_model.dart';
import '../../features/estoque/presentation/estoque_screen.dart';
import '../../features/estoque/presentation/item_estoque_form_screen.dart';
import '../../features/estoque/presentation/item_estoque_detalhe_screen.dart';
import '../../features/pedidos/data/pedido_model.dart';
import '../../features/pedidos/presentation/pedidos_screen.dart';
import '../../features/pedidos/presentation/pedidos_cliente_screen.dart';
import '../../features/pedidos/presentation/pedido_form_screen.dart';
import '../../features/pedidos/presentation/pedido_detalhe_screen.dart';
import '../../features/caixa/data/transacao_model.dart';
import '../../features/caixa/presentation/caixa_screen.dart';
import '../../features/caixa/presentation/transacao_form_screen.dart';
import '../../features/agenda/data/agendamento_model.dart';
import '../../features/agenda/presentation/agenda_screen.dart';
import '../../features/agenda/presentation/agendamento_form_screen.dart';
import '../../features/agenda/presentation/agendamento_detalhe_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/configuracoes/presentation/configuracoes_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

class _AuthNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _sub;
  User? _user;

  _AuthNotifier(Stream<User?> stream) {
    _sub = stream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get currentUser => _user;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authRepositoryProvider).authStateChanges();
  final notifier = _AuthNotifier(authStream);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/inicio',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = notifier.currentUser != null;
      final loc = state.matchedLocation;
      final isOnAuth =
          loc == '/login' || loc == '/esqueci-senha';
      if (!isLoggedIn && !isOnAuth) return '/login';
      if (isLoggedIn && loc == '/login') return '/inicio';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/esqueci-senha',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Clientes (telas cheias, sem drawer) ────────────────────────
      GoRoute(
        path: '/clientes/novo',
        builder: (_, __) => const ClienteFormScreen(),
      ),
      GoRoute(
        path: '/clientes/:id/editar',
        builder: (_, state) => ClienteFormScreen(
            cliente: state.extra as Cliente?),
      ),
      GoRoute(
        path: '/clientes/:id',
        builder: (_, state) => ClientePerfilScreen(
            clienteId: state.pathParameters['id']!),
      ),

      // ── Prontuário (telas cheias, sem drawer) ──────────────────────
      GoRoute(
        path: '/prontuario/:clienteId/nova',
        builder: (_, state) => ReceitaFormScreen(
            clienteId: state.pathParameters['clienteId']!),
      ),
      GoRoute(
        path: '/prontuario/:clienteId/:receitaId/editar',
        builder: (_, state) => ReceitaFormScreen(
          clienteId: state.pathParameters['clienteId']!,
          receita: state.extra as Receita?,
        ),
      ),
      GoRoute(
        path: '/prontuario/:clienteId/:receitaId',
        builder: (_, state) {
          final receita = state.extra as Receita?;
          if (receita == null) {
            return ReceitasClienteScreen(
                clienteId: state.pathParameters['clienteId']!);
          }
          return ReceitaDetalheScreen(
            clienteId: state.pathParameters['clienteId']!,
            receita: receita,
          );
        },
      ),
      GoRoute(
        path: '/prontuario/:clienteId',
        builder: (_, state) => ReceitasClienteScreen(
            clienteId: state.pathParameters['clienteId']!),
      ),

      // ── Estoque (telas cheias, sem drawer) ────────────────────────
      GoRoute(
        path: '/estoque/novo',
        builder: (_, __) => const ItemEstoqueFormScreen(),
      ),
      GoRoute(
        path: '/estoque/:id/editar',
        builder: (_, state) => ItemEstoqueFormScreen(
            item: state.extra as ItemEstoque?),
      ),
      GoRoute(
        path: '/estoque/:id',
        builder: (_, state) => ItemEstoqueDetalheScreen(
            item: state.extra as ItemEstoque),
      ),

      // ── Pedidos por cliente ───────────────────────────────────────
      GoRoute(
        path: '/clientes/:clienteId/pedidos',
        builder: (_, state) => PedidosClienteScreen(
            clienteId: state.pathParameters['clienteId']!),
      ),

      // ── Pedidos (telas cheias, sem drawer) ────────────────────────
      GoRoute(
        path: '/pedidos/novo',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, String?>) {
            return PedidoFormScreen(
              clienteId: extra['clienteId'],
              clienteNome: extra['clienteNome'],
            );
          }
          return const PedidoFormScreen();
        },
      ),
      GoRoute(
        path: '/pedidos/:id/editar',
        builder: (_, state) =>
            PedidoFormScreen(pedido: state.extra as Pedido?),
      ),
      GoRoute(
        path: '/pedidos/:id',
        builder: (_, state) =>
            PedidoDetalheScreen(pedido: state.extra as Pedido),
      ),

      // ── Caixa (telas cheias, sem drawer) ─────────────────────────
      GoRoute(
        path: '/caixa/nova',
        builder: (_, __) => const TransacaoFormScreen(),
      ),
      GoRoute(
        path: '/caixa/:id/editar',
        builder: (_, state) => TransacaoFormScreen(
            transacao: state.extra as Transacao?),
      ),

      // ── Agenda (telas cheias, sem drawer) ─────────────────────────
      GoRoute(
        path: '/agenda/novo',
        builder: (_, state) => AgendamentoFormScreen(
            dataInicial: state.extra as DateTime?),
      ),
      GoRoute(
        path: '/agenda/:id/editar',
        builder: (_, state) => AgendamentoFormScreen(
            agendamento: state.extra as Agendamento?),
      ),
      GoRoute(
        path: '/agenda/:id',
        builder: (_, state) => AgendamentoDetalheScreen(
            agendamento: state.extra as Agendamento),
      ),

      // ── Shell (drawer + AppBar) ────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            MainScaffold(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/inicio',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/clientes',
            builder: (_, __) => const ClientesScreen(),
          ),
          GoRoute(
            path: '/prontuario',
            builder: (_, __) => const ProntuarioScreen(),
          ),
          GoRoute(
            path: '/pedidos',
            builder: (_, __) => const PedidosScreen(),
          ),
          GoRoute(
            path: '/estoque',
            builder: (_, __) => const EstoqueScreen(),
          ),
          GoRoute(
            path: '/caixa',
            builder: (_, __) => const CaixaScreen(),
          ),
          GoRoute(
            path: '/agenda',
            builder: (_, __) => const AgendaScreen(),
          ),
          GoRoute(
            path: '/configuracoes',
            builder: (_, __) => const ConfiguracoesScreen(),
          ),
        ],
      ),
    ],
  );
});
