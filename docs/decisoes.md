# Log de decisões

Registro das decisões relevantes do projeto, com a justificativa de cada uma. Este arquivo
alimenta o relatório técnico.

Modelo de entrada:

```
## DNN: título curto
- **Data:** AAAA-MM-DD
- **Fase:** N
- **Contexto:** que problema ou pergunta motivou a decisão
- **Alternativas consideradas:** o que mais poderia ter sido feito
- **Decisão:** o que foi escolhido
- **Justificativa:** por quê
- **Consequências:** o que essa decisão implica nas próximas fases
```

---

## D01: Ambiente virtual com `venv`

- **Data:** 2026-10-27
- **Fase:** 0
- **Contexto:** o projeto precisa de um ambiente isolado e reproduzível, e também por Docker.
- **Alternativas consideradas:** `conda`/`mamba`, `uv`.
- **Decisão:** `venv` (da biblioteca padrão) com Python 3.12.
- **Justificativa:** já é familiar e não exige instalar nada. Todas as dependências (pandas,
  scikit-learn, shap, pyarrow) têm wheels no pip, então não há dependência nativa que
  justifique o conda. Integra direto com `requirements.txt` e com uma imagem `python:3.12-slim`.
- **Consequências:** a versão do Python é a do sistema (3.12.3), o que atende ao requisito
  de 3.11+. O conda só seria reavaliado no caso da CNN com GPU (extra opcional).

## D02: Dados e codebook fora do Git

- **Data:** 2026-10-27
- **Fase:** 0
- **Contexto:** o XPT bruto tem ~1,1 GB, os CSVs de referência ~50 MB e o codebook ~7 MB.
- **Alternativas consideradas:** versionar os arquivos menores (CSVs, codebook) ou usar Git LFS.
- **Decisão:** nada de `dataset/` nem o codebook vai para o Git. A estrutura de pastas é
  mantida com `.gitkeep`, e o README traz os links de download (CDC e Kaggle).
- **Justificativa:** são dados públicos com fonte oficial estável. Versioná-los incharia o
  repositório sem ganho.
- **Consequências:** o pipeline XPT → interim → processed precisa ser **100% reproduzível**
  pelos notebooks, sem nenhum passo manual.

## D03: Recorte do produto, questionário de pré-consulta

- **Data:** 2026-10-27
- **Fase:** 0 (definição do problema)
- **Contexto:** o enunciado pede um sistema de apoio à triagem hospitalar para diabetes.
  É preciso definir quem usa, quando e com que objetivo.
- **Decisão:** o modelo alimenta um **questionário respondido pelo paciente na sala de
  espera**, no intervalo entre o agendamento e a consulta. O resultado (risco estimado e
  fatores que mais pesaram) é entregue ao **médico**, que tem a palavra final.
- **Justificativa:**
  - O tempo ocioso de espera é pouco aproveitado, e a coleta estruturada de dados apoia
    qualquer diagnóstico. Esse questionario pode vir por meio de um tablet oferecido pela própria clinica ou por um link enviado para o whatsapp do cliente enquanto ele aguarda o atendimento.
  - O foco é **trazer à luz** o risco em pessoas que ainda não sabem que o estilo de vida as
    coloca em risco. Neste caso, podemos abrangir para atendimentos médicos de diferentes especialidades.
  - O BRFSS também é autodeclarado, então o tipo de dado no treino é o mesmo que o
    questionário vai coletar.
  - O contexto de espera permite um questionário mais longo que um app de autoavaliação.
- **Consequências:**
  - **Features:** só entram variáveis que o paciente consegue responder. As variáveis do
    módulo de diabetes do BRFSS (insulina, idade do diagnóstico, exames de pé e de olho
    etc.) devem ser excluídas por **vazamento do alvo**.
  - **Público-alvo:** pacientes **sem** diagnóstico prévio. Quem já é diabético não precisa
    da triagem.
  - **Métrica:** recall da classe positiva como métrica principal. Um falso positivo custa
    uma glicemia de jejum; um falso negativo é um risco não sinalizado. O limiar é ajustado
    na validação para não gerar alarmes demais.
  - **Interpretabilidade:** o médico precisa ver *por que* o paciente foi sinalizado
    (SHAP individual, Fase 6), inclusive para identificar vieses do modelo.
  - **Limitações para o relatório:** mudança de população (BRFSS é a população geral, a sala
    de espera é uma população clínica), alvo autodeclarado (diabéticos não diagnosticados
    aparecem como negativos) e causalidade reversa (quem já foi diagnosticado muda de hábito).

D04
 - Foi optado separar em dois arquivos requirements.txt. Um para o desenvolvimento contendo o Jupyter (mais competo/pesado) outro só para execução e validação do código.

 Contexto: o freeze tinha ~110 pacotes, a maioria do Jupyter. Então foi optado separar para dar a opção de executar somente o fonte sem executar o notebook.
O Docker run executar completo com o notebook para facilitar a avaliação dos resultados.
---

## Notas rápidas (formalizar depois no modelo acima)

