import 'package:flutter/material.dart';
import '../services/dados.dart';

/// Tela Início: versículo do dia.
/// O dia do ano escolhe o versículo da lista (de prova, por enquanto).
/// Tocar no versículo abre o capítulo inteiro na tela Bíblia (Fase 2).
class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Dados.versiculosDoDia(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return const Center(child: Text('Não foi possível carregar o versículo do dia.'));
        }
        final dados = snap.data!;
        final lista = dados['versiculos'] as List<dynamic>;
        final v = Dados.versiculoDoDia(lista, DateTime.now());
        final ehProva = dados['lista'] == 'prova';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Versículo do dia — ${v['dia_da_semana']}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(v['tema']),
                avatar: const Icon(Icons.label, size: 18),
              ),
              const SizedBox(height: 24),
              Text(
                '“${v['texto_arc']}”',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                v['referencia'],
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (ehProva)
                const Card(
                  color: Colors.amberAccent,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'LISTA DE PROVA — a versão final dos versículos será definida pelo Edson, versículo por versículo.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
