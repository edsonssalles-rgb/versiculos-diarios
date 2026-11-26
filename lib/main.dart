import 'package:flutter/material.dart';
import 'screens/inicio.dart';
import 'screens/biblia.dart';
import 'screens/ajuda.dart';
import 'screens/pao_nosso.dart';
import 'widgets/miniplayer.dart';

void main() {
  runApp(const MyChurchApp());
}

/// MyChurch — Fase 1, passo 2: Início com 3 cards + miniplayer.
///
/// 4 abas: Início (3 cards), Bíblia (ARC embutida),
/// Ajuda (fichas por tema) e Pão Nosso (reflexão do dia — conteúdo do Edson).
/// Cores: azul profundo (principal) + dourado suave (destaque);
/// claro/escuro segue o sistema do celular (ThemeMode.system).
class MyChurchApp extends StatelessWidget {
  const MyChurchApp({super.key});

  static const _azulProfundo = Color(0xFF0B2A5B);
  static const _dourado = Color(0xFFC9A227);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyChurch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _azulProfundo,
          secondary: _dourado,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _azulProfundo,
          brightness: Brightness.dark,
          secondary: _dourado,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
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

  static const List<String> _titulos = <String>[
    'Versículo do dia',
    'Bíblia',
    'Ajuda',
    'Pão Nosso',
  ];

  void _irPara(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    final telas = <Widget>[
      TelaInicio(
        onIrParaAjuda: () => _irPara(2),
        onIrParaPaoNosso: () => _irPara(3),
      ),
      const TelaBiblia(),
      const TelaAjuda(),
      const TelaPaoNosso(),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      body: Column(
        children: [
          Expanded(child: telas[_indice]),
          const Miniplayer(),
        ],
      ),
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
