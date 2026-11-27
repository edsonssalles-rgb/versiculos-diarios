import 'dart:convert';
import 'package:flutter/services.dart';

/// Carrega os dados locais do aplicativo (tudo embutido, sem servidor).
///
/// Fontes:
/// - Bíblia: assets/biblia/pt_arc.json (Almeida Revista e Corrigida, domínio público)
/// - Versículos do dia: assets/versiculos/versiculos_final.json (LISTA FINAL: 371 versículos, 53 por dia da semana)
/// - Fichas de ajuda: assets/ajuda/fichas_ajuda_rascunho.json (RASCUNHO)
/// - Pão Nosso: assets/pao_nosso/pao_nosso.json (reflexões escritas pelo Edson)
class Dados {
  static List<dynamic>? _biblia;
  static Map<String, dynamic>? _versiculos;
  static Map<String, dynamic>? _fichas;
  static Map<String, dynamic>? _paoNosso;

  static Future<List<dynamic>> biblia() async {
    _biblia ??= jsonDecode(await rootBundle.loadString('assets/biblia/pt_arc.json')) as List<dynamic>;
    return _biblia!;
  }

  static Future<Map<String, dynamic>> versiculosDoDia() async {
    _versiculos ??= jsonDecode(
      await rootBundle.loadString('assets/versiculos/versiculos_final.json'),
    ) as Map<String, dynamic>;
    return _versiculos!;
  }

  static Future<Map<String, dynamic>> fichasAjuda() async {
    _fichas ??= jsonDecode(
      await rootBundle.loadString('assets/ajuda/fichas_ajuda_rascunho.json'),
    ) as Map<String, dynamic>;
    return _fichas!;
  }

  static Future<Map<String, dynamic>> paoNosso() async {
    _paoNosso ??= jsonDecode(
      await rootBundle.loadString('assets/pao_nosso/pao_nosso.json'),
    ) as Map<String, dynamic>;
    return _paoNosso!;
  }

  /// Versículo do dia: escolhido pelo DIA DA SEMANA, conforme o ciclo
  /// definido pelo Edson (segunda = Motivação e fé, terça = Milagres,
  /// quarta = Buscar a Deus, oração e Palavra, quinta = Família, amor e
  /// união, sexta = Libertação e livramento, sábado = Conselhos e
  /// prudência, domingo = Adoração).
  ///
  /// A lista final tem 371 versículos = 53 por dia da semana (dia 1 =
  /// segunda). A semana do ano avança o índice de 7 em 7, então toda
  /// segunda-feira cai num versículo de Motivação e fé, toda terça num
  /// de Milagres, e assim por diante. Como 371 = 53 x 7, o ciclo cobre
  /// o ano inteiro sem repetir nem atrasar — inclusive em ano bissexto
  /// (366 dias = 52 semanas + 2 dias, índice máximo 370). No ano
  /// seguinte o ciclo recomeça do dia 1.
  static Map<String, dynamic> versiculoDoDia(
      List<dynamic> versiculos, DateTime hoje) {
    final inicioDoAno = DateTime(hoje.year, 1, 1);
    final diaDoAno = hoje.difference(inicioDoAno).inDays + 1;
    final semana = (diaDoAno - 1) ~/ 7;
    final diaDaSemana = hoje.weekday - 1; // segunda=0 ... domingo=6
    final indice = (semana * 7 + diaDaSemana) % versiculos.length;
    return versiculos[indice] as Map<String, dynamic>;
  }

  /// Texto de um versículo da Bíblia: livro, capítulo (1-based), versículo (1-based).
  static String? versiculoBiblia(
      List<dynamic> biblia, String livro, int capitulo, int versiculo) {
    for (final l in biblia) {
      if (l['name'] == livro) {
        final caps = l['chapters'] as List<dynamic>;
        if (capitulo < 1 || capitulo > caps.length) return null;
        final versos = caps[capitulo - 1] as List<dynamic>;
        if (versiculo < 1 || versiculo > versos.length) return null;
        return versos[versiculo - 1] as String;
      }
    }
    return null;
  }
}
