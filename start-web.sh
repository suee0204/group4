#!/bin/bash
# Start Web service only

echo "Starting Flask Web Application..."

# Set environment variables for supervisor
export START_IOT=false
export START_WEB=true

# Start supervisor with Web service only
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf