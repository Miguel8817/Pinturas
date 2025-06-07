FROM python:3.11-slim

WORKDIR /app

# 1. Instala PRIMERO las dependencias de compilación
RUN apt-get update && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuración del entorno Python
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 3. Copia solo requirements.txt primero
COPY requirements.txt .

# 4. Instalación específica para mysqlclient primero
RUN pip install --no-cache-dir mysqlclient==2.2.0 && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copia el resto de la aplicación
COPY . .

CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]