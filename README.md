# Smart Fire Alert System

A comprehensive IoT-based fire detection and alert system with web interface, designed for Raspberry Pi hardware integration.

## 🔥 System Overview

The Smart Fire Alert System consists of multiple components:

1. **IoT Fire Detection Service** - Hardware-integrated fire detection using sensors
2. **Flask Web Application** - Web interface for firefighter management and monitoring
3. **MySQL Database** - Firefighter data storage
4. **Alert System** - Real-time notifications via Telegram

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Sensors   │────│  Fire Detection │────│   Web Interface │
│  (Raspberry Pi) │    │    Service      │    │   (Flask API)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                └───────────────────────┼──── MySQL Database
                                                        │
                                                        └──── Telegram Alerts
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Raspberry Pi (for IoT functionality)
- MySQL database access

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd smart-fire-alert-system
   git submodule update --init --recursive
   ```

2. **Start the entire system:**
   ```bash
   # Production deployment
   docker-compose up -d
   
   # Development mode
   docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
   ```

3. **Initialize the database:**
   ```bash
   docker-compose exec web-app python -c "from App import db; db.create_all()"
   ```

4. **Access the application:**
   - Web Interface: http://localhost:5000
   - Database: localhost:3306
   - Redis Cache: localhost:6379

## 📁 Project Structure

```
smart-fire-alert-system/
├── src/
│   ├── Main.py              # IoT main application
│   ├── App.py               # Flask web application
│   ├── AlertSystem.py       # Fire detection logic
│   ├── TempSmoke.py         # Temperature and smoke sensors
│   ├── PiCam.py            # Camera functionality
│   ├── RemoteAccess.py     # Telegram notifications
│   ├── hal/                # Hardware Abstraction Layer
│   ├── templates/          # HTML templates
│   ├── static/             # Static web assets
│   ├── on-duty.sql         # Database initialization
│   └── off-duty.sql        # Database initialization
├── Dockerfile.iot          # IoT service container
├── Dockerfile.web          # Web service container
├── docker-compose.yml      # Production configuration
├── docker-compose.dev.yml  # Development overrides
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables

#### Web Application (Flask)
```bash
FLASK_ENV=production          # production/development
FLASK_DEBUG=0                 # 0/1
SQLALCHEMY_DATABASE_URI=mysql+pymysql://webapp:password@mysql-db:3306/firefighters
```

#### IoT Application
```bash
PYTHONUNBUFFERED=1           # Enable real-time logging
DEBUG=1                      # Enable debug mode (development)
```

#### Database (MySQL)
```bash
MYSQL_ROOT_PASSWORD=passworddevops3321
MYSQL_DATABASE=firefighters
MYSQL_USER=webapp
MYSQL_PASSWORD=passworddevops3321
```

### Telegram Bot Configuration

Update `src/RemoteAccess.py` with your bot credentials:
```python
TOKEN = "YOUR_BOT_TOKEN"      # Replace with your Telegram bot token
chat_id = "YOUR_CHAT_ID"      # Replace with your chat ID
```

## 🌐 API Documentation

### REST API Endpoints

#### Fire Status API
```http
GET /api/fire-status
```

**Description:** Get current fire detection status

**Response:**
```json
{
  "value": true,
  "status": "success"
}
```

**Example Usage:**
```bash
curl -X GET http://localhost:5000/api/fire-status
```

```javascript
// JavaScript/AJAX
fetch('/api/fire-status')
  .then(response => response.json())
  .then(data => console.log('Fire status:', data.value));
```

```python
# Python requests
import requests
response = requests.get('http://localhost:5000/api/fire-status')
data = response.json()
print(f"Fire detected: {data['value']}")
```

#### Web Interface Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home page |
| `/page2.html` | GET | Fire detection dashboard |
| `/page3.html` | GET | System monitoring |
| `/page4.html` | GET | Settings |
| `/page5.html` | GET | On-duty firefighters |
| `/page6.html` | GET | Off-duty firefighters |

### Database API (SQLAlchemy)

#### Firefighter Model
```python
from App import Firefighter, db

# Create a new firefighter
firefighter = Firefighter(
    name="John Doe",
    area="Zone A",
    status="On-Duty",
    password="secret123"
)
db.session.add(firefighter)
db.session.commit()

# Query firefighters
on_duty = Firefighter.query.filter(Firefighter.status.ilike('On-Duty')).all()
off_duty = Firefighter.query.filter(Firefighter.status.ilike('Off-Duty')).all()
```

## 🔌 Hardware Integration

### Supported Sensors

| Component | HAL Module | Description |
|-----------|------------|-------------|
| Temperature/Humidity | `hal_temp_humidity_sensor` | DHT22 sensor |
| IR Sensor | `hal_ir_sensor` | Infrared flame detection |
| Camera | `picamera2` | Raspberry Pi camera |
| LED | `hal_led` | Status indicators |
| LCD Display | `hal_lcd` | 16x2 character display |
| Buzzer | `hal_buzzer` | Audio alerts |
| Servo Motor | `hal_servo` | Automated responses |
| DC Motor | `hal_dc_motor` | Fan/ventilation control |

