# syntax=docker/dockerfile:1

FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install system dependencies (curl for health checks/logs; no heavy build deps needed)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python deps first for better layer caching
COPY requirements.api.txt /app/requirements.api.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.api.txt

# Copy application source
COPY src /app/src

# Default target: API service
FROM base AS api
WORKDIR /app/src
EXPOSE 8000
# Start the Flask app via gunicorn (module: App, app instance: app)
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "App:app"]

# Raspberry Pi Edge target (hardware-dependent)
FROM ghcr.io/raspberrypi/python:3.11-bookworm AS edge
WORKDIR /app
# System packages required for HAL and camera
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    python3-picamera2 \
    libcamera-apps \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.edge.txt /app/requirements.edge.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.edge.txt

COPY src /app/src
WORKDIR /app/src
CMD ["python", "Main.py"]