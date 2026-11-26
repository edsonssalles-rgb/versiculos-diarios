import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tela Contato: como falar com o Edson.
///
/// E-mail: edsonssalles@gmail.com — botão "Copiar e-mail" copia o
/// endereço para a área de transferência e confirma com um aviso.
/// WhatsApp: o número ainda não foi informado, por isso o botão aparece
/// como "em breve" e desativado. Nenhum número foi inventado aqui:
/// quando o Edson mandar o número, esta tela é atualizada.
class TelaContato extends StatelessWidget {
  const TelaContato({super.key});

  static const _email = 'edsonssalles@gmail.com';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Contato',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Quer falar com o Edson, pedir oração ou contar o que Deus '
                'tem feito na sua vida? Estes são os canais de contato.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mail,
                              color: Color(0xFF0B2A5B)),
                          const SizedBox(width: 8),
                          Text(
                            'E-mail',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        _email,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: _email),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text('E-mail copiado.'),
                                ),
                              );
                          }
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copiar e-mail'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0B2A5B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chat,
                              color: Color(0xFF0B2A5B)),
                          const SizedBox(width: 8),
                          Text(
                            'WhatsApp',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'O número do WhatsApp ainda não foi informado — '
                        'em breve este botão estará ativo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const FilledButton(
                        onPressed: null,
                        child: Text('WhatsApp — em breve'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
