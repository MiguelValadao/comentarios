import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/publicacao.dart';
import '../services/auth_service.dart';
import '../services/publicacao_service.dart';
import '../utils/formatar_data.dart';
import 'detalhe_publicacao_page.dart';
import 'nova_publicacao_page.dart';
import 'perfil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = PublicacaoService();

  Future<void> _excluir(Publicacao publicacao) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir publicação'),
        content: const Text('Deseja realmente excluir esta publicação?'),
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
      await _service.excluir(publicacao.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários em Tempo Real'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerfilPage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Publicacao>>(
        stream: _service.listar(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar publicações: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final publicacoes = snapshot.data!;
          if (publicacoes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma publicação ainda.\nToque em + para criar a primeira!',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: publicacoes.length,
            itemBuilder: (context, index) {
              final publicacao = publicacoes[index];
              final proprio =
                  publicacao.uidAutor == auth.usuario?.uid;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                          if (proprio)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Excluir',
                              onPressed: () => _excluir(publicacao),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(publicacao.texto),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalhePublicacaoPage(
                                publicacao: publicacao,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Comentários'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NovaPublicacaoPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
