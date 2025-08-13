# Dockerfile Combination Guide

This guide explains different approaches to combine `Dockerfile.iot` and `Dockerfile.web` for the Smart Fire Alert System.

## 🎯 Approaches Overview

| Approach | Use Case | Advantages | Disadvantages |
|----------|----------|------------|---------------|
| **Single Combined** | Simple deployment, resource-constrained devices | Easy management, shared resources | Larger image, harder to scale individually |
| **Multi-stage Build** | Flexible deployment options | Optimized images, multiple targets | More complex build process |
| **Process Manager** | All-in-one solution with service control | Full control, service monitoring | Additional complexity |

## 📁 Files Created

- `Dockerfile.combined` - Single container with supervisor
- `Dockerfile.multistage` - Multi-stage build with multiple targets
- `supervisord.conf` - Process management configuration
- `start-*.sh` - Service startup scripts
- `docker-compose.combined.yml` - Orchestration for combined approach

## 🔧 Method 1: Single Combined Container (Recommended for Raspberry Pi)

### File: `Dockerfile.combined`

**Features:**
- Single container running both services
- Supervisor for process management
- Optimized for ARM architecture
- Flexible startup modes

**Build and Run:**
```bash
# Build the combined image
docker build -f Dockerfile.combined -t smart-fire-combined .

# Run both services (default)
docker run -it --privileged --device=/dev/gpiomem \
  -p 5000:5000 -p 8080:8080 \
  smart-fire-combined

# Run only IoT service
docker run -it --privileged --device=/dev/gpiomem \
  smart-fire-combined /usr/local/bin/start-iot.sh

# Run only Web service
docker run -it -p 5000:5000 \
  -e SQLALCHEMY_DATABASE_URI=mysql+pymysql://webapp:pass@host:3306/firefighters \
  smart-fire-combined /usr/local/bin/start-web.sh
```

**Docker Compose Usage:**
```bash
# Start combined service with database
docker-compose -f docker-compose.combined.yml up fire-alert-combined mysql-db
```

## 🏗️ Method 2: Multi-stage Build (Recommended for Production)

### File: `Dockerfile.multistage`

**Features:**
- Multiple build targets
- Optimized images for each use case
- Shared base layers for efficiency
- Separate IoT and Web variants

**Build Targets:**
```bash
# Build combined image (default)
docker build --target combined -t smart-fire-combined -f Dockerfile.multistage .

# Build IoT-only image
docker build --target iot-only -t smart-fire-iot -f Dockerfile.multistage .

# Build Web-only image  
docker build --target web-only -t smart-fire-web -f Dockerfile.multistage .
```

**Docker Compose with Profiles:**
```bash
# Run IoT-only service
docker-compose -f docker-compose.combined.yml --profile iot-only up

# Run Web-only service
docker-compose -f docker-compose.combined.yml --profile web-only up

# Run combined service
docker-compose -f docker-compose.combined.yml up fire-alert-combined mysql-db
```

## ⚙️ Method 3: Custom Process Management

### Configuration Files

**supervisord.conf** - Manages both processes:
```ini
[program:iot-service]
command=python Main.py
autostart=%(ENV_START_IOT)s

[program:web-service]
command=gunicorn --bind 0.0.0.0:5000 App:app
autostart=%(ENV_START_WEB)s
```

**Startup Scripts:**
- `start-combined.sh` - Both services
- `start-iot.sh` - IoT only
- `start-web.sh` - Web only

## 🚀 Usage Examples

### 1. Development on Raspberry Pi
```bash
# Combined container for development
docker run -it --privileged \
  --device=/dev/gpiomem \
  --device=/dev/i2c-1 \
  -p 5000:5000 \
  -v $(pwd)/src:/app/src \
  smart-fire-combined
```

### 2. Production Deployment
```bash
# Multi-stage approach with separate containers
docker-compose -f docker-compose.yml up  # Original separate services

# Or combined approach
docker-compose -f docker-compose.combined.yml up fire-alert-combined mysql-db
```

### 3. Cloud Deployment (without GPIO)
```bash
# Web-only for cloud deployment
docker build --target web-only -t smart-fire-web -f Dockerfile.multistage .
docker run -p 5000:5000 \
  -e SQLALCHEMY_DATABASE_URI=mysql://... \
  smart-fire-web
```

### 4. Edge Computing
```bash
# IoT-only for edge devices
docker build --target iot-only -t smart-fire-iot -f Dockerfile.multistage .
docker run --privileged --device=/dev/gpiomem smart-fire-iot
```

