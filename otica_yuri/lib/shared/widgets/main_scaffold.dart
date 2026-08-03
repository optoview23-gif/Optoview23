// lib/shared/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'app_drawer.dart';

class MainScaffold extends StatelessWidget {
  final String location;
  final Widget child;
  const MainScaffold({super.key, required this.location, required this.child});

  String _title(String loc) {
    if (loc.startsWith('/clientes')) return 'Clientes';
    if (loc.startsWith('/prontuario')) return 'Prontuário';
    if (loc.startsWith('/pedidos')) return 'Pedidos';
    if (loc.startsWith('/estoque')) return 'Estoque';
    if (loc.startsWith('/caixa')) return 'Caixa';
    if (loc.startsWith('/agenda')) return 'Agenda';
    if (loc.startsWith('/configuracoes')) return 'Configurações';
    return 'Início';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title(location))),
      drawer: AppDrawer(location: location),
      body: child,
    );
  }
}
