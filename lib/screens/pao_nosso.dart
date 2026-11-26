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
  void initState() {
    super.initState();
    _tts.setErrorHandler((_) {
      // A fala falhou (no Chrome web aparece SpeechSynthesisErrorEvent).
      if (!mounted) return;
      _mostrarErroVoz();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Escolhe uma voz em português (de preferência pt-BR) antes de falar.
  /// No Chrome web a fala pode falhar sem uma voz explícita; sem voz em
  /// pt disponível, segue com a voz padrão do sistema.
  Future<void> _prepararVoz() async {
    try {
      final vozes = await _tts.getVoices;
      Map<String, String>? escolhida;
      for (final voz in vozes) {
        final mapa = voz as Map;
        final nome = (mapa['name'] as String?) ?? '';
        final locale = (mapa['locale'] as String?) ?? '';
        if (nome.isEmpty) continue;
        if (locale.startsWith('pt-BR')) {
          escolhida = {'name': nome, 'locale': locale};
          break;
        }
        if (escolhida == null && locale.startsWith('pt')) {
          escolhida = {'name': nome, 'locale': locale};
        }
      }
      if (escolhida != null) {
        await _tts.setVoice(escolhida);
      }
    } catch (_) {
      // Sem lista de vozes: segue com a voz padrão.
    }
  }

  void _mostrarErroVoz() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Não foi possível ler em voz alta neste navegador.'),
        ),
      );
  }

  Future<void> _ouvir(String texto, String idioma) async {
    await _tts.setLanguage(idioma);
    await _tts.setSpeechRate(0.9);
    setState(() => _lendo = true);
    try {
      await _prepararVoz();
      final resultado = await _tts.speak(texto);
      if (mounted) {
        setState(() => _lendo = false);
        if (resultado == 0) _mostrarErroVoz();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _lendo = false);
        _mostrarErroVoz();
      }
    }
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
