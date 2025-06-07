FROM python:3.11-slim

WORKDIR /app

# 1. Instalación de dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuración del entorno
ENV PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production

# 3. Copia requirements.txt
COPY requirements.txt .

# 4. Instalación de dependencias de Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copia el código de la app
COPY . .

# 6. Puerto expuesto
EXPOSE 5000

# 7. Comando de ejecución
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
