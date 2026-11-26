import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/dados.dart';

/// Miniplayer estilo Spotify, fixo no rodapé do app (acima da barra de abas).
///
/// Lê o versículo do dia em voz alta (flutter_tts, pt-BR, velocidade 0.9).
/// Controles: aleatório, anterior, play/pause, próximo, repetir.
/// Anterior/próximo andam um versículo na lista de prova (90 versículos);
/// com o aleatório ligado, o próximo sorteia outro versículo.
///
/// A barra de progresso é ESTIMADA a partir da quantidade de palavras
/// (cerca de 150 palavras por minuto na velocidade 0.9) — nunca é uma
/// posição exata da fala, porque o flutter_tts não informa o progresso.
class Miniplayer extends StatefulWidget {
  const Miniplayer({super.key});

  @override
  State<Miniplayer> createState() => _MiniplayerState();
}

class _MiniplayerState extends State<Miniplayer> {
  final FlutterTts _tts = FlutterTts();
  List<dynamic>? _versiculos;
  int _indice = 0;
  bool _tocando = false;
  bool _aleatorio = false;
  bool _repetir = false;
  Timer? _temporizador;
  Duration _decorrido = Duration.zero;
  Duration _estimado = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('pt-BR');
    _tts.setSpeechRate(0.9);
    _tts.setCompletionHandler(() {
      if (!mounted || !_tocando) return;
      if (_repetir) {
        unawaited(_falarAtual());
      } else {
        unawaited(_proximo());
      }
    });
    _carregar();
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _carregar() async {
    final dados = await Dados.versiculosDoDia();
    if (!mounted) return;
    final lista = dados['versiculos'] as List<dynamic>;
    final hoje = Dados.versiculoDoDia(lista, DateTime.now());
    setState(() {
      _versiculos = lista;
      _indice = lista.indexOf(hoje);
      if (_indice < 0) _indice = 0;
    });
  }

  Map<String, dynamic>? get _atual {
    if (_versiculos == null || _versiculos!.isEmpty) return null;
    return _versiculos![_indice] as Map<String, dynamic>;
  }

  /// Duração estimada da fala: ~150 palavras por minuto na velocidade 0.9.
  Duration _estimarDuracao(String texto) {
    final palavras = texto.trim().split(RegExp(r'\s+')).length;
    final segundos = palavras / 2.5; // 150 palavras por minuto
    return Duration(milliseconds: (segundos * 1000).round());
  }

  Future<void> _falarAtual() async {
    final v = _atual;
    if (v == null) return;
    final texto = '${v['referencia']}. ${v['texto_arc']}';
    _estimado = _estimarDuracao(texto);
    _decorrido = Duration.zero;
    _iniciarTemporizador();
    setState(() => _tocando = true);
    await _tts.speak(texto);
  }

  void _iniciarTemporizador() {
    _temporizador?.cancel();
    _temporizador = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || !_tocando) return;
      setState(() {
        _decorrido += const Duration(milliseconds: 500);
        if (_decorrido >= _estimado) _decorrido = _estimado;
      });
    });
  }

  Future<void> _parar() async {
    _temporizador?.cancel();
    await _tts.stop();
    if (mounted) {
      setState(() {
        _tocando = false;
        _decorrido = Duration.zero;
      });
    }
  }

  Future<void> _alternarPlay() async {
    if (_tocando) {
      await _parar();
    } else {
      await _falarAtual();
    }
  }

  Future<void> _irPara(int novoIndice) async {
    if (_versiculos == null || _versiculos!.isEmpty) return;
    final estavaTocando = _tocando;
    await _parar();
    if (!mounted) return;
    setState(() => _indice = novoIndice);
    if (estavaTocando) await _falarAtual();
  }

  Future<void> _proximo() {
    final n = _versiculos!.length;
    if (_aleatorio && n > 1) {
      var sorteado = _indice;
      while (sorteado == _indice) {
        sorteado = Random().nextInt(n);
      }
      return _irPara(sorteado);
    } else {
      return _irPara((_indice + 1) % n);
    }
  }

  Future<void> _anterior() {
    final n = _versiculos!.length;
    return _irPara((_indice - 1 + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final v = _atual;
    final titulo = v == null
        ? 'Versículo do dia'
        : 'Versículo do dia — ${v['referencia']}';
    final corDestaque = Theme.of(context).colorScheme.secondary;
    final progresso = _estimado.inMilliseconds == 0
        ? 0.0
        : (_decorrido.inMilliseconds / _estimado.inMilliseconds)
            .clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: _aleatorio ? corDestaque : null,
                ),
                tooltip: 'Aleatório',
                onPressed: v == null
                    ? null
                    : () => setState(() => _aleatorio = !_aleatorio),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                tooltip: 'Anterior',
                onPressed: v == null ? null : _anterior,
              ),
              IconButton(
                icon: Icon(
                  _tocando ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 36,
                ),
                tooltip: _tocando ? 'Pausar' : 'Ouvir',
                onPressed: v == null ? null : _alternarPlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                tooltip: 'Próximo',
                onPressed: v == null ? null : _proximo,
              ),
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: _repetir ? corDestaque : null,
                ),
                tooltip: 'Repetir',
                onPressed: v == null
                    ? null
                    : () => setState(() => _repetir = !_repetir),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(value: progresso),
        ],
      ),
    );
  }
}