## 🔄 Service Control

### Supervisor Commands (in combined container)
```bash
# Enter the container
docker exec -it smart-fire-combined bash

# Control services
supervisorctl status
supervisorctl start iot-service
supervisorctl stop web-service
supervisorctl restart all

# View logs
supervisorctl tail iot-service
supervisorctl tail web-service
```

### Environment Variables for Control
```bash
# Control which services start
docker run \
  -e START_IOT=true \
  -e START_WEB=false \
  smart-fire-combined
```

## 📊 Comparison Matrix

### Resource Usage
| Method | Image Size | Memory Usage | CPU Usage | Complexity |
|--------|------------|--------------|-----------|------------|
| Combined | ~800MB | Medium | Medium | Low |
| Multi-stage Combined | ~800MB | Medium | Medium | Medium |
| Multi-stage IoT-only | ~400MB | Low | Low | Medium |
| Multi-stage Web-only | ~300MB | Low | Low | Medium |

### Deployment Scenarios
| Scenario | Recommended Method | Reason |
|----------|-------------------|---------|
| Raspberry Pi (development) | Combined | Simple, all-in-one |
| Raspberry Pi (production) | Multi-stage Combined | Optimized, flexible |
| Cloud deployment | Multi-stage Web-only | No hardware dependencies |
| Edge computing | Multi-stage IoT-only | Minimal footprint |
| Kubernetes | Multi-stage separate | Better scaling |

## 🛠️ Advanced Configurations

### 1. Custom Build Args
```dockerfile
# In Dockerfile.combined
ARG ENABLE_IOT=true
ARG ENABLE_WEB=true
ARG PYTHON_VERSION=3.9

FROM arm32v7/python:${PYTHON_VERSION}-slim-bullseye
```

```bash
# Build with custom args
docker build \
  --build-arg ENABLE_IOT=false \
  --build-arg ENABLE_WEB=true \
  -f Dockerfile.combined \
  -t smart-fire-web-only .
```

### 2. Health Checks for Combined Services
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || \
      python -c "import requests; requests.get('http://localhost:8080/status')" || \
      exit 1
```

### 3. Volume Sharing Between Services
```yaml
# docker-compose.combined.yml
volumes:
  - shared-data:/app/shared
  - ./logs:/app/logs
  - ./config:/app/config:ro
```

## 🔧 Troubleshooting

### Common Issues

**1. GPIO Permission Denied:**
```bash
# Add privileged mode and devices
docker run --privileged --device=/dev/gpiomem ...
```

**2. Service Won't Start:**
```bash
# Check supervisor logs
docker exec -it container supervisorctl tail -f iot-service
```

**3. Port Conflicts:**
```bash
# Use different ports
docker run -p 5001:5000 -p 8081:8080 ...
```

### Debugging Commands
```bash
# Check running processes in container
docker exec -it smart-fire-combined ps aux

# Check supervisor status
docker exec -it smart-fire-combined supervisorctl status

# View all logs
docker exec -it smart-fire-combined tail -f /tmp/*.log

# Test individual components
docker exec -it smart-fire-combined python -c "from AlertSystem import alert; print(alert())"
```

## 📝 Best Practices

### 1. **Use Multi-stage for Production**
- Optimized image sizes
- Separate concerns
- Better security

### 2. **Use Combined for Development**
- Simpler setup
- Easier debugging
- Faster iteration

### 3. **Environment-specific Configurations**
```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production with combined
docker-compose -f docker-compose.combined.yml up
```

### 4. **Security Considerations**
- Use non-root users
- Limit container privileges when possible
- Separate secrets management
- Regular security updates

## 🎯 Recommendations

### For Raspberry Pi Deployment:
```bash
# Use combined approach
docker build -f Dockerfile.combined -t smart-fire-pi .
docker run -d --restart=unless-stopped --privileged \
  --device=/dev/gpiomem \
  -p 5000:5000 \
  --name fire-alert-system \
  smart-fire-pi
```

### For Cloud/Server Deployment:
```bash
# Use multi-stage web-only
docker build --target web-only -f Dockerfile.multistage -t smart-fire-web .
# Deploy with proper database connection
```

### For Development:
```bash
# Use combined with volume mounts
docker-compose -f docker-compose.combined.yml \
  -f docker-compose.dev.yml up
```

This guide provides comprehensive options for combining the Dockerfiles based on your specific deployment needs and constraints.