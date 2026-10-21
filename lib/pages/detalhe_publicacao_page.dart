import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comentario.dart';
import '../models/publicacao.dart';
import '../services/auth_service.dart';
import '../services/comentario_service.dart';
import '../utils/formatar_data.dart';

class DetalhePublicacaoPage extends StatefulWidget {
  final Publicacao publicacao;

  const DetalhePublicacaoPage({super.key, required this.publicacao});

  @override
  State<DetalhePublicacaoPage> createState() => _DetalhePublicacaoPageState();
}

class _DetalhePublicacaoPageState extends State<DetalhePublicacaoPage> {
  final _comentarioService = ComentarioService();
  final _controller = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    final auth = context.read<AuthService>();
    final usuario = auth.usuario;
    if (usuario == null) return;
    setState(() => _enviando = true);
    try {
      await _comentarioService.enviar(
        texto: texto,
        nome: auth.nome,
        uid: usuario.uid,
        publicacaoId: widget.publicacao.id,
      );
      _controller.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar comentário.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  Future<void> _excluir(Comentario comentario) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir comentário'),
        content: const Text('Deseja realmente excluir este comentário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await _comentarioService.excluir(comentario.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final publicacao = widget.publicacao;
    return Scaffold(
      appBar: AppBar(title: const Text('Discussão')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(
                            publicacao.nomeAutor.isNotEmpty
                                ? publicacao.nomeAutor[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                publicacao.nomeAutor,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatarData(publicacao.data),
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(publicacao.texto),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Comentario>>(
              stream: _comentarioService
                  .listarPorPublicacao(publicacao.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Erro ao carregar comentários: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comentarios = snapshot.data!;
                if (comentarios.isEmpty) {
                  return const Center(
                    child: Text('Seja o primeiro a comentar!'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final comentario = comentarios[index];
                    final proprio = comentario.uid == auth.usuario?.uid;
                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                            comentario.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatarData(comentario.data),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      subtitle: Text(comentario.texto),
                      trailing: proprio
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Excluir comentário',
                              onPressed: () => _excluir(comentario),
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviar(),
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
