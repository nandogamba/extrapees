# Plano do projeto: Tech Challenge Fase 1

Marque `[x]` conforme as tarefas forem concluídas. Uma fase só está concluída quando
todas as tarefas dela estiverem marcadas e as decisões tiverem sido registradas em
[`decisoes.md`](decisoes.md).

## Status geral

- [ ] Fase 0: Ambiente e estrutura
- [ ] Fase 1: Primeiro contato com o bruto
- [ ] Fase 2: Limpeza
- [ ] Fase 3: Comparação com o gabarito (Kaggle)
- [ ] Fase 4: EDA
- [ ] Fase 5: Modelagem
- [ ] Fase 6: Interpretação e discussão crítica
- [ ] Fase 7: Entrega

---

## Fase 0: Ambiente e estrutura

Objetivo: ambiente reproduzível e repositório seguro, sem dados grandes no Git.

- [x] Renomear `dataset/raw/LLCP2015.XPT␣` (tem um espaço no final do nome) para `LLCP2015.XPT`
- [x] Criar o ambiente virtual (`python3 -m venv .venv`) e ativá-lo
- [x] Criar o `.gitignore` (`.venv/`, dados brutos e intermediários, caches, checkpoints do Jupyter)
- [x] Rodar `git init` **depois** do `.gitignore` e conferir com `git status` que nenhum dado aparece
- [ ] Criar as pastas da estrutura (`notebooks/`, `src/`, `reports/figures/`, `dataset/interim/`, `dataset/processed/`)
- [ ] Instalar as dependências e gerar o `requirements.txt` com as versões fixadas
- [ ] Testar o kernel do Jupyter apontando para o `.venv`
- [ ] Criar o `docs/decisoes.md` e registrar a decisão do ambiente (venv) e da fixação de versões
- [x] Primeiro commit

## Fase 1: Primeiro contato com o bruto (`01_exploracao_raw.ipynb`)

Objetivo: entender **como os dados chegam**, sem interpretar ainda.

- [ ] Ler o XPT uma única vez e salvar em Parquet (`dataset/interim/`)
- [ ] `head()`, `shape`, `info()`, `dtypes`, uso de memória
- [ ] Consultar o codebook (`docs/codebook15_llcp.pdf`) e identificar a variável-alvo (`DIABETE3`)
- [ ] Ver a distribuição bruta do alvo (`value_counts`, incluindo os códigos 7/9 e os vazios)
- [ ] Selecionar as colunas candidatas a features, com justificativa
- [ ] Registrar as decisões

## Fase 2: Limpeza (`02_limpeza.ipynb`)

Objetivo: transformar os códigos do CDC em valores com significado. Nesta fase só se remove
ou recodifica; **imputação fica para o pipeline** (Fase 5), para não vazar informação.

- [ ] Mapear os códigos especiais por variável (7/77/9/99 → ausente, 88/888 → zero etc.)
- [ ] Definir o alvo binário (o que fazer com pré-diabetes e com diabetes gestacional?)
- [ ] Tratar valores inconsistentes (fora das faixas do codebook)
- [ ] Quantificar os ausentes por coluna e decidir: remover linhas, remover colunas ou deixar para imputar
- [ ] Mover funções reutilizáveis para `src/`
- [ ] Salvar o dataset limpo em `dataset/processed/`
- [ ] Registrar as decisões

## Fase 3: Comparação com o gabarito (`03_comparacao_reference.ipynb`)

Objetivo: validar a limpeza contra os CSVs do Kaggle e **explicar** cada diferença.

- [ ] Comparar o número de linhas e a proporção de positivos
- [ ] Comparar a distribuição de cada coluna em comum
- [ ] Documentar as diferenças e as prováveis causas
- [ ] Registrar as decisões (manter a própria limpeza ou ajustar?)

## Fase 4: EDA (`04_eda.ipynb`)

- [ ] Estatísticas descritivas
- [ ] Distribuições (univariadas e por classe do alvo)
- [ ] Análise do desbalanceamento
- [ ] Análise de correlação (com o alvo e entre as features)
- [ ] Salvar os gráficos em `reports/figures/`
- [ ] Discussão escrita dos achados

## Fase 5: Modelagem (`05_modelagem.ipynb`)

- [ ] Split estratificado treino / validação / teste (`random_state=42`), **antes** de qualquer transformação
- [ ] Pipeline de pré-processamento (`Pipeline` + `ColumnTransformer`, ajustado só no treino)
- [ ] Baseline (classificador trivial) para ter um ponto de referência
- [ ] 2 ou mais modelos (ex.: Regressão Logística, Árvore, Random Forest, KNN)
- [ ] Tratamento do desbalanceamento só no treino (`class_weight` ou SMOTE)
- [ ] Ajuste de hiperparâmetros e do limiar de decisão na validação
- [ ] Avaliação final no teste (**uma única vez**)
- [ ] Justificar as métricas (recall e F1 da classe positiva; accuracy só como referência)

## Fase 6: Interpretação e discussão (`06_interpretacao.ipynb`)

- [ ] Feature importance
- [ ] SHAP (com amostra, se necessário, e documentar isso)
- [ ] Discussão crítica: o modelo pode ser usado na prática? Com qual limiar? Que vieses tem?

## Fase 7: Entrega

- [ ] README.md com as instruções de execução e o link do dataset
- [ ] Dockerfile testado do zero
- [ ] Relatório técnico
- [ ] Vídeo de demonstração (até 15 min)
- [ ] PDF final com os links
- [ ] (Extra, opcional) CNN com imagens médicas
