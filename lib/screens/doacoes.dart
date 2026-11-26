import 'package:flutter/material.dart';

/// Tela Doação: as doações vão para o Edson como pessoa física
/// (não para a igreja) e ajudam a manter o aplicativo gratuito.
///
/// Ko-fi e Stripe: os links ainda não foram informados, por isso os
/// botões aparecem como "em breve" e desativados. Nenhum link foi
/// inventado aqui: quando o Edson mandar os links, esta tela é atualizada.
class TelaDoacoes extends StatelessWidget {
  const TelaDoacoes({super.key});

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
                'Doação',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Este aplicativo é gratuito. Se ele tem abençoado a sua '
                'vida, você pode contribuir para mantê-lo no ar. A doação '
                'vai direto para o Edson, como pessoa física.',
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
                          const Icon(Icons.coffee,
                              color: Color(0xFF0B2A5B)),
                          const SizedBox(width: 8),
                          Text(
                            'Ko-fi',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doe qualquer valor pelo Ko-fi — o link ainda não '
                        'foi informado, em breve este botão estará ativo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const FilledButton(
                        onPressed: null,
                        child: Text('Ko-fi — em breve'),
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
                          const Icon(Icons.credit_card,
                              color: Color(0xFF0B2A5B)),
                          const SizedBox(width: 8),
                          Text(
                            'Stripe',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doe com cartão pelo Stripe — o link ainda não foi '
                        'informado, em breve este botão estará ativo.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const FilledButton(
                        onPressed: null,
                        child: Text('Stripe — em breve'),
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
