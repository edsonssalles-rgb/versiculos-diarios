# Versículos Diários — app cristão (Fase 1)

Versículo diário de manhã, Bíblia Almeida Revista e Corrigida dentro do app,
ajuda por tema com respostas prontas e Pão Nosso (reflexão do dia, escrita pelo Edson).

## Estado atual (Fase 1 — 24/11/2026)

- [x] Bíblia ARC em JSON baixada do GitHub (thiagobodruk/bible, `pt_arc`):
      `assets/biblia/pt_arc.json` — 66 livros, 1.189 capítulos, 31.105 versículos.
- [x] Lista de 90 versículos diários **DE PROVA** (ciclo semanal seg–dom):
      `assets/versiculos/versiculos_90_prova.json` (+ CSV e MD na pasta do projeto).
      A versão final será definida pelo Edson, versículo por versículo.
- [x] 8 fichas de ajuda em **RASCUNHO** (aguardando aprovação/correção do Edson):
      `assets/ajuda/fichas_ajuda_rascunho.json`.
- [x] Espaço do Pão Nosso pronto (`assets/pao_nosso/`): as 90 reflexões são do
      Edson — o arquivo `pao_nosso.json` está vazio até ele mandar.
- [x] Esqueleto Flutter com 4 telas: Início, Bíblia, Ajuda, Pão Nosso.
- [ ] Build/teste: **não rodado nesta VM** — o Flutter não está instalado aqui.
      Rodar no MacBook do Edson (ver "Como rodar" abaixo).

## Como rodar (no MacBook)

```sh
# 1. Instalar o Flutter (uma vez só): https://docs.flutter.dev/get-started/install/macos
# 2. Entrar na pasta do projeto e baixar as dependências:
cd versiculos-diarios-app
flutter pub get

# 3. Rodar na web (grátis, sem loja):
flutter run -d chrome

# 4. Rodar no celular Samsung (Android, com o cabo USB ou Wi-Fi):
flutter run
```

## Estrutura

```
versiculos-diarios-app/
├── pubspec.yaml            # dependências gratuitas: flutter_tts, flutter_local_notifications
├── lib/
│   ├── main.dart           # app + navegação das 4 telas
│   ├── services/dados.dart # carrega Bíblia, versículos, fichas e Pão Nosso dos assets
│   └── screens/
│       ├── inicio.dart     # versículo do dia
│       ├── biblia.dart     # leitura da Bíblia (livro + capítulo)
│       ├── ajuda.dart      # fichas por tema
│       └── pao_nosso.dart  # reflexão do dia + botão de ouvir
└── assets/
    ├── biblia/pt_arc.json
    ├── versiculos/versiculos_90_prova.json
    ├── ajuda/fichas_ajuda_rascunho.json
    └── pao_nosso/
        ├── pao_nosso.json  # vazio até o Edson mandar as 90 reflexões
        └── README.md       # formato esperado das reflexões
```

## Custos

Zero para construir e lançar na web. Lojas só depois, se ele decidir:
Google Play US$ 25 (único), App Store US$ 99/ano. Doações fora das lojas
(botão "Quero abençoar este trabalho" → Ko-fi ou Stripe, para ele como pessoa física).

## O que ainda depende do Edson

- Pão Nosso: as 90 reflexões (ele escreve e manda).
- Versículos diários: definição final, versículo por versículo (a lista atual é de prova).
- Nome do aplicativo (sugestão atual: "Versículos Diários").
- Som de harpa/angelical da notificação da manhã (arquivo CC0 a escolher).
- Criar o repositório no GitHub (conta edsonssalles-rgb) — ver `COMO_CRIAR_REPOSITORIO.md`.
