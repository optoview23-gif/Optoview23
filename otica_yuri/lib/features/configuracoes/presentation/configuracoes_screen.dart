import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';

class ConfiguracoesScreen extends ConsumerWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(user?.email),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Loja',
            children: [
              const _InfoTile(
                icon: Icons.store_outlined,
                title: 'Nome',
                subtitle: 'Ótica Yuri',
              ),
              const _InfoTile(
                icon: Icons.location_on_outlined,
                title: 'Endereço',
                subtitle: 'Configure no sistema',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Conta',
            children: [
              _InfoTile(
                icon: Icons.email_outlined,
                title: 'E-mail',
                subtitle: user?.email ?? '–',
              ),
              _ActionTile(
                icon: Icons.lock_outline,
                title: 'Alterar senha',
                onTap: () => _confirmarResetSenha(context, ref, user?.email),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Sobre',
            children: [
              const _InfoTile(
                icon: Icons.info_outline,
                title: 'Versão do app',
                subtitle: '1.0.0',
              ),
              const _InfoTile(
                icon: Icons.business_outlined,
                title: 'Desenvolvido por',
                subtitle: 'OptoView23',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sair da conta',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmarSaida(context, ref),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String? email) {
    return Container(
      width: double.infinity,
      color: AppColors.secondary,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person_outline,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('Administrador',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email ?? '',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8)),
          ),
          Card(
            child: Column(
              children: children
                  .expand((w) => [
                        w,
                        if (w != children.last)
                          const Divider(height: 1, indent: 52),
                      ])
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sair',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmarResetSenha(
      BuildContext context, WidgetRef ref, String? email) {
    if (email == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar senha'),
        content: Text('Enviar e-mail de redefinição para $email?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(authRepositoryProvider)
                  .sendPasswordResetEmail(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('E-mail de redefinição enviado')));
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
