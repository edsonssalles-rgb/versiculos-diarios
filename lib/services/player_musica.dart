import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Controlador compartilhado do player de música do MyChurch.
///
/// O AudioPlayer vive aqui (uma única instância) para que o player do
/// cabeçalho (desktop) e o miniplayer do rodapé (celular/tablet) sejam
/// duas vistas do MESMO áudio: trocar de página ou redimensionar a
/// janela não recria o player nem reinicia a música.
///
/// A lógica de áudio é a mesma de antes (just_audio, o mp3 "Agnus Dei"
/// em assets/audio/agnus_dei.mp3, repetir em loop, anterior/próximo
/// recomeçam a única faixa). Só mudou de lugar: antes vivia dentro do
/// widget Miniplayer, e o áudio recomeçava quando a tela mudava.
class PlayerMusica extends ChangeNotifier {
  PlayerMusica() {
    _preparar();
  }

  static const caminhoAudio = 'assets/audio/agnus_dei.mp3';

  final AudioPlayer _audio = AudioPlayer();

  bool carregado = false;
  bool tocando = false;
  bool aleatorio = false;
  bool repetir = false;
  Duration posicao = Duration.zero;
  Duration duracao = Duration.zero;

  /// Mensagens de erro ("Não foi possível tocar o áudio."). As vistas
  /// do player escutam este stream e mostram o SnackBar.
  final StreamController<String> _erros =
      StreamController<String>.broadcast();
  Stream<String> get erros => _erros.stream;

  StreamSubscription<Duration>? _subPosicao;
  StreamSubscription<Duration?>? _subDuracao;
  StreamSubscription<PlayerState>? _subEstado;
  StreamSubscription<PlayerException>? _subErro;

  bool _descartado = false;

  double get progresso => duracao.inMilliseconds == 0
      ? 0.0
      : (posicao.inMilliseconds / duracao.inMilliseconds)
          .clamp(0.0, 1.0);

  /// "0:00", "2:07".
  static String formatarTempo(Duration d) {
    final minutos = d.inMinutes;
    final segundos = d.inSeconds % 60;
    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }

  Future<void> _preparar() async {
    _subPosicao = _audio.positionStream.listen((p) {
      posicao = p;
      notifyListeners();
    });
    _subDuracao = _audio.durationStream.listen((d) {
      if (d != null) {
        duracao = d;
        notifyListeners();
      }
    });
    _subEstado = _audio.playerStateStream.listen((estado) async {
      if (estado.processingState == ProcessingState.completed && !repetir) {
        // Fim da música sem repetir: volta para o começo, parado.
        try {
          await _audio.seek(Duration.zero);
        } catch (_) {
          // O player pode já ter sido descartado; nada a fazer.
        }
      }
      tocando = estado.playing;
      notifyListeners();
    });
    _subErro = _audio.errorStream.listen((_) {
      tocando = false;
      notifyListeners();
      _erros.add('Não foi possível tocar o áudio.');
    });
    try {
      final d = await _audio.setAsset(caminhoAudio);
      if (_descartado) return;
      carregado = true;
      if (d != null) duracao = d;
      notifyListeners();
    } on PlayerException catch (_) {
      if (!_descartado) _erros.add('Não foi possível carregar o áudio.');
    } catch (_) {
      if (!_descartado) _erros.add('Não foi possível carregar o áudio.');
    }
  }

  @override
  void dispose() {
    _descartado = true;
    _subPosicao?.cancel();
    _subDuracao?.cancel();
    _subEstado?.cancel();
    _subErro?.cancel();
    _erros.close();
    _audio.dispose();
    super.dispose();
  }

  Future<void> alternarPlay() async {
    if (!carregado) return;
    try {
      if (tocando) {
        await _audio.pause();
      } else {
        // Se já terminou e ficou no fim, recomeça do zero.
        if (duracao > Duration.zero && posicao >= duracao) {
          await _audio.seek(Duration.zero);
        }
        await _audio.play();
      }
    } catch (_) {
      _erros.add('Não foi possível tocar o áudio.');
    }
  }

  /// Anterior e Próximo: só há uma faixa no player, então os dois
  /// recomeçam a música do início (continua tocando se já tocava).
  Future<void> reiniciar() async {
    if (!carregado) return;
    try {
      await _audio.seek(Duration.zero);
    } catch (_) {
      _erros.add('Não foi possível tocar o áudio.');
    }
  }

  Future<void> alternarRepetir() async {
    final novo = !repetir;
    repetir = novo;
    notifyListeners();
    try {
      await _audio.setLoopMode(novo ? LoopMode.one : LoopMode.off);
    } catch (_) {
      // Se falhar, desfaz o visual do botão.
      repetir = !novo;
      notifyListeners();
    }
  }

  /// Só há uma faixa no player: o botão fica no mockup, mas não há
  /// segunda música para sortear.
  void alternarAleatorio() {
    aleatorio = !aleatorio;
    notifyListeners();
  }
}
