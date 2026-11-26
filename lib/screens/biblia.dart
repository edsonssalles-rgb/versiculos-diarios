import 'package:flutter/material.dart';
import '../services/dados.dart';

/// Tela Bíblia: Almeida Revista e Corrigida, embutida no app (offline).
/// Fase 1: escolher o livro e o capítulo e ler os versículos.
/// Busca por palavra entra numa fase seguinte.
class TelaBiblia extends StatefulWidget {
  const TelaBiblia({super.key});

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
      if (mounted) setState(() => _livros = b);
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
      children: [
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
