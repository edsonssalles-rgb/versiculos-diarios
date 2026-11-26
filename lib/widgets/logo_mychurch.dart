import 'package:flutter/material.dart';

/// Logo do MyChurch: quadrado azul profundo com cantos arredondados
/// e a letra "M" branca em negrito — igual ao cabeçalho do mockup.
/// É um widget (sem arquivo de imagem), então funciona em qualquer tamanho.
class LogoMyChurch extends StatelessWidget {
  const LogoMyChurch({super.key, this.tamanho = 56});

  /// Lado do quadrado em pixels lógicos.
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A5B),
        borderRadius: BorderRadius.circular(tamanho * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        'M',
        style: TextStyle(
          color: Colors.white,
          fontSize: tamanho * 0.55,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
