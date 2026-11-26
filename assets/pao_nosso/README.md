# Pão Nosso — espaço reservado para as reflexões do Edson

As reflexões do Pão Nosso são escritas **pelo Edson** — o Johnnie não escreve o Pão Nosso.

## Como subir as reflexões

1. O Edson escreve as reflexões (ele vai mandar 90, para começar).
2. Cada reflexão vira um item no arquivo `pao_nosso.json`, nesta pasta, com este formato:

```json
{
  "dia": 1,
  "titulo": "Perseverar até o fim",
  "referencia": "Mateus 24:13",
  "texto": "Texto da reflexão, cerca de uma página (3 a 4 minutos de leitura), terminando com uma frase para guardar no dia."
}
```

3. O campo `dia` vai de 1 a 90 (depois, até 365). O aplicativo mostra a reflexão
   do dia do ano, ciclando pela lista enquanto houver menos de 365.
4. O botão de play da tela lê a reflexão em voz alta com a voz do sistema
   do celular (flutter_tts, gratuito).

## Regras

- Não misturar com o versículo do dia: o versículo sai como notificação de manhã;
  o Pão Nosso só aparece dentro do aplicativo, ao abrir.
- A pessoa só vê a reflexão do dia — as próximas ficam guardadas até a data delas.
- Modelo de cada reflexão: versículo em destaque, texto de uma página aplicando
  o trecho à vida da pessoa, e uma frase final para guardar no dia.
