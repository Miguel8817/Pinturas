FROM python:3.11-slim

WORKDIR /app

# 1. Instala TODAS las dependencias necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    default-libmysqlclient-dev \
    libssl-dev \
    zlib1g-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuración esencial
ENV PYTHONUNBUFFERED=1

# 3. Instalación DIRECTA de mysqlclient primero
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir wheel && \
    pip install --no-cache-dir mysqlclient==2.2.0 --no-build-isolation

# 4. Copia requirements.txt
COPY requirements.txt .

# 5. Instala el resto
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copia la aplicación
COPY . .

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]