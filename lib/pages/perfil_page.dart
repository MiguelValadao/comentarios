import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _nomeController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = context.read<AuthService>().nome;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite seu nome')),
      );
      return;
    }
    setState(() => _carregando = true);
    final auth = context.read<AuthService>();
    final erro = await auth.atualizarNome(nome);
    if (!mounted) return;
    setState(() => _carregando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro ?? 'Nome atualizado com sucesso!'),
        backgroundColor: erro == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _sair() async {
    await context.read<AuthService>().sair();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              auth.usuario?.email ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _carregando ? null : _salvar,
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _sair,
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
