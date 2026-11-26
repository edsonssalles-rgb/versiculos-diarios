import 'package:share_plus/share_plus.dart';

/// Texto compartilhado de um versículo: o texto entre aspas,
/// a referência com (ARC) e a assinatura do app, cada um numa linha:
///
/// "Eu sou o caminho, e a verdade, e a vida."
/// João 14:6 (ARC)
/// — MyChurch
String textoParaCompartilhar(Map<String, dynamic> versiculo) {
  final texto = versiculo['texto_arc'] as String? ?? '';
  final referencia = versiculo['referencia'] as String? ?? '';
  return '"$texto"\n$referencia (ARC)\n— MyChurch';
}

/// Abre o menu de compartilhar do sistema com o versículo.
/// Na web usa a Web Share API do navegador (com fallback do pacote).
Future<void> compartilharVersiculo(Map<String, dynamic> versiculo) async {
  await SharePlus.instance.share(
    ShareParams(text: textoParaCompartilhar(versiculo)),
  );
}
