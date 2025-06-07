FROM python:3.11-slim

WORKDIR /app

# 1. Instalación de dependencias del sistema necesarias para compilar y para cryptography
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 2. Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    PORT=5000

# 3. Copiamos requirements primero (caché)
COPY requirements.txt .

# 4. Instalación de dependencias
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 5. Copiamos la app
COPY . .

# 6. Exponer el puerto
EXPOSE 5000

# 7. Comando de ejecución
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
