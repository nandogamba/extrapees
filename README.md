# Tech Challenge Fase 1: triagem de risco de alteração glicêmica

Modelo de classificação binária que estima, a partir de um questionário respondido pelo paciente,
se vale a pena encaminhá-lo para um exame de glicemia. É uma ferramenta de **triagem**: o médico
sempre tem a palavra final.

| Resultado no conjunto de teste | |
|---|---|
| Modelo | Random Forest, limiar 0,461 |
| Recall da classe positiva | 79,5% |
| Precisão da classe positiva | 30,6% |
| F1 da classe positiva | 0,442 |
| Accuracy | 68,8% |
| AUC | 0,807 |
| Pacientes encaminhados | 40,4% |

## Onde está cada coisa

- [`notebooks/tc1_diabetes.ipynb`](notebooks/tc1_diabetes.ipynb): todo o trabalho, da carga à discussão crítica, já com os resultados
- [`docs/relatorio_tecnico.md`](docs/relatorio_tecnico.md): relatório técnico
- [`docs/decisoes.md`](docs/decisoes.md): registro das decisões
- [`reports/figures/`](reports/figures): gráficos gerados

## Como executar

### Com Docker

```bash
docker build -t tc1-diabetes .
docker run --rm --user "$(id -u):$(id -g)" -v "$(pwd)/reports:/app/reports" tc1-diabetes
```

O notebook é executado do início ao fim. A versão com os resultados é salva em
`reports/tc1_diabetes_executado.ipynb`, e os gráficos, em `reports/figures/`.

### Sem Docker (Python 3.12)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
jupyter lab notebooks/tc1_diabetes.ipynb
```

## Dados

O repositório inclui `dataset/processed/brfss2015_recorte.parquet` (2 MB), com as 11 colunas usadas
e nenhum tratamento, então nenhum download é necessário.

Para refazer o recorte a partir do dado original, baixe o
[BRFSS 2015 do CDC](https://www.cdc.gov/brfss/annual_data/annual_2015.html) (arquivo SAS Transport),
coloque o `LLCP2015.XPT` em `dataset/raw/`, apague o recorte e execute o notebook.
