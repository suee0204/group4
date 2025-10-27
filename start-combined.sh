#!/bin/bash
# Start both IoT and Web services

echo "Starting Combined Fire Alert System (IoT + Web)..."

# Set environment variables for supervisor
export START_IOT=true
export START_WEB=true

# Start supervisor with both services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf