import 'dart:async';
import 'package:flutter/material.dart';
import '../services/player_musica.dart';

/// Duas vistas do MESMO player (PlayerMusica, compartilhado e criado
/// uma só vez em TelaPrincipal):
///
/// - Miniplayer: barra completa do rodapé (celular/tablet) — igual a
///   antes: título da faixa, tempo atual à esquerda, tempo total à
///   direita, barra de progresso entre eles, e controles com o botão
///   de play GRANDE, AZUL e CIRCULAR no centro (aleatório à esquerda,
///   anterior, play, próximo, repetir à direita — com um selo "1"
///   quando a repetição está ligada).
///
/// - PlayerCompacto: versão compacta para dentro do cabeçalho
///   (desktop): título pequeno com ellipsis, anterior / play-pause /
///   próximo, barra de progresso fina e tempos; aleatório e repetir
///   menores, nas pontas.
///
/// A barra de progresso e os tempos usam a posição e a duração REAIS
/// do áudio (streams do just_audio) — nada de estimativa. Os botões
/// "Ouvir" dos cards e do Pão Nosso continuam separados: eles leem o
/// versículo/reflexão em voz alta via TTS (flutter_tts).

const _azulPlayer = Color(0xFF0B2A5B);

/// Escuta os erros do player e mostra o SnackBar. Usado pelas duas
/// vistas; cada vista cancela sua escuta ao sair da tela.
mixin _ErrosDoPlayer<T extends StatefulWidget> on State<T> {
  StreamSubscription<String>? _subErros;

  void escutarErros(PlayerMusica player) {
    _subErros = player.erros.listen((mensagem) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(mensagem)));
    });
  }

  @override
  void dispose() {
    _subErros?.cancel();
    super.dispose();
  }
}

class Miniplayer extends StatefulWidget {
  const Miniplayer({super.key, required this.player});

  final PlayerMusica player;

  @override
  State<Miniplayer> createState() => _MiniplayerState();
}

class _MiniplayerState extends State<Miniplayer> with _ErrosDoPlayer {
  @override
  void initState() {
    super.initState();
    escutarErros(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    return ListenableBuilder(
      listenable: player,
      builder: (context, _) {
        final corDestaque = Theme.of(context).colorScheme.secondary;
        final corTextoSecundario =
            Theme.of(context).colorScheme.onSurfaceVariant;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Agnus Dei',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    PlayerMusica.formatarTempo(player.posicao),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: corTextoSecundario),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: player.progresso,
                      minHeight: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(corDestaque),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    PlayerMusica.formatarTempo(player.duracao),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: corTextoSecundario),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: player.aleatorio ? corDestaque : null,
                    ),
                    tooltip: 'Aleatório',
                    onPressed: player.carregado
                        ? player.alternarAleatorio
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    tooltip: 'Anterior',
                    onPressed: player.carregado ? player.reiniciar : null,
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: FilledButton(
                      onPressed:
                          player.carregado ? player.alternarPlay : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _azulPlayer,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(
                        player.tocando ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    tooltip: 'Próximo',
                    onPressed: player.carregado ? player.reiniciar : null,
                  ),
                  _BotaoRepetir(
                    ativo: player.repetir,
                    corDestaque: corDestaque,
                    tamanho: 24,
                    onPressed:
                        player.carregado ? player.alternarRepetir : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Botão de repetir com o selo "1" quando a repetição está ligada.
class _BotaoRepetir extends StatelessWidget {
  const _BotaoRepetir({
    required this.ativo,
    required this.corDestaque,
    required this.tamanho,
    required this.onPressed,
  });

  final bool ativo;
  final Color corDestaque;
  final double tamanho;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final selo = tamanho <= 18 ? 12.0 : 14.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.repeat,
            size: tamanho,
            color: ativo ? corDestaque : null,
          ),
          tooltip: 'Repetir',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: tamanho + 12,
            height: tamanho + 12,
          ),
          onPressed: onPressed,
        ),
        if (ativo)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: selo,
              height: selo,
              decoration: const BoxDecoration(
                color: _azulPlayer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: selo - 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Player compacto do cabeçalho (só no desktop): duas linhas — na
/// primeira, título pequeno com ellipsis + anterior / play-pause /
/// próximo + aleatório e repetir menores; na segunda, tempo atual,
/// barra de progresso fina e tempo total.
class PlayerCompacto extends StatefulWidget {
  const PlayerCompacto({super.key, required this.player});

  final PlayerMusica player;

  @override
  State<PlayerCompacto> createState() => _PlayerCompactoState();
}

class _PlayerCompactoState extends State<PlayerCompacto>
    with _ErrosDoPlayer {
  @override
  void initState() {
    super.initState();
    escutarErros(widget.player);
  }

  /// Botão pequeno do cabeçalho (30x30, ícone 18).
  Widget _botaoPequeno({
    required IconData icone,
    required VoidCallback? onPressed,
    Color? cor,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icone, size: 18, color: cor),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    return ListenableBuilder(
      listenable: player,
      builder: (context, _) {
        final corDestaque = Theme.of(context).colorScheme.secondary;
        final corTextoSecundario =
            Theme.of(context).colorScheme.onSurfaceVariant;
        final estiloTempo = Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: corTextoSecundario, fontSize: 11);
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Agnus Dei',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                _botaoPequeno(
                  icone: Icons.shuffle,
                  cor: player.aleatorio ? corDestaque : null,
                  tooltip: 'Aleatório',
                  onPressed:
                      player.carregado ? player.alternarAleatorio : null,
                ),
                _botaoPequeno(
                  icone: Icons.skip_previous,
                  tooltip: 'Anterior',
                  onPressed: player.carregado ? player.reiniciar : null,
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: FilledButton(
                    onPressed: player.carregado ? player.alternarPlay : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _azulPlayer,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      player.tocando ? Icons.pause : Icons.play_arrow,
                      size: 20,
                    ),
                  ),
                ),
                _botaoPequeno(
                  icone: Icons.skip_next,
                  tooltip: 'Próximo',
                  onPressed: player.carregado ? player.reiniciar : null,
                ),
                _BotaoRepetir(
                  ativo: player.repetir,
                  corDestaque: corDestaque,
                  tamanho: 18,
                  onPressed:
                      player.carregado ? player.alternarRepetir : null,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  PlayerMusica.formatarTempo(player.posicao),
                  style: estiloTempo,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: LinearProgressIndicator(
                    value: player.progresso,
                    minHeight: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(corDestaque),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  PlayerMusica.formatarTempo(player.duracao),
                  style: estiloTempo,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
