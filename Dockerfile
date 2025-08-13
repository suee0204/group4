# ------------------------------------------
# Smart Fire Alert System - Production Image
# ------------------------------------------

# Base image - change to an arm build (e.g. python:3.11-slim-bullseye)
# if you plan to deploy on a Raspberry-Pi.
FROM python:3.11-slim

# --------------------------------------------------------------------
# Install OS packages required by Python wheels & optional camera stack
# --------------------------------------------------------------------
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        libatlas-base-dev \
        libjpeg-dev \
        libcamera-dev \
        libv4l-dev \
        libssl-dev \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------------
# Create an unprivileged user (recommended for production usage)
# -------------------------------------------------------------
RUN useradd -ms /bin/bash appuser
WORKDIR /app
USER appuser

# ------------------------------------------------------------------
# Copy Python dependency descriptors first to leverage layer caching
# ------------------------------------------------------------------
COPY requirements.txt ./

# -----------------------------
# Install Python dependencies
# -----------------------------
RUN pip install --no-cache-dir -r requirements.txt

# -----------------------
# Copy application source
# -----------------------
COPY . .

# Expose Flask default port
EXPOSE 5000

# -----------------------------
# Default start-up instruction
# -----------------------------
# For production you may want to use Gunicorn instead:
#   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "src.App:app"]
CMD ["python", "src/App.py"]