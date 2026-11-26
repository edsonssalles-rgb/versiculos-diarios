import 'package:flutter/material.dart';
import 'screens/inicio.dart';
import 'screens/biblia.dart';
import 'screens/ajuda.dart';
import 'screens/pao_nosso.dart';

void main() {
  runApp(const VersiculosDiariosApp());
}

/// Versículos Diários — versão 1 (Fase 1: esqueleto + conteúdo de prova).
///
/// 4 telas: Início (versículo do dia), Bíblia (ARC embutida),
/// Ajuda (fichas por tema) e Pão Nosso (reflexão do dia — conteúdo do Edson).
class VersiculosDiariosApp extends StatelessWidget {
  const VersiculosDiariosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Versículos Diários',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _indice = 0;

  static const List<Widget> _telas = <Widget>[
    TelaInicio(),
    TelaBiblia(),
    TelaAjuda(),
    TelaPaoNosso(),
  ];

  static const List<String> _titulos = <String>[
    'Versículo do dia',
    'Bíblia',
    'Ajuda',
    'Pão Nosso',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: _telas[_indice],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indice,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _indice = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bíblia'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Ajuda'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Pão Nosso'),
        ],
      ),
    );
  }
}
