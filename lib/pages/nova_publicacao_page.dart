import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/publicacao_service.dart';

class NovaPublicacaoPage extends StatefulWidget {
  const NovaPublicacaoPage({super.key});

  @override
  State<NovaPublicacaoPage> createState() => _NovaPublicacaoPageState();
}

class _NovaPublicacaoPageState extends State<NovaPublicacaoPage> {
  final _controller = TextEditingController();
  final _service = PublicacaoService();
  String _erro = '';
  bool _carregando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Digite o texto da publicação');
      return;
    }
    final auth = context.read<AuthService>();
    final usuario = auth.usuario;
    if (usuario == null) return;
    setState(() {
      _erro = '';
      _carregando = true;
    });
    try {
      await _service.criar(
        texto: texto,
        nomeAutor: auth.nome,
        uidAutor: usuario.uid,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erro = 'Erro ao publicar. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova publicação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'O que você quer compartilhar?',
                border: OutlineInputBorder(),
              ),
            ),
            if (_erro.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _erro,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _carregando ? null : _publicar,
              child: _carregando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