- D04 requirements: separado em `requirements.txt` (execução) e `requirements-dev.txt` (Jupyter); só os pacotes diretos fixados.
- D05 Docker: o container executa os notebooks 01→06. Pendente: como ele obtém os dados (volume ou download) e qual requirements entra na imagem.
- D06 conversão: XPT lido inteiro (opção A) e salvo em Parquet em `dataset/interim/`; o texto é decodificado na leitura.
- D07 caminhos: a raiz do projeto é descoberta subindo os diretórios até achar o `requirements.txt` (cobre o local e o Docker; o Colab fica fora do escopo).
- D08 alvo: `DIABETE3` NaN (7), 7 = não sabe (598) e 9 = recusou (193) → linhas descartadas, pois não há como recuperar o rótulo (~0,2% da base). **Positivo = códigos 1 (diabetes), 2 (gestacional) e 4 (pré-diabetes); negativo = código 3.** Justificativa: em triagem, o falso positivo custa uma glicemia barata e o falso negativo adia um diagnóstico; o pré-diabetes e o histórico gestacional são justamente os casos em que vale checar. Consequências: o alvo passa a ser "alteração glicêmica atual ou passada" (e não "tem diabetes", como no enunciado ao pé da letra; justificar no relatório); a prevalência sobe para ~15–16%; o resultado vai divergir do Kaggle na Fase 3. ⚠️ Risco de viés: o código 2 é só de mulheres, em geral mais jovens → na Fase 6, verificar o SHAP de `SEX`/idade e as métricas por sexo.
- D09 saída do produto (ideia): risco em 5 níveis (1 = muito baixo ... 5 = muito alto), derivado da probabilidade do classificador binário. Os cortes são por **risco absoluto** e não por quantis ("pacientes com este perfil têm diabetes em ~X de cada 10 casos"), porque é mais útil para o médico e mantém o significado numa população diferente da do BRFSS. Consequências: calibração obrigatória (curva de calibração + `CalibratedClassifierCV`); os cortes são definidos na validação; os níveis terão tamanhos diferentes. Considerado e descartado: quantis, que fixariam 40% de encaminhamentos e chamariam de "alta" probabilidades baixas.
- D10 causalidade reversa nos hábitos: bebedor pesado tem prevalência MENOR (7,4% vs 16,2%). Provável causa: quem é diagnosticado muda de hábito (bebe menos, come melhor), além do efeito "sick quitter" e da idade. O treino retrata o diabético DEPOIS do diagnóstico, mas o produto atende quem ainda não foi diagnosticado (descompasso entre treino e uso). A pergunta "já foi diagnosticado?" filtra o uso, mas não corrige o treino. Opções: (A) preferir features que o diagnóstico não muda; (B) treinar só com os diagnosticados recentes via `DIABAGE2` (filtro de linhas, não feature); (C) aceitar e documentar; (D) A + B como experimento comparativo. **Decisão: C (aceitar e documentar)**, pelo prazo. A causalidade reversa é uma hipótese plausível, mas não demonstrada: os dados mostram só a associação, e o quanto os hábitos mudam depois do diagnóstico varia muito. Vai para o relatório como limitação, com a D como trabalho futuro. Na Fase 6, o SHAP das variáveis de hábito deve ser apresentado ao médico como associação, não como efeito causal. **Verificação por idade (`_AGEG5YR`):** a diferença persiste dentro de cada faixa etária (exceto 18–24 anos, em que é igual: 1,8% vs 1,9%) e cresce com a idade (35–39: 7,3% vs 4,7%; 60–64: 20,6% vs 9,3%). A idade não explica sozinha; o padrão é consistente com a causalidade reversa (mais idade → mais tempo desde o diagnóstico). Extras: a idade é um preditor forte (1,8% → 25%), e a prevalência cai no 80+, provável viés de sobrevivência.
- D11 exercício (`EXERANY2`, 1 = sim, 2 = não; codificação INVERSA à do `_RFDRHV5`): quem não se exercita tem mais alteração glicêmica em todas as faixas etárias (×1,3 aos 18–24 → ~×1,6 dos 50 aos 64). Diferente do álcool, a diferença já existe nos mais jovens, antes de haver diagnósticos acumulados → sugere uma associação anterior ao diagnóstico. Hipótese (não verificável com dado transversal): a diferença real é maior, pois diagnosticados que passaram a se exercitar "contaminam" o grupo "sim".
- D12 seleção de features (Fase 1, versão 1): `_AGEG5YR`, `SEX`, `_BMI5` ou `_BMI5CAT`, `_SMOKER3`, `EXERANY2`, `_RFDRHV5`, `_RFHYPE5`, `_RFCHOL`, `GENHLTH`, `DIFFWALK`. Critérios: uma variável por tema, preferindo as calculadas pelo CDC (códigos limpos, sem ausência estrutural); o paciente consegue responder num tablet; sem vazamento. O IMC é calculado pelo sistema a partir do peso e da altura informados (mesma fórmula do CDC no treino e no uso). Ressalvas (D10, associação e não causa): `GENHLTH` (o diagnóstico muda a autoavaliação de saúde), `DIFFWALK` (pode ser consequência: neuropatia, obesidade, idade), `_RFDRHV5`, `EXERANY2`. Excluídas: `_MICHD`, `CVDSTRK3` e `CHCKIDNY` (são também consequências do diabetes → risco de vazamento); `HLTHPLN1` (mede acesso ao diagnóstico, não saúde: quem não tem plano tem menos diagnóstico, e o alvo é autodeclarado); `_INCOMG` e `_EDUCAG` (risco de discriminação socioeconômica e questionário mais invasivo). Diverge do Kaggle, que mantém as cardíacas, AVC, renda e escolaridade → comparar na Fase 3.
- D13 `_RFCHOL` vazio: só existe para quem já mediu o colesterol (`BLOODCHO = 1`). O vazio (59 mil, 13%) vira a categoria "nunca mediu", e não NaN, pois é ausência estrutural e provavelmente se associa ao acesso ao diagnóstico.
