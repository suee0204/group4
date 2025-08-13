# syntax=docker/dockerfile:1
FROM python:3.11-slim

# Install system packages (build tools and MySQL client libs)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        default-libmysqlclient-dev \
        pkg-config \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m appuser
WORKDIR /app

# Copy dependency file first to leverage Docker layer caching
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY src ./src
COPY docs ./docs
COPY MySQL ./MySQL
COPY src/templates ./src/templates
COPY src/static ./src/static

# Environment variables
ENV FLASK_APP=src/App.py \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Expose port
EXPOSE 8000

# Healthcheck (basic)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8000/ || exit 1

# Run with Gunicorn
# Binding to 0.0.0.0 makes the server accessible from outside the container
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--chdir", "/app", "src.App:app"]