FROM python:3.12-slim

WORKDIR /app

# HOME gravável permite rodar o container com o usuário do host (--user)
ENV HOME=/tmp

COPY requirements.txt requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt

COPY . .

# Executa o notebook do início ao fim e salva a versão com os resultados em reports/
CMD ["jupyter", "nbconvert", "--to", "notebook", "--execute", "notebooks/tc1_diabetes.ipynb", "--output-dir", "reports", "--output", "tc1_diabetes_executado.ipynb"]
