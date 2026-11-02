# CLAUDE.md — Tech Challenge Fase 1 (FIAP PosTech IA para Devs)

## Modo de trabalho: PROJETO DE ESTUDO

Este projeto é, antes de tudo, um exercício de aprendizado. O objetivo não é só entregar o
trabalho, é entender cada etapa e o porquê de cada decisão.

Regras para o Claude Code:

1. **Não implemente etapas inteiras sozinho.** Trabalhe uma etapa de cada vez, só quando eu pedir.
2. **Explique antes de codar.** Antes de escrever código, explique o conceito, as alternativas
   possíveis e os trade-offs. Espere eu escolher.
3. **Prefira que eu escreva o código.** Seu papel padrão é orientar e revisar. Quando eu pedir
   explicitamente para você escrever, faça em blocos pequenos e comente o que cada bloco faz e por quê.
4. **Faça perguntas que me façam pensar** antes de entregar respostas prontas (ex.: "o que você
   espera ver nessa distribuição?").
5. **Aponte armadilhas** (vazamento de dados, métrica enganosa, viés) quando elas aparecerem,
   mesmo que eu não pergunte.
6. **Registre decisões.** Toda decisão relevante (o que remover, como codificar, qual métrica)
   deve ir para `docs/decisoes.md` com a justificativa, porque isso alimenta o relatório técnico.
7. Responda em **português**.

## O desafio

Sistema de apoio à triagem para um hospital: classificação binária "tem / não tem diabetes"
com dados tabulares, usando ML clássico. O médico sempre tem a palavra final; o modelo é
ferramenta de **triagem de risco**, não de diagnóstico.

Requisitos do enunciado (checklist):

- [ ] Discussão do problema e do dataset escolhido
- [ ] Exploração: estatísticas descritivas, distribuições, discussão dos resultados
- [ ] Limpeza: valores ausentes e inconsistentes
- [ ] Pipeline de pré-processamento em Python (conversão de categóricas/numéricas)
- [ ] Análise de correlação
- [ ] 2+ modelos de classificação (ex.: Regressão Logística, Árvore, KNN, Random Forest)
- [ ] Separação clara treino / validação / teste
- [ ] Avaliação com métricas adequadas (accuracy, recall, F1), com justificativa da escolha
- [ ] Interpretação: feature importance e SHAP
- [ ] Discussão crítica: o modelo pode ser usado na prática? Como?
- [ ] (Extra, opcional) CNN com imagens médicas

Entregáveis:

- [ ] Repositório Git com código-fonte completo e documentado
- [ ] Dockerfile + README.md com instruções de execução
- [ ] Dataset ou link para download
- [ ] Resultados (gráficos, prints, análises)
- [ ] Relatório técnico: pré-processamento, modelos e por quê, resultados e interpretação
- [ ] Vídeo de demonstração (até 15 min, YouTube/Vimeo)
- [ ] PDF final com os links

## Dados

- `dataset/raw/LLCP2015.XPT`: BRFSS 2015 bruto do CDC (~440 mil linhas, ~330 colunas).
  Formato SAS Transport, lido com `pd.read_sas(..., format="xport")`.
  - Codebook oficial do CDC em `docs/` (consultar antes de interpretar qualquer variável).
  - Códigos especiais comuns: 7/77 = "não sabe", 9/99 = "recusou", 88/888 = "nenhum/zero",
    BLANK = não perguntado. Esses códigos **não são valores numéricos válidos** e precisam de
    tratamento explícito.
  - O notebook trabalha com um recorte de 11 colunas em `dataset/processed/`, gerado do XPT
    só se ainda não existir.
- Dados brutos **não vão para o Git** (`.gitignore`); o README traz o link de download. A
  exceção é o recorte de 2 MB, para o notebook rodar sem download.

## Convenções técnicas

- Python 3.11+, pandas, numpy, scikit-learn, matplotlib/seaborn, shap, pyarrow.
- `random_state=42` em tudo que for aleatório.
- Split **estratificado** treino / validação / teste, feito **antes** de qualquer transformação
  que aprenda dos dados (imputação, scaling, encoding, balanceamento).
- Pré-processamento sempre dentro de `sklearn.pipeline.Pipeline` / `ColumnTransformer`,
  ajustado apenas no treino.
- Desbalanceamento: tratar **só no treino**, com `class_weight="balanced"`.
  Validação e teste mantêm a proporção real da população.
- Ajuste de hiperparâmetros e de limiar de decisão na **validação**; o teste é usado uma única
  vez, no final.
- Métrica principal: recall/F1 da classe positiva (em triagem, um falso negativo custa mais
  que um falso alarme). Accuracy só como referência, nunca isolada.
- SHAP e KNN: usar amostras quando o volume tornar o cálculo lento, e documentar isso.

## Estrutura do projeto

Tudo em um único notebook, com as bibliotecas e os métodos vistos nas aulas (ver D14 em `docs/decisoes.md`).

```
TC1/
├── CLAUDE.md
├── README.md
├── Dockerfile
├── requirements.txt / requirements-dev.txt
├── dataset/
│   ├── raw/          # LLCP2015.XPT (fora do Git)
│   └── processed/    # brfss2015_recorte.parquet (2 MB, versionado)
├── notebooks/
│   └── tc1_diabetes.ipynb
├── reports/figures/
└── docs/
    ├── decisoes.md
    ├── plano.md
    └── relatorio_tecnico.md
```
