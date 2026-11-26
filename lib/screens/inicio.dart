import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/compartilhar.dart';
import '../services/dados.dart';

/// Tela Início (MyChurch) — igual ao mockup do Edson.
///
/// O cabeçalho (logo "M" + MyChurch + menu + player) vive em main.dart;
/// aqui o conteúdo mostra só a data de hoje, acima da grade.
///
/// Os 3 cards têm TODOS o mesmo formato e as mesmas cores: foto grande
/// no topo (largura total do card, 16:9), título em azul abaixo da foto,
/// texto abaixo do título, e botão azul — e todos têm a MESMA ALTURA:
/// os cards de cada linha esticam até o mais alto, e os botões ficam
/// sempre alinhados no rodapé do card.
/// - Versículo do dia: "Ouvir" (azul, lê em voz alta) + "Ler na Bíblia"
///   (cinza, abre a Bíblia no livro/capítulo do versículo)
/// - Pão Nosso: "Ler a reflexão" (azul, abre a tela Pão Nosso) + "Ouvir"
///   (cinza, só quando há reflexão)
/// - "Você está sofrendo?": "Receber uma palavra" (azul, abre a Ajuda)
///
/// O texto nunca fica sobre a imagem. Na tela larga os 3 cards ficam
/// lado a lado (grade, padrão do site modelo); no celular, empilhados.
/// O ciclo semanal é só lógica interna: nenhum tema aparece como texto
/// visível aqui (só a data do cabeçalho, que é uma data, não o ciclo).
class TelaInicio extends StatefulWidget {
  const TelaInicio({
    super.key,
    required this.onIrParaAjuda,
    required this.onIrParaPaoNosso,
    required this.onLerNaBiblia,
  });

  final VoidCallback onIrParaAjuda;
  final VoidCallback onIrParaPaoNosso;

  /// Abre a Bíblia no livro e capítulo do versículo (ex.: "Marcos", 9).
  final void Function(String livro, int capitulo) onLerNaBiblia;

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  final FlutterTts _tts = FlutterTts();
  Map<String, dynamic>? _versiculos;
  Map<String, dynamic>? _paoNosso;
  String? _erro;

  /// Qual card está falando agora: 'versiculo', 'pao' ou null.
  String? _falando;

