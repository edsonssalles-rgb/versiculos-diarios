import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/dados.dart';

/// Tela Pão Nosso: a reflexão do dia, escrita pelo Edson.
/// Enquanto as 90 reflexões dele não chegam, a tela mostra o espaço reservado
/// e explica como subir o arquivo. O botão de play lê a reflexão em voz alta
/// com a voz gratuita do sistema do celular (flutter_tts).
class TelaPaoNosso extends StatefulWidget {
  const TelaPaoNosso({super.key});

  @override
  State<TelaPaoNosso> createState() => _TelaPaoNossoState();
}

class _TelaPaoNossoState extends State<TelaPaoNosso> {
  final FlutterTts _tts = FlutterTts();
  bool _lendo = false;

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _ouvir(String texto, String idioma) async {
    await _tts.setLanguage(idioma);
    await _tts.setSpeechRate(0.9);
    setState(() => _lendo = true);
    await _tts.speak(texto);
    setState(() => _lendo = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Dados.paoNosso(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return const Center(child: Text('Não foi possível carregar o Pão Nosso.'));
        }
        final dados = snap.data!;
        final reflexoes = (dados['reflexoes'] as List<dynamic>?) ?? [];
        if (reflexoes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 48),
                SizedBox(height: 16),
                Text(
                  'Pão Nosso — a Palavra do dia',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'As reflexões diárias são escritas pelo Edson. '
                  'O espaço já está pronto: quando ele mandar as 90 reflexões, '
                  'elas aparecem aqui, uma por dia, com botão de ouvir.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        final hoje = DateTime.now();
        final diaDoAno = hoje.difference(DateTime(hoje.year, 1, 1)).inDays + 1;
        final r = reflexoes[(diaDoAno - 1) % reflexoes.length] as Map<String, dynamic>;
        final texto = '${r['titulo']}. ${r['referencia']}. ${r['texto']}';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(r['titulo'], style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(r['referencia'], textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Text(r['texto'], style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _lendo ? null : () => _ouvir(texto, 'pt-BR'),
                icon: const Icon(Icons.play_arrow),
                label: Text(_lendo ? 'Lendo...' : 'Ouvir a reflexão'),
              ),
            ],
          ),
        );
      },
    );
  }
}
