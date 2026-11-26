import 'package:flutter/material.dart';
import '../services/dados.dart';

/// Tela Bíblia: Almeida Revista e Corrigida, embutida no app (offline).
/// Fase 1: escolher o livro e o capítulo e ler os versículos.
/// Busca por palavra entra numa fase seguinte.
///
/// O botão "Ler na Bíblia" da Início pode pré-selecionar um livro e um
/// capítulo (livroInicial/capituloInicial): a tela abre direto neles.
class TelaBiblia extends StatefulWidget {
  const TelaBiblia({super.key, this.livroInicial, this.capituloInicial});

  /// Nome do livro a abrir (ex.: "Marcos"), ou null para manter o atual.
  final String? livroInicial;

  /// Capítulo a abrir (1-based), ou null para manter o atual.
  final int? capituloInicial;

  @override
  State<TelaBiblia> createState() => _TelaBibliaState();
}

class _TelaBibliaState extends State<TelaBiblia> {
  List<dynamic>? _livros;
  int _livro = 42; // João, para começar
  int _capitulo = 3;

  @override
  void initState() {
    super.initState();
    Dados.biblia().then((b) {
      if (!mounted) return;
      setState(() => _livros = b);
      _aplicarSelecao();
    });
  }

  @override
  void didUpdateWidget(TelaBiblia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.livroInicial != oldWidget.livroInicial ||
        widget.capituloInicial != oldWidget.capituloInicial) {
      _aplicarSelecao();
    }
  }

  /// Aplica livroInicial/capituloInicial, se informados e válidos.
  void _aplicarSelecao() {
    if (_livros == null) return;
    final nome = widget.livroInicial;
    if (nome == null) return;
    var indice = -1;
    for (var i = 0; i < _livros!.length; i++) {
      if ((_livros![i]['name'] as String).toLowerCase() ==
          nome.toLowerCase()) {
        indice = i;
        break;
      }
    }
    if (indice < 0) return;
    final capitulos = _livros![indice]['chapters'] as List<dynamic>;
    var capitulo = widget.capituloInicial ?? 1;
    if (capitulo < 1) capitulo = 1;
    if (capitulo > capitulos.length) capitulo = capitulos.length;
    setState(() {
      _livro = indice;
      _capitulo = capitulo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_livros == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final livro = _livros![_livro];
    final capitulos = livro['chapters'] as List<dynamic>;
    final versos = capitulos[_capitulo - 1] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bíblia',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Almeida Revista e Corrigida',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _livro,
                  isExpanded: true,
                  items: [
                    for (var i = 0; i < _livros!.length; i++)
                      DropdownMenuItem(value: i, child: Text(_livros![i]['name'])),
                  ],
                  onChanged: (v) => setState(() {
                    _livro = v!;
                    _capitulo = 1;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: _capitulo,
                  isExpanded: true,
                  items: [
                    for (var i = 1; i <= capitulos.length; i++)
                      DropdownMenuItem(value: i, child: Text('Capítulo $i')),
                  ],
                  onChanged: (v) => setState(() => _capitulo = v!),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: versos.length,
            itemBuilder: (context, i) => ListTile(
              leading: Text('${i + 1}'),
              title: Text(versos[i] as String),
            ),
          ),
        ),
      ],
    );
  }
}
