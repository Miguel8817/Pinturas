FROM python:3.11-slim

WORKDIR /app

# 1. Instala solo dependencias esenciales del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 2. Copia requirements.txt primero (para cachear la instalación)
COPY requirements.txt .

# 3. Instala dependencias Python
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# 4. Copia el resto de la aplicación (EXCLUYENDO .git)
COPY . .

# 5. Comando de ejecución simplificado (sin git-lfs)
CMD ["gunicorn", "--bind", "0.0.0.0:${PORT:-5000}", "--workers", "4", "app:app"]