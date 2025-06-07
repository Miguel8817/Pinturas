FROM python:3.11-slim

WORKDIR /app

# 1. Instala dependencias del sistema (git, git-lfs y libs necesarias)
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    build-essential \
    libffi-dev \
    libssl-dev \
    default-libmysqlclient-dev \
    pkg-config \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

# 2. Copia SOLO requirements.txt
COPY requirements.txt .

# 3. Instalación de dependencias Python
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# 4. Copia el resto de la app (incluye .git)
COPY . .

# 5. Comando de ejecución con git-lfs pull y gunicorn
CMD ["sh", "-c", "git lfs pull && gunicorn --bind 0.0.0.0:${PORT:-5000} --workers 4 app:app"]