### GPIO Configuration

The IoT application requires access to GPIO pins:
```bash
# Grant GPIO access to Docker container
docker run --device=/dev/gpiomem:/dev/gpiomem --privileged smart-fire-iot
```

### Camera Setup

For Raspberry Pi camera functionality:
```bash
# Enable camera interface
sudo raspi-config
# Navigate to Interfacing Options > Camera > Enable

# Test camera
libcamera-still -o test.jpg
```

## 🚀 Deployment Options

### 1. Docker Compose (Recommended)

**Production:**
```bash
docker-compose up -d
```

**Development:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

**Specific Services:**
```bash
# Web application only
docker-compose up -d web-app mysql-db

# IoT application only (Raspberry Pi)
docker-compose up -d iot-app
```

### 2. Individual Docker Containers

**Web Application:**
```bash
docker build -f Dockerfile.web -t smart-fire-web .
docker run -p 5000:5000 \
  -e SQLALCHEMY_DATABASE_URI=mysql+pymysql://webapp:password@host:3306/firefighters \
  smart-fire-web
```

**IoT Application:**
```bash
docker build -f Dockerfile.iot -t smart-fire-iot .
docker run --privileged --device=/dev/gpiomem:/dev/gpiomem \
  smart-fire-iot
```

### 3. Native Python Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Install HAL modules
cd src/hal
pip install -e .

# Run applications
python src/App.py      # Web application
python src/Main.py     # IoT application
```

## 🔍 Monitoring and Logging

### Health Checks

Both applications include health checks:
```bash
# Check web application health
curl -f http://localhost:5000/

# Check container health
docker ps
docker-compose ps
```

### Logging

View application logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web-app
docker-compose logs -f iot-app

# Follow logs in real-time
docker logs -f smart-fire-web
docker logs -f smart-fire-iot
```

### Database Management

```bash
# Access MySQL shell
docker-compose exec mysql-db mysql -u webapp -p firefighters

# Backup database
docker-compose exec mysql-db mysqldump -u webapp -p firefighters > backup.sql

# Restore database
docker-compose exec -T mysql-db mysql -u webapp -p firefighters < backup.sql
```

## 🧪 Testing

### Unit Tests

```bash
# Run tests in container
docker-compose exec web-app python -m pytest

# Run specific test file
docker-compose exec web-app python -m pytest test_main.py

# Run with coverage
docker-compose exec web-app python -m pytest --cov=.
```

### Manual Testing

```bash
# Test fire detection manually
docker-compose exec iot-app python -c "
from AlertSystem import alert
print('Fire detected:', alert())
"

# Test camera capture
docker-compose exec iot-app python -c "
from PiCam import photo
photo()
print('Photo captured')
"

# Test Telegram notification
docker-compose exec iot-app python -c "
from RemoteAccess import sendMsg
result = sendMsg()
print('Message sent:', result)
"
```

## 🔒 Security Considerations

### Production Deployment

1. **Change default passwords:**
   ```bash
   # Update database passwords in docker-compose.yml
   MYSQL_ROOT_PASSWORD=your_secure_password
   MYSQL_PASSWORD=your_secure_password
   ```

2. **Use environment files:**
   ```bash
   # Create .env file
   echo "MYSQL_PASSWORD=secure_password" > .env
   echo "TELEGRAM_TOKEN=your_bot_token" >> .env
   ```

3. **Enable HTTPS:**
   ```bash
   # Configure nginx with SSL certificates
   # Update nginx.conf with SSL settings
   ```

4. **Firewall configuration:**
   ```bash
   # Limit port access
   ufw allow 22     # SSH
   ufw allow 80     # HTTP
   ufw allow 443    # HTTPS
   ufw enable
   ```

## 🐛 Troubleshooting

### Common Issues

**1. GPIO Permission Denied:**
```bash
# Solution: Run with privileged mode
docker run --privileged --device=/dev/gpiomem smart-fire-iot
```

**2. Camera Not Working:**
```bash
# Check camera interface
vcgencmd get_camera

# Enable camera
sudo raspi-config
```

**3. Database Connection Failed:**
```bash
# Check MySQL service
docker-compose logs mysql-db

# Verify network connectivity
docker-compose exec web-app ping mysql-db
```

**4. Web Application 500 Error:**
```bash
# Check application logs
docker-compose logs web-app

# Initialize database
docker-compose exec web-app python -c "from App import db; db.create_all()"
```

### Performance Optimization

**1. Resource Limits:**
```yaml
# Add to docker-compose.yml
services:
  web-app:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

**2. Database Optimization:**
```sql
-- Optimize MySQL configuration
SET GLOBAL innodb_buffer_pool_size = 128M;
SET GLOBAL max_connections = 100;
```

## 📚 Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Raspberry Pi GPIO Pinout](https://pinout.xyz/)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the troubleshooting section above

---

**Note:** This system is designed for educational and demonstration purposes. For production fire safety systems, ensure compliance with local fire safety regulations and standards.