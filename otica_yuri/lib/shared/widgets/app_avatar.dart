import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? fotoUrl;
  final String nome;
  final double radius;

  const AppAvatar({
    super.key,
    required this.fotoUrl,
    required this.nome,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(fotoUrl!),
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        nome.isNotEmpty ? nome[0].toUpperCase() : '?',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
