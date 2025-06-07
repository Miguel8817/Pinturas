FROM python:3.11-slim

WORKDIR /app

# 1. Instala todas las dependencias de compilación necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    python3-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuración del entorno Python
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 3. Copia solo requirements.txt primero
COPY requirements.txt .

# 4. Instalación en dos etapas con verificación
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir wheel && \
    pip install --no-cache-dir mysqlclient==2.2.0

# 5. Instala el resto de dependencias
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copia el resto de la aplicación
COPY . .

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]