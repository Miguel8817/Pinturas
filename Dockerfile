FROM python:3.11-slim

WORKDIR /app

# 1. Configuración inicial del entorno
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 2. Instala dependencias del sistema COMPLETAS
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Copia solo requirements.txt primero
COPY requirements.txt .

# 4. Instalación robusta de dependencias
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --use-deprecated=legacy-resolver -r requirements.txt

# 5. Copia el resto de la aplicación
COPY . .

# 6. Comando de ejecución
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]