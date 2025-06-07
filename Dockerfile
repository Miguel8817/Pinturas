FROM python:3.11-slim

WORKDIR /app

# Instalación de dependencias nativas para flask_mysqldb
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el resto de la app
COPY . .

# Puerto
EXPOSE ${PORT:-5000}

# Comando para correr
CMD ["gunicorn", "--bind", "0.0.0.0:${PORT:-5000}", "--workers", "4", "app:app"]
