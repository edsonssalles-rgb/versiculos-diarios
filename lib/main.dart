import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/inicio.dart';
import 'screens/biblia.dart';
import 'screens/ajuda.dart';
import 'screens/pao_nosso.dart';
import 'screens/contato.dart';
import 'screens/doacoes.dart';
import 'services/player_musica.dart';
import 'widgets/logo_mychurch.dart';
import 'widgets/miniplayer.dart';

void main() {
  runApp(const MyChurchApp());
}

/// MyChurch — Fase 1, passo 4: layout do mockup + site modelo.
///
/// Navegação principal (4 destinos): Início, Bíblia, Contato, Doação.
/// Pão Nosso e Ajuda continuam existindo, mas são alcançados pelos cards
/// da Início (não aparecem na navegação principal).
///
/// Cabeçalho único (~80 px), sem faixa separada de player:
/// - Desktop (>= 1000): uma só linha — logo "M" + MyChurch à esquerda,
///   menu centralizado (Início, Bíblia, Contato, Doação) e o player
///   compacto à direita, depois de "Doação".
/// - Tablet (600-1000): logo + menu na mesma linha; o player fica na
///   barra mini do rodapé.
/// - Celular (< 600): logo + botão hambúrguer (abre o menu lateral);
///   o player fica na barra mini do rodapé.
///
/// O player de música é UM só (PlayerMusica, criado em TelaPrincipal):
/// o player do cabeçalho e o miniplayer do rodapé são duas vistas do
/// mesmo áudio — trocar de página ou redimensionar a janela não
/// reinicia a música.
///
/// Web é sempre CLARA (página clara, fundo cinza claro, cards brancos);
/// no celular, claro/escuro segue o sistema (ThemeMode.system).
/// Cores: azul profundo (principal) + dourado suave (destaque).
const _azulProfundo = Color(0xFF0B2A5B);
const _dourado = Color(0xFFC9A227);
const _fundoClaro = Color(0xFFF2F2F5);

class MyChurchApp extends StatelessWidget {
  const MyChurchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyChurch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _azulProfundo,
          secondary: _dourado,
        ),
        scaffoldBackgroundColor: _fundoClaro,
        cardTheme: const CardThemeData(color: Colors.white),
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
      themeMode: kIsWeb ? ThemeMode.light : ThemeMode.system,
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
  /// Player de música compartilhado: criado uma só vez aqui e passado
  /// para o cabeçalho (desktop) ou para o miniplayer do rodapé
  /// (celular/tablet). Nunca é recriado ao trocar de página ou ao
  /// redimensionar a janela.
  final PlayerMusica _player = PlayerMusica();

  /// 0 Início, 1 Bíblia, 2 Contato, 3 Doação, 4 Ajuda, 5 Pão Nosso.
  int _tela = 0;

  /// Livro/capítulo para pré-selecionar na Bíblia ("Ler na Bíblia").
  String? _bibliaLivro;
  int? _bibliaCapitulo;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _irPara(int i) => setState(() => _tela = i);

  void _lerNaBiblia(String livro, int capitulo) {
    setState(() {
      _bibliaLivro = livro;
      _bibliaCapitulo = capitulo;
      _tela = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    final desktop = largura >= 1000;
    final tablet = largura >= 600 && largura < 1000;
    final telas = <Widget>[
      TelaInicio(
        onIrParaAjuda: () => _irPara(4),
        onIrParaPaoNosso: () => _irPara(5),
        onLerNaBiblia: _lerNaBiblia,
      ),
      TelaBiblia(
        livroInicial: _bibliaLivro,
        capituloInicial: _bibliaCapitulo,
      ),
      const TelaContato(),
      const TelaDoacoes(),
      const TelaAjuda(),
      const TelaPaoNosso(),
    ];

    // A barra de abas só tem os 4 destinos principais. Ajuda e Pão Nosso
    // são abertos pelos cards da Início, então a aba Início fica marcada.
    final indiceNav = _tela <= 3 ? _tela : 0;

    if (desktop) {
      return Scaffold(
        body: Column(
          children: [
            _CabecalhoTopo(
              telaAtual: _tela,
              onSelecionar: _irPara,
              player: _player,
            ),
            Expanded(child: telas[_tela]),
          ],
        ),
      );
    }

    // Celular (< 600) e tablet (600-1000): cabeçalho com logo + menu,
    // player na barra mini do rodapé e barra de abas embaixo. No
    // celular o menu é o hambúrguer (menu lateral); no tablet o menu
    // aparece na própria linha do cabeçalho.
    return Scaffold(
      drawer: tablet
          ? null
          : _MenuLateral(telaAtual: _tela, onSelecionar: _irPara),
      body: Column(
        children: [
          _CabecalhoTopo(
            telaAtual: _tela,
            onSelecionar: _irPara,
            hamburguer: !tablet,
          ),
          Expanded(child: telas[_tela]),
          Miniplayer(player: _player),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceNav,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _irPara,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bíblia'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Contato'),
          BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard), label: 'Doação'),
        ],
      ),
    );
  }
}

