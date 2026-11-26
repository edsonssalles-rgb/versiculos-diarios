# Como criar o repositório no GitHub (conta edsonssalles-rgb)

O repositório **não foi criado** — nesta VM o GitHub não está logado
(`gh auth status` = "You are not logged into any GitHub hosts").
Criar o repositório precisa ser feito no MacBook do Edson (ou com o login dele).

## Opção 1 — pelo terminal, no MacBook (com o `gh` logado)

```sh
cd versiculos-diarios-app
gh auth login            # só na primeira vez; escolher GitHub.com, HTTPS, login no navegador
gh repo create versiculos-diarios --public --source=. --remote=origin --push
```

## Opção 2 — pelo site do GitHub

1. Entrar em https://github.com/new (logado como edsonssalles-rgb).
2. Nome do repositório: `versiculos-diarios` (público).
3. Não marcar "Add a README" (o projeto já tem um).
4. Depois, no terminal, dentro da pasta do projeto:

```sh
git init
git add .
git commit -m "Versículos Diários — Fase 1: Bíblia ARC, lista de 90 versículos de prova, fichas de ajuda em rascunho, esqueleto Flutter"
git branch -M main
git remote add origin https://github.com/edsonssalles-rgb/versiculos-diarios.git
git push -u origin main
```

## Depois de criar

- O projeto continua local até o primeiro `push`.
- Nada é publicado em loja nem na web por criar o repositório — é só o código versionado.
