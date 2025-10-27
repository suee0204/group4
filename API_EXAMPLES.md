# Smart Fire Alert System - API Examples and Usage Guide

This document provides comprehensive examples for all public APIs, functions, and components in the Smart Fire Alert System.

## 📋 Table of Contents

1. [REST API Examples](#rest-api-examples)
2. [Hardware API Examples](#hardware-api-examples)
3. [Database API Examples](#database-api-examples)
4. [Alert System Examples](#alert-system-examples)
5. [Camera API Examples](#camera-api-examples)
6. [Telegram Integration Examples](#telegram-integration-examples)
7. [Web Interface Integration](#web-interface-integration)

## 🌐 REST API Examples

### Fire Status API

#### Basic Usage
```bash
# Get current fire detection status
curl -X GET http://localhost:5000/api/fire-status

# Response
{
  "value": true,
  "status": "success"
}
```

#### JavaScript/AJAX Integration
```javascript
// Simple fetch
async function checkFireStatus() {
    try {
        const response = await fetch('/api/fire-status');
        const data = await response.json();
        
        if (data.status === 'success') {
            console.log('Fire detected:', data.value);
            return data.value;
        }
    } catch (error) {
        console.error('Error checking fire status:', error);
        return null;
    }
}

// Real-time monitoring with intervals
function startFireMonitoring() {
    setInterval(async () => {
        const fireDetected = await checkFireStatus();
        
        if (fireDetected) {
            alert('🔥 FIRE DETECTED! Please evacuate immediately!');
            // Trigger additional actions
            updateFireStatus(true);
            playAlarmSound();
        }
    }, 5000); // Check every 5 seconds
}

// jQuery implementation
$('#check-fire-btn').click(function() {
    $.ajax({
        url: '/api/fire-status',
        method: 'GET',
        success: function(data) {
            if (data.value) {
                $('#fire-indicator').addClass('fire-detected');
                $('#fire-message').text('FIRE DETECTED!');
            } else {
                $('#fire-indicator').removeClass('fire-detected');
                $('#fire-message').text('All Clear');
            }
        },
        error: function(xhr, status, error) {
            console.error('Error:', error);
            $('#fire-message').text('Status Unknown');
        }
    });
});
```

#### Python Client Examples
```python
import requests
import time
import json
from datetime import datetime

class FireAlertClient:
    def __init__(self, base_url='http://localhost:5000'):
        self.base_url = base_url
        
    def get_fire_status(self):
        """Get current fire detection status"""
        try:
            response = requests.get(f'{self.base_url}/api/fire-status')
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error getting fire status: {e}")
            return None
    
    def monitor_continuously(self, interval=5, callback=None):
        """Monitor fire status continuously"""
        print(f"Starting fire monitoring (checking every {interval}s)")
        
        while True:
            status = self.get_fire_status()
            if status:
                timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                fire_detected = status.get('value', False)
                
                print(f"[{timestamp}] Fire Status: {'🔥 DETECTED' if fire_detected else '✅ Clear'}")
                
                if callback and fire_detected:
                    callback(status)
                    
            time.sleep(interval)

# Usage examples
client = FireAlertClient()

# Single check
status = client.get_fire_status()
print(f"Fire detected: {status['value'] if status else 'Unknown'}")

# Continuous monitoring with callback
def fire_alert_callback(status):
    print("🚨 FIRE ALERT TRIGGERED!")
    # Send email, SMS, or other notifications
    
client.monitor_continuously(interval=10, callback=fire_alert_callback)
```

## 🔌 Hardware API Examples

### Temperature and Smoke Sensor
```python
from TempSmoke import get_temp_state, get_ir_sensor_state

def monitor_sensors():
    """Monitor temperature and smoke sensors"""
    
    # Get individual sensor readings
    temp_alert = get_temp_state()
    smoke_detected = get_ir_sensor_state()
    
    print(f"Temperature Alert: {temp_alert}")
    print(f"Smoke Detected: {smoke_detected}")
    
    # Combined fire detection logic
    if temp_alert and smoke_detected:
        print("🔥 FIRE DETECTED: Both temperature and smoke!")
        return True
    elif temp_alert:
        print("⚠️ High temperature detected")
        return False
    elif smoke_detected:
        print("⚠️ Smoke detected")
        return False
    else:
        print("✅ All sensors normal")
        return False

# Continuous monitoring
import time

def sensor_monitoring_loop():
    while True:
        fire_detected = monitor_sensors()
        
        if fire_detected:
            # Trigger alert actions
            trigger_fire_alert()
            
        time.sleep(2)  # Check every 2 seconds
```

### HAL (Hardware Abstraction Layer) Examples
```python
from hal import hal_led as led
from hal import hal_lcd as LCD
from hal import hal_buzzer as buzzer
from hal import hal_servo as servo
from hal import hal_dc_motor as dc_motor

def initialize_hardware():
    """Initialize all hardware components"""
    print("Initializing hardware components...")
    
    # Initialize HAL modules
    led.init()
    buzzer.init()
    servo.init()
    dc_motor.init()
    
    # Initialize LCD
    lcd = LCD.lcd()
    lcd.lcd_clear()
    lcd.lcd_display_string("System Ready", 1)
    
    print("Hardware initialization complete")
    return lcd

def fire_alert_sequence(lcd):
    """Execute fire alert hardware sequence"""
    
    # Sound buzzer alarm
    buzzer.beep(0.1, 0.1, 5)  # 5 short beeps
    
    # Flash LED warning
    for i in range(10):
        led.set_output(1, 1)  # LED on
        time.sleep(0.2)
        led.set_output(1, 0)  # LED off
        time.sleep(0.2)
    
    # Display alert message
    lcd.lcd_clear()
    lcd.lcd_display_string("FIRE DETECTED!", 1)
    lcd.lcd_display_string("EVACUATE NOW!", 2)
    
    # Activate servo (emergency valve/door)
    servo.set_servo_position(160)
    time.sleep(2)
    
    # Start ventilation fan
    dc_motor.set_motor_speed(75)

def normal_operation_sequence(lcd):
    """Reset to normal operation"""
    
    # Clear displays
    lcd.lcd_clear()
    lcd.lcd_display_string("System Normal", 1)
    lcd.lcd_display_string("Have a nice day", 2)
    
    # Turn off LED
    led.set_output(1, 0)
    
    # Reset servo position
    servo.set_servo_position(75)
    
    # Stop fan
    dc_motor.set_motor_speed(0)

# Main hardware control loop
def hardware_control_loop():
    lcd = initialize_hardware()
    
    while True:
        # Check sensor status
        fire_detected = monitor_sensors()
        
        if fire_detected:
            fire_alert_sequence(lcd)
        else:
            normal_operation_sequence(lcd)
            
        time.sleep(1)
```

## 💾 Database API Examples

### Firefighter Management
```python
from App import app, db, Firefighter
from flask import Flask

def database_examples():
    """Examples of database operations"""
    
    with app.app_context():
        # Create database tables
        db.create_all()
        
        # Add new firefighter
        new_firefighter = Firefighter(
            name="John Smith",
            area="Zone A",
            status="On-Duty",
            password="secure123"
        )
        db.session.add(new_firefighter)
        db.session.commit()
        print(f"Added firefighter: {new_firefighter.name}")
        
        # Query all firefighters
        all_firefighters = Firefighter.query.all()
        print(f"Total firefighters: {len(all_firefighters)}")
        
        # Query on-duty firefighters
        on_duty = Firefighter.query.filter(
            Firefighter.status.ilike('On-Duty')
        ).all()
        print(f"On-duty firefighters: {len(on_duty)}")
        
        # Query off-duty firefighters
        off_duty = Firefighter.query.filter(
            Firefighter.status.ilike('Off-Duty')
        ).all()
        print(f"Off-duty firefighters: {len(off_duty)}")
        
        # Update firefighter status
        firefighter = Firefighter.query.filter_by(name="John Smith").first()
        if firefighter:
            firefighter.status = "Off-Duty"
            db.session.commit()
            print(f"Updated {firefighter.name} status to {firefighter.status}")
        
        # Delete firefighter
        firefighter_to_delete = Firefighter.query.filter_by(name="John Smith").first()
        if firefighter_to_delete:
            db.session.delete(firefighter_to_delete)
            db.session.commit()
            print(f"Deleted firefighter: {firefighter_to_delete.name}")

# Batch operations
def batch_operations():
    """Batch database operations"""
    
    with app.app_context():
        # Add multiple firefighters
        firefighters = [
            Firefighter(name="Alice Johnson", area="Zone A", status="On-Duty", password="pass1"),
            Firefighter(name="Bob Wilson", area="Zone B", status="Off-Duty", password="pass2"),
            Firefighter(name="Carol Davis", area="Zone C", status="On-Duty", password="pass3"),
        ]
        
        db.session.add_all(firefighters)
        db.session.commit()
        print(f"Added {len(firefighters)} firefighters")
        
        # Bulk status update
        Firefighter.query.filter_by(area="Zone A").update({"status": "On-Duty"})
        db.session.commit()
        print("Updated all Zone A firefighters to On-Duty")

# Custom queries
def custom_queries():
    """Advanced database queries"""
    
    with app.app_context():
        # Count by status
        on_duty_count = Firefighter.query.filter_by(status="On-Duty").count()
        off_duty_count = Firefighter.query.filter_by(status="Off-Duty").count()
        
        print(f"On-Duty: {on_duty_count}, Off-Duty: {off_duty_count}")
        
        # Search by name pattern
        search_results = Firefighter.query.filter(
            Firefighter.name.like('%John%')
        ).all()
        print(f"Found {len(search_results)} firefighters with 'John' in name")
        
        # Get firefighters by area
        zone_a_firefighters = Firefighter.query.filter_by(area="Zone A").all()
        for ff in zone_a_firefighters:
            print(f"Zone A: {ff.name} - {ff.status}")
```

## 🚨 Alert System Examples

### Comprehensive Alert System
```python
from AlertSystem import alert
from RemoteAccess import sendMsg
from PiCam import photo
import time
from datetime import datetime

class ComprehensiveAlertSystem:
    def __init__(self):
        self.alert_active = False
        self.last_alert_time = None
        self.alert_count = 0
        
    def check_fire_status(self):
        """Check if fire is detected"""
        return alert()
    
    def trigger_alert(self):
        """Trigger comprehensive fire alert"""
        self.alert_active = True
        self.alert_count += 1
        self.last_alert_time = datetime.now()
        
        print(f"🔥 FIRE ALERT #{self.alert_count} - {self.last_alert_time}")
        
        # Capture photo evidence
        try:
            photo()
            print("📸 Photo captured successfully")
        except Exception as e:
            print(f"❌ Photo capture failed: {e}")
        
        # Send Telegram notification
        try:
            sendMsg()
            print("📱 Telegram notification sent")
        except Exception as e:
            print(f"❌ Telegram notification failed: {e}")
        
        # Log alert to file
        self.log_alert()
        
    def log_alert(self):
        """Log alert to file"""
        log_entry = f"{self.last_alert_time}: Fire Alert #{self.alert_count}\n"
        
        try:
            with open("fire_alerts.log", "a") as f:
                f.write(log_entry)
        except Exception as e:
            print(f"❌ Failed to log alert: {e}")
    
    def reset_alert(self):
        """Reset alert status"""
        if self.alert_active:
            print("✅ Fire alert cleared")
            self.alert_active = False
    
    def monitor_continuously(self):
        """Continuous monitoring loop"""
        print("Starting continuous fire monitoring...")
        
        while True:
            fire_detected = self.check_fire_status()
            
            if fire_detected and not self.alert_active:
                self.trigger_alert()
            elif not fire_detected and self.alert_active:
                self.reset_alert()
            
            time.sleep(2)  # Check every 2 seconds

# Usage
alert_system = ComprehensiveAlertSystem()
alert_system.monitor_continuously()

# Advanced alert with conditions
def advanced_alert_logic():
    """Advanced alert logic with multiple conditions"""
    
    consecutive_detections = 0
    detection_threshold = 3  # Require 3 consecutive detections
    
    while True:
        fire_detected = alert()
        
        if fire_detected:
            consecutive_detections += 1
            print(f"Fire detection {consecutive_detections}/{detection_threshold}")
            
            if consecutive_detections >= detection_threshold:
                print("🔥 CONFIRMED FIRE - Triggering full alert")
                # Trigger full alert sequence
                photo()
                sendMsg()
                consecutive_detections = 0  # Reset counter
        else:
            consecutive_detections = 0  # Reset on clear reading
            
        time.sleep(1)
```

## 📸 Camera API Examples

### Camera Functionality
```python
from PiCam import photo
import time
from datetime import datetime
import os

def basic_photo_capture():
    """Basic photo capture"""
    try:
        photo()
        print("Photo captured successfully")
    except Exception as e:
        print(f"Photo capture failed: {e}")

def timestamped_photo_capture():
    """Capture photo with timestamp"""
    from picamera2 import Picamera2
    
    try:
        picam2 = Picamera2()
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"fire_alert_{timestamp}.jpg"
        
        camera_config = picam2.create_still_configuration(
            main={"size": (1920, 1080)},
            lores={"size": (640, 480)},
            display="lores"
        )
        picam2.configure(camera_config)
        picam2.start()
        time.sleep(2)  # Allow camera to warm up
        
        picam2.capture_file(f"static/{filename}")
        picam2.stop()
        
        print(f"Photo saved as: {filename}")
        return filename
        
    except Exception as e:
        print(f"Timestamped photo capture failed: {e}")
        return None

def continuous_photo_monitoring():
    """Continuous photo capture when fire detected"""
    
    while True:
        if alert():  # Fire detected
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"fire_evidence_{timestamp}.jpg"
            
            try:
                timestamped_photo_capture()
                print(f"Fire evidence captured: {filename}")
                
                # Wait before next capture to avoid flooding
                time.sleep(30)
            except Exception as e:
                print(f"Failed to capture fire evidence: {e}")
        
        time.sleep(5)  # Check every 5 seconds

# Photo management utilities
def clean_old_photos(max_age_days=7):
    """Clean up old photos"""
    import os
    import time
    
    static_dir = "static"
    current_time = time.time()
    max_age_seconds = max_age_days * 24 * 60 * 60
    
    for filename in os.listdir(static_dir):
        if filename.endswith('.jpg'):
            file_path = os.path.join(static_dir, filename)
            file_age = current_time - os.path.getmtime(file_path)
            
            if file_age > max_age_seconds:
                os.remove(file_path)
                print(f"Deleted old photo: {filename}")

def get_latest_photo():
    """Get the latest captured photo"""
    static_dir = "static"
    jpg_files = [f for f in os.listdir(static_dir) if f.endswith('.jpg')]
    
    if jpg_files:
        latest_file = max(jpg_files, key=lambda f: os.path.getmtime(os.path.join(static_dir, f)))
        return latest_file
    return None
```

## 📱 Telegram Integration Examples

### Enhanced Telegram Notifications
```python
import requests
from datetime import datetime
import json

class TelegramAlertBot:
    def __init__(self, token, chat_id):
        self.token = token
        self.chat_id = chat_id
        self.base_url = f"https://api.telegram.org/bot{token}"
    
    def send_message(self, message):
        """Send text message"""
        url = f"{self.base_url}/sendMessage"
        params = {
            'chat_id': self.chat_id,
            'text': message,
            'parse_mode': 'HTML'
        }
        
        try:
            response = requests.get(url, params=params)
            return response.json()
        except Exception as e:
            print(f"Failed to send message: {e}")
            return None
    
    def send_photo(self, photo_path, caption=""):
        """Send photo with caption"""
        url = f"{self.base_url}/sendPhoto"
        
        try:
            with open(photo_path, 'rb') as photo:
                files = {'photo': photo}
                data = {
                    'chat_id': self.chat_id,
                    'caption': caption
                }
                response = requests.post(url, files=files, data=data)
                return response.json()
        except Exception as e:
            print(f"Failed to send photo: {e}")
            return None
    
    def send_fire_alert(self, location="Unknown", severity="High"):
        """Send comprehensive fire alert"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        message = f"""
🔥 <b>FIRE ALERT</b> 🔥

📅 <b>Time:</b> {timestamp}
📍 <b>Location:</b> {location}
⚠️ <b>Severity:</b> {severity}
🚨 <b>Action:</b> Immediate evacuation required

Please respond to this emergency immediately!
        """
        
        return self.send_message(message)
    
    def send_status_update(self, sensors_data):
        """Send system status update"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        message = f"""
📊 <b>System Status Update</b>

📅 <b>Time:</b> {timestamp}
🌡️ <b>Temperature Alert:</b> {sensors_data.get('temp_alert', 'Unknown')}
💨 <b>Smoke Detected:</b> {sensors_data.get('smoke_detected', 'Unknown')}
🔄 <b>System Status:</b> {sensors_data.get('system_status', 'Operational')}
        """
        
        return self.send_message(message)

# Usage examples
bot = TelegramAlertBot(
    token="7996574904:AAEtvpuxFx859QUQ70BbENDrLT9oydtU358",
    chat_id="6644289057"
)

# Send fire alert
bot.send_fire_alert(location="Building A, Floor 2", severity="Critical")

# Send status update
sensors_data = {
    'temp_alert': True,
    'smoke_detected': True,
    'system_status': 'Alert Mode'
}
bot.send_status_update(sensors_data)

# Send photo evidence
latest_photo = get_latest_photo()
if latest_photo:
    bot.send_photo(
        f"static/{latest_photo}",
        caption="🔥 Fire evidence captured by security camera"
    )
```

## 🌐 Web Interface Integration

### JavaScript Frontend Examples
```javascript
class FireAlertDashboard {
    constructor() {
        this.isMonitoring = false;
        this.monitoringInterval = null;
        this.lastStatus = null;
    }
    
    async checkFireStatus() {
        try {
            const response = await fetch('/api/fire-status');
            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error checking fire status:', error);
            return null;
        }
    }
    
    updateStatusDisplay(status) {
        const statusElement = document.getElementById('fire-status');
        const timestampElement = document.getElementById('last-update');
        
        if (status && status.status === 'success') {
            const fireDetected = status.value;
            
            statusElement.textContent = fireDetected ? '🔥 FIRE DETECTED' : '✅ All Clear';
            statusElement.className = fireDetected ? 'alert-danger' : 'alert-success';
            
            timestampElement.textContent = `Last update: ${new Date().toLocaleString()}`;
            
            // Trigger alerts if fire detected
            if (fireDetected && !this.lastStatus) {
                this.triggerFireAlert();
            }
            
            this.lastStatus = fireDetected;
        } else {
            statusElement.textContent = '❓ Status Unknown';
            statusElement.className = 'alert-warning';
        }
    }
    
    triggerFireAlert() {
        // Visual alert
        document.body.classList.add('fire-alert');
        
        // Audio alert
        this.playAlarmSound();
        
        // Browser notification
        if (Notification.permission === 'granted') {
            new Notification('🔥 FIRE DETECTED!', {
                body: 'Immediate evacuation required!',
                icon: '/static/fire-icon.png'
            });
        }
        
        // Flash page title
        this.flashPageTitle();
    }
    
    playAlarmSound() {
        const audio = new Audio('/static/alarm.mp3');
        audio.loop = true;
        audio.play().catch(e => console.log('Audio play failed:', e));
    }
    
    flashPageTitle() {
        const originalTitle = document.title;
        let isFlashing = true;
        
        const flashInterval = setInterval(() => {
            document.title = isFlashing ? '🔥 FIRE ALERT! 🔥' : originalTitle;
            isFlashing = !isFlashing;
        }, 1000);
        
        // Stop flashing after 30 seconds
        setTimeout(() => {
            clearInterval(flashInterval);
            document.title = originalTitle;
        }, 30000);
    }
    
    startMonitoring(interval = 5000) {
        if (this.isMonitoring) return;
        
        this.isMonitoring = true;
        console.log(`Starting fire monitoring (${interval}ms interval)`);
        
        this.monitoringInterval = setInterval(async () => {
            const status = await this.checkFireStatus();
            this.updateStatusDisplay(status);
        }, interval);
        
        // Initial check
        this.checkFireStatus().then(status => this.updateStatusDisplay(status));
    }
    
    stopMonitoring() {
        if (!this.isMonitoring) return;
        
        this.isMonitoring = false;
        clearInterval(this.monitoringInterval);
        console.log('Fire monitoring stopped');
    }
}

// Initialize dashboard
const dashboard = new FireAlertDashboard();

// Start monitoring when page loads
document.addEventListener('DOMContentLoaded', () => {
    // Request notification permission
    if ('Notification' in window) {
        Notification.requestPermission();
    }
    
    // Start monitoring
    dashboard.startMonitoring(3000); // Check every 3 seconds
});

// Real-time updates with WebSocket (optional enhancement)
class RealTimeFireMonitor {
    constructor(websocketUrl) {
        this.websocket = null;
        this.websocketUrl = websocketUrl;
    }
    
    connect() {
        this.websocket = new WebSocket(this.websocketUrl);
        
        this.websocket.onopen = () => {
            console.log('WebSocket connected for real-time monitoring');
        };
        
        this.websocket.onmessage = (event) => {
            const data = JSON.parse(event.data);
            
            if (data.type === 'fire_status') {
                dashboard.updateStatusDisplay(data);
            }
        };
        
        this.websocket.onclose = () => {
            console.log('WebSocket disconnected, attempting reconnect...');
            setTimeout(() => this.connect(), 5000);
        };
    }
}
```

### HTML Integration Examples
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fire Alert Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .fire-alert {
            animation: flash 0.5s infinite alternate;
        }
        
        @keyframes flash {
            from { background-color: red; }
            to { background-color: darkred; }
        }
        
        .status-card {
            min-height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            border-color: #f5c2c7;
            color: #842029;
        }
        
        .alert-success {
            background-color: #d1e7dd;
            border-color: #badbcc;
            color: #0f5132;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <h1 class="text-center mb-4">🔥 Smart Fire Alert System</h1>
        
        <!-- Status Card -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="card status-card">
                    <div class="card-body text-center">
                        <h2 id="fire-status" class="alert alert-secondary">Checking status...</h2>
                        <p id="last-update" class="text-muted">Initializing...</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Control Buttons -->
        <div class="row mb-4">
            <div class="col-md-6">
                <button id="start-monitoring" class="btn btn-success w-100">
                    Start Monitoring
                </button>
            </div>
            <div class="col-md-6">
                <button id="stop-monitoring" class="btn btn-danger w-100">
                    Stop Monitoring
                </button>
            </div>
        </div>
        
        <!-- System Information -->
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Sensor Status</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-6">Temperature:</div>
                            <div class="col-6" id="temp-status">Normal</div>
                        </div>
                        <div class="row">
                            <div class="col-6">Smoke:</div>
                            <div class="col-6" id="smoke-status">Clear</div>
                        </div>
                        <div class="row">
                            <div class="col-6">Camera:</div>
                            <div class="col-6" id="camera-status">Ready</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>Latest Photo</h5>
                    </div>
                    <div class="card-body">
                        <img id="latest-photo" src="/static/test.jpg" 
                             class="img-fluid" alt="Latest capture">
                        <p class="text-muted mt-2">
                            <small id="photo-timestamp">Last captured: Unknown</small>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Initialize dashboard (using the JavaScript code from above)
        const dashboard = new FireAlertDashboard();
        
        // Button event listeners
        document.getElementById('start-monitoring').addEventListener('click', () => {
            dashboard.startMonitoring(2000);
        });
        
        document.getElementById('stop-monitoring').addEventListener('click', () => {
            dashboard.stopMonitoring();
        });
        
        // Auto-start monitoring
        dashboard.startMonitoring(5000);
    </script>
</body>
</html>
```

## 🔧 Configuration Examples

### Environment Configuration
```bash
# .env file for production
FLASK_ENV=production
FLASK_DEBUG=0
MYSQL_ROOT_PASSWORD=secure_password_here
MYSQL_PASSWORD=webapp_password_here
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# .env.development file
FLASK_ENV=development
FLASK_DEBUG=1
MYSQL_ROOT_PASSWORD=dev_password
MYSQL_PASSWORD=dev_password
LOG_LEVEL=DEBUG
```

### Docker Environment Variables
```yaml
# docker-compose.override.yml for custom settings
version: '3.8'
services:
  web-app:
    environment:
      - CUSTOM_ALERT_THRESHOLD=85
      - PHOTO_QUALITY=high
      - MONITORING_INTERVAL=3
  
  iot-app:
    environment:
      - SENSOR_SENSITIVITY=high
      - CAMERA_RESOLUTION=1920x1080
      - GPIO_MODE=BCM
```

This comprehensive API documentation provides detailed examples for all major components of the Smart Fire Alert System. Each section includes practical code examples that can be directly used or adapted for specific implementation needs.