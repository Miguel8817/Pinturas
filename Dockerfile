FROM python:3.11-slim

WORKDIR /app

# 1. Instalación de dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuración del entorno
ENV PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production

# 3. Copiar y cachear dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 4. Copiar aplicación
COPY . .

# 5. Crear usuario no root
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# 6. Puerto expuesto
EXPOSE 5000

# 7. Comando de ejecución
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]