  @override
  void initState() {
    super.initState();
    _tts.setErrorHandler((_) {
      // A fala falhou (no Chrome web aparece SpeechSynthesisErrorEvent).
      if (!mounted) return;
      setState(() => _falando = null);
      _mostrarErroVoz();
    });
    _carregar();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final v = await Dados.versiculosDoDia();
      final p = await Dados.paoNosso();
      if (mounted) {
        setState(() {
          _versiculos = v;
          _paoNosso = p;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar a tela inicial.');
      }
    }
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

  /// Lê um texto em voz alta; tocar de novo para a fala.
  Future<void> _ouvir(String id, String texto) async {
    if (_falando == id) {
      await _tts.stop();
      if (mounted) setState(() => _falando = null);
      return;
    }
    await _tts.stop();
    setState(() => _falando = id);
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.9);
      await _prepararVoz();
      final resultado = await _tts.speak(texto);
      if (mounted) {
        setState(() => _falando = null);
        if (resultado == 0) _mostrarErroVoz();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _falando = null);
        _mostrarErroVoz();
      }
    }
  }

  /// "Marcos 9:23" ou "Lamentações 3:22-23" -> (livro, capítulo).
  /// Devolve null quando a referência não segue esse formato.
  ({String livro, int capitulo})? _parseReferencia(String ref) {
    final m = RegExp(r'^(.+?)\s+(\d+):(\d+)').firstMatch(ref.trim());
    if (m == null) return null;
    return (livro: m.group(1)!, capitulo: int.parse(m.group(2)!));
  }

  @override
  Widget build(BuildContext context) {
    if (_erro != null) {
      return Center(child: Text(_erro!));
    }
    if (_versiculos == null || _paoNosso == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final lista = _versiculos!['versiculos'] as List<dynamic>;
    final v = Dados.versiculoDoDia(lista, DateTime.now());
    final ehProva = _versiculos!['lista'] == 'prova';
    final reflexoes = (_paoNosso!['reflexoes'] as List<dynamic>?) ?? [];

    // Largura útil da grade: tela menos o padding de 16 de cada lado,
    // limitada a 1100 (o mesmo limite do ConstrainedBox abaixo).
    final larguraGrade =
        (MediaQuery.of(context).size.width - 32).clamp(0.0, 1100.0);
    final colunas = larguraGrade < 600 ? 1 : larguraGrade < 1000 ? 2 : 3;
    // Só no layout largo os cards têm a mesma altura (IntrinsicHeight +
    // Spacer); no celular cada card tem sua altura natural.
    final mesmaAltura = colunas > 1;

    final cardVersiculo = _CartaoHome(
      mesmaAltura: mesmaAltura,
      titulo: 'Versículo do dia',
      imagem: 'assets/images/versiculo.jpg',
      filhos: [
        Text(
          '“${v['texto_arc']}”',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          '${v['referencia']} — Almeida Revista e Corrigida',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _botaoAzul(
              rotulo: _falando == 'versiculo' ? 'Parar' : 'Ouvir',
              icone: _falando == 'versiculo'
                  ? Icons.stop
                  : Icons.play_arrow,
              onPressed: () => _ouvir(
                'versiculo',
                '${v['referencia']}. ${v['texto_arc']}',
              ),
            ),
            _botaoCinza(
              rotulo: 'Ler na Bíblia',
              onPressed: () {
                final ref = _parseReferencia(v['referencia'] as String);
                if (ref != null) {
                  widget.onLerNaBiblia(ref.livro, ref.capitulo);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartilhar',
              onPressed: () => compartilharVersiculo(v),
            ),
          ],
        ),
      ],
    );

    final Widget cardPaoNosso;
    if (reflexoes.isEmpty) {
      cardPaoNosso = _CartaoHome(
        mesmaAltura: mesmaAltura,
        titulo: 'Pão Nosso de cada dia',
        imagem: 'assets/images/pao_nosso.jpg',
        filhos: [
          const Text(
            'As reflexões diárias são escritas pelo Edson. '
            'O espaço já está pronto: quando ele mandar as 90 reflexões, '
            'elas aparecem aqui, uma por dia, com botão de ouvir.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            children: [
              _botaoAzul(
                rotulo: 'Ler a reflexão',
                icone: Icons.restaurant,
                onPressed: widget.onIrParaPaoNosso,
              ),
            ],
          ),
        ],
      );
    } else {
      final hoje = DateTime.now();
      final diaDoAno = hoje.difference(DateTime(hoje.year, 1, 1)).inDays + 1;
      final r =
          reflexoes[(diaDoAno - 1) % reflexoes.length] as Map<String, dynamic>;
      final textoReflexao =
          '${r['titulo']}. ${r['referencia']}. ${r['texto']}';
      cardPaoNosso = _CartaoHome(
        mesmaAltura: mesmaAltura,
        titulo: 'Pão Nosso de cada dia',
        imagem: 'assets/images/pao_nosso.jpg',
        filhos: [
          Text(
            r['titulo'],
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            r['referencia'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _botaoAzul(
                rotulo: 'Ler a reflexão',
                icone: Icons.restaurant,
                onPressed: widget.onIrParaPaoNosso,
              ),
              _botaoCinza(
                rotulo: _falando == 'pao' ? 'Parar' : 'Ouvir',
                icone: _falando == 'pao' ? Icons.stop : Icons.play_arrow,
                onPressed: () => _ouvir('pao', textoReflexao),
              ),
            ],
          ),
        ],
      );
    }

    final cardSofrendo = _CartaoHome(
      mesmaAltura: mesmaAltura,
      titulo: 'Você está sofrendo?',
      imagem: 'assets/images/sofrendo.jpg',
      filhos: [
        const Text(
          'Receba uma palavra no momento de aflição.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Wrap(
          children: [
            _botaoAzul(
              rotulo: 'Receber uma palavra',
              icone: Icons.favorite,
              onPressed: widget.onIrParaAjuda,
            ),
          ],
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _dataHojePorExtenso(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              _gradeCards(
                [cardVersiculo, cardPaoNosso, cardSofrendo],
                colunas,
              ),
              const SizedBox(height: 16),
              if (ehProva)
                Text(
                  'LISTA DE PROVA — a versão final dos versículos será definida pelo Edson, versículo por versículo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

/// Grade da Início: no layout largo os cards de cada linha têm a MESMA
/// ALTURA — a linha é um Row com CrossAxisAlignment.stretch ENVOLVIDO
/// por IntrinsicHeight (sem ele, o stretch dentro do SingleChildScrollView
/// recebe altura infinita e quebra com "BoxConstraints forces an infinite
/// height"). Na última linha, os espaços vazios mantêm a largura das
/// colunas. Com 1 coluna (celular), os cards ficam empilhados em largura
/// total, sem Row nem IntrinsicHeight.
Widget _gradeCards(List<Widget> cards, int colunas) {
  if (colunas <= 1) {
    final itens = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      if (i > 0) itens.add(const SizedBox(height: 16));
      itens.add(cards[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: itens,
    );
  }
  final linhas = <Widget>[];
  for (var i = 0; i < cards.length; i += colunas) {
    final fim = (i + colunas).clamp(0, cards.length);
    final daLinha = cards.sublist(i, fim);
    linhas.add(
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < daLinha.length; j++) ...[
              if (j > 0) const SizedBox(width: 16),
              Expanded(child: daLinha[j]),
            ],
            for (var j = daLinha.length; j < colunas; j++) ...[
              const SizedBox(width: 16),
              const Expanded(child: SizedBox.shrink()),
            ],
          ],
        ),
      ),
    );
    if (fim < cards.length) {
      linhas.add(const SizedBox(height: 16));
    }
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: linhas,
  );
}

/// Data de hoje em português: "Terça-feira, 24 de novembro de 2026".
String _dataHojePorExtenso() {
  const diasSemana = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  const meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  final hoje = DateTime.now();
  final dia = diasSemana[hoje.weekday - 1];
  final diaCapitalizado = dia[0].toUpperCase() + dia.substring(1);
  return '$diaCapitalizado, ${hoje.day} de ${meses[hoje.month - 1]} de ${hoje.year}';
}

/// Botão azul em pílula — o mesmo nos 3 cards.
Widget _botaoAzul({
  required String rotulo,
  required IconData icone,
  required VoidCallback onPressed,
}) {
  return FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icone, size: 18),
    label: Text(rotulo),
    style: FilledButton.styleFrom(
      backgroundColor: const Color(0xFF0B2A5B),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: const StadiumBorder(),
    ),
  );
}

/// Botão cinza em pílula — ação secundária (mesmo formato do azul).
Widget _botaoCinza({
  required String rotulo,
  IconData? icone,
  required VoidCallback onPressed,
}) {
  return FilledButton.tonalIcon(
    onPressed: onPressed,
    icon: icone == null ? null : Icon(icone, size: 18),
    label: Text(rotulo),
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: const StadiumBorder(),
    ),
  );
}

/// Card da Início, padrão do site modelo: foto grande no topo, em
/// largura total do card e 16:9; título em azul abaixo da foto; o corpo
/// (texto, referência, botões) fica abaixo do título. O texto nunca
/// fica sobre a imagem.
///
/// Mesma altura (layout largo, mesmaAltura: true): o conteúdo estica
/// até a altura do card (IntrinsicHeight + Expanded) e o Spacer empurra
/// a linha de botões — sempre o último filho — para o rodapé do card,
/// então os botões dos 3 cards ficam alinhados mesmo quando os textos
/// têm tamanhos diferentes. No celular (mesmaAltura: false) o card tem
/// sua altura natural: Column simples, sem IntrinsicHeight, sem
/// Expanded e sem Spacer — nada de flex dentro do scroll sem uma
/// altura limitada por fora.
class _CartaoHome extends StatelessWidget {
  const _CartaoHome({
    required this.titulo,
    required this.imagem,
    required this.filhos,
    this.mesmaAltura = true,
  });

  final String titulo;
  final String imagem;
  final List<Widget> filhos;

  /// true no layout largo (desktop/tablet), false no celular.
  final bool mesmaAltura;

  @override
  Widget build(BuildContext context) {
    // O último filho é sempre a linha de botões; no modo de altura igual
    // o Spacer a empurra para o rodapé do card.
    final corpo = mesmaAltura && filhos.length > 1
        ? <Widget>[
            ...filhos.sublist(0, filhos.length - 1),
            const Spacer(),
            filhos.last,
          ]
        : filhos;
    final texto = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: mesmaAltura ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0B2A5B),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...corpo,
        ],
      ),
    );
    final foto = AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.asset(
        imagem,
        fit: BoxFit.cover,
      ),
    );
    if (!mesmaAltura) {
      // Celular: altura natural, sem IntrinsicHeight/Expanded/Spacer.
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            foto,
            texto,
          ],
        ),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            foto,
            Expanded(child: texto),
          ],
        ),
      ),
    );
  }
}