/// Cabeçalho único (~80 px): logo "M" + MyChurch à esquerda; no centro,
/// o menu (Início, Bíblia, Contato, Doação — o atual fica com texto azul
/// e sublinhado dourado) ou, no celular, o botão hambúrguer; à direita,
/// só no desktop, o player compacto depois de "Doação".
class _CabecalhoTopo extends StatelessWidget {
  const _CabecalhoTopo({
    required this.telaAtual,
    required this.onSelecionar,
    this.player,
    this.hamburguer = false,
  });

  /// Tela atual (0..5); só 0..3 têm item no menu.
  final int telaAtual;
  final ValueChanged<int> onSelecionar;

  /// Player compartilhado: só no desktop ele aparece no cabeçalho.
  final PlayerMusica? player;

  /// true no celular: mostra o botão hambúrguer em vez do menu.
  final bool hamburguer;

  static const _rotulos = ['Início', 'Bíblia', 'Contato', 'Doação'];

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: esquema.surface,
        border:
            Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const LogoMyChurch(tamanho: 40),
          const SizedBox(width: 10),
          Text(
            'MyChurch',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (!hamburguer)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _rotulos.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        onPressed: () => onSelecionar(i),
                        style: TextButton.styleFrom(
                          foregroundColor: telaAtual == i
                              ? _azulProfundo
                              : esquema.onSurfaceVariant,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_rotulos[i]),
                            const SizedBox(height: 2),
                            Container(
                              height: 2,
                              width: 24,
                              color: telaAtual == i
                                  ? _dourado
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            const Spacer(),
          if (player != null) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: PlayerCompacto(player: player!),
            ),
          ],
          if (hamburguer)
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        ],
      ),
    );
  }
}

/// Menu lateral do celular (hambúrguer): os 4 destinos principais,
/// com o atual marcado.
class _MenuLateral extends StatelessWidget {
  const _MenuLateral({
    required this.telaAtual,
    required this.onSelecionar,
  });

  final int telaAtual;
  final ValueChanged<int> onSelecionar;

  static const _rotulos = ['Início', 'Bíblia', 'Contato', 'Doação'];
  static const _icones = [
    Icons.home,
    Icons.book,
    Icons.mail,
    Icons.card_giftcard,
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: _azulProfundo),
            child: Row(
              children: [
                const LogoMyChurch(tamanho: 44),
                const SizedBox(width: 12),
                Text(
                  'MyChurch',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _rotulos.length; i++)
            ListTile(
              leading: Icon(_icones[i]),
              title: Text(_rotulos[i]),
              selected: telaAtual == i,
              selectedColor: _azulProfundo,
              onTap: () {
                Navigator.of(context).pop();
                onSelecionar(i);
              },
            ),
        ],
      ),
    );
  }
}
