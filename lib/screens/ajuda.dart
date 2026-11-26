import 'package:flutter/material.dart';
import '../services/dados.dart';

/// Tela Ajuda: botões por tema; cada ficha tem acolhimento, versículo,
/// palavra curta, oração breve e próximo passo.
/// Fase 1: fichas em RASCUNHO, aguardando aprovação/correção do Edson.
class TelaAjuda extends StatelessWidget {
  const TelaAjuda({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Dados.fichasAjuda(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return const Center(child: Text('Não foi possível carregar as fichas de ajuda.'));
        }
        final fichas = snap.data!['fichas_lista'] as List<dynamic>;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              color: Colors.amberAccent,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'RASCUNHO — as fichas estão em revisão pelo Edson. O aplicativo apoia, não substitui o acompanhamento de um pastor, de um profissional de saúde ou de pessoas próximas.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final f in fichas)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(f['tema']),
                  subtitle: Text(f['referencia']),
                  onTap: () => _abrirFicha(context, f),
                ),
              ),
          ],
        );
      },
    );
  }

  void _abrirFicha(BuildContext context, Map<String, dynamic> f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(f['tema']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f['acolhimento']),
              const SizedBox(height: 12),
              Text(
                '“${f['versiculo_arc']}” (${f['referencia']})',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Text(f['palavra_curta']),
              const SizedBox(height: 12),
              Text('Oração: ${f['oracao']}'),
              const SizedBox(height: 12),
              Text('Próximo passo: ${f['proximo_passo']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
