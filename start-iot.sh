#!/bin/bash
# Start IoT service only

echo "Starting IoT Fire Detection Service..."

# Set environment variables for supervisor
export START_IOT=true
export START_WEB=false

# Start supervisor with IoT service only
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf