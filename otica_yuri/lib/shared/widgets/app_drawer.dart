// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/data/auth_repository.dart';

class AppDrawer extends ConsumerWidget {
  final String location;
  const AppDrawer({super.key, required this.location});

  static const _items = [
    (label: 'Início', icon: Icons.home_outlined, route: '/inicio'),
    (label: 'Clientes', icon: Icons.people_outline, route: '/clientes'),
    (label: 'Prontuário', icon: Icons.visibility_outlined, route: '/prontuario'),
    (label: 'Pedidos', icon: Icons.shopping_bag_outlined, route: '/pedidos'),
    (label: 'Estoque', icon: Icons.inventory_outlined, route: '/estoque'),
    (label: 'Caixa', icon: Icons.attach_money, route: '/caixa'),
    (label: 'Agenda', icon: Icons.calendar_today_outlined, route: '/agenda'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Image.asset(
                'assets/images/logo_otica_yuri.png',
                height: 80,
                color: Colors.white,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.visibility,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._items.map((item) => _DrawerItem(
                        label: item.label,
                        icon: item.icon,
                        route: item.route,
                        selected: location.startsWith(item.route),
                      )),
                  const Divider(color: Colors.white24, height: 32),
                  _DrawerItem(
                    label: 'Configurações',
                    icon: Icons.settings_outlined,
                    route: '/configuracoes',
                    selected: location.startsWith('/configuracoes'),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Sair', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Powered by OptoView',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool selected;
  const _DrawerItem(
      {required this.label,
      required this.icon,
      required this.route,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : Colors.white70),
      title: Text(label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          )),
      selected: selected,
      selectedTileColor: Colors.white12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}
