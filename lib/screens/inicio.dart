import 'package:flutter/material.dart';
import '../services/dados.dart';

/// Tela Início (MyChurch): 3 cards + aviso de lista de prova.
///
/// - Versículo do dia (texto, referência e tema)
/// - Pão Nosso (reflexão do dia, escrita pelo Edson)
/// - "Você está sofrendo?" (tocar leva para a aba Ajuda)
///
/// Cada card tem uma faixa no topo: título à esquerda, foto à direita,
/// texto nunca sobre a imagem. O ciclo semanal é só lógica interna:
/// nenhum dia da semana aparece como texto visível aqui.
class TelaInicio extends StatefulWidget {
  const TelaInicio({
    super.key,
    required this.onIrParaAjuda,
    required this.onIrParaPaoNosso,
  });

  final VoidCallback onIrParaAjuda;
  final VoidCallback onIrParaPaoNosso;

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  Map<String, dynamic>? _versiculos;
  Map<String, dynamic>? _paoNosso;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CartaoHome(
            titulo: 'Versículo do dia',
            imagem: 'assets/images/versiculo.jpg',
            filhos: [
              Text(
                '“${v['texto_arc']}”',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                v['referencia'],
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Center(
                child: Chip(
                  label: Text(v['tema']),
                  avatar: const Icon(Icons.label, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CartaoHome(
            titulo: 'Pão Nosso',
            imagem: 'assets/images/pao_nosso.jpg',
            onTap: widget.onIrParaPaoNosso,
            filhos: [
              if (reflexoes.isEmpty)
                const Text(
                  'As reflexões diárias são escritas pelo Edson. '
                  'O espaço já está pronto: quando ele mandar as 90 reflexões, '
                  'elas aparecem aqui, uma por dia, com botão de ouvir.',
                  textAlign: TextAlign.center,
                )
              else
                _ReflexaoDoDia(reflexoes: reflexoes),
            ],
          ),
          const SizedBox(height: 16),
          _CartaoHome(
            titulo: 'Você está sofrendo?',
            imagem: 'assets/images/sofrendo.jpg',
            onTap: widget.onIrParaAjuda,
            filhos: [
              const Text(
                'Se o coração está pesado, há palavras de acolhimento, '
                'versículos e uma oração esperando por você.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Toque para ver a ajuda →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (ehProva)
            const Card(
              color: Colors.amberAccent,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'LISTA DE PROVA — a versão final dos versículos será definida pelo Edson, versículo por versículo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Título da reflexão do dia (mesma regra da tela Pão Nosso).
class _ReflexaoDoDia extends StatelessWidget {
  const _ReflexaoDoDia({required this.reflexoes});

  final List<dynamic> reflexoes;

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final diaDoAno = hoje.difference(DateTime(hoje.year, 1, 1)).inDays + 1;
    final r =
        reflexoes[(diaDoAno - 1) % reflexoes.length] as Map<String, dynamic>;
    return Column(
      children: [
        Text(
          r['titulo'],
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(r['referencia'], textAlign: TextAlign.center),
      ],
    );
  }
}

/// Card da Início: faixa no topo com o título à esquerda e a foto
/// à direita; o corpo fica abaixo da faixa, nunca sobre a imagem.
class _CartaoHome extends StatelessWidget {
  const _CartaoHome({
    required this.titulo,
    required this.imagem,
    required this.filhos,
    this.onTap,
  });

  final String titulo;
  final String imagem;
  final List<Widget> filhos;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final conteudo = Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Text(
                    titulo,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  imagem,
                  width: 110,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: filhos,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return conteudo;
    return InkWell(onTap: onTap, child: conteudo);
  }
}
