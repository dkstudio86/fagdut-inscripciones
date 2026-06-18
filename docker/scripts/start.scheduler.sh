#!/bin/sh

# Start the scheduler
sleep 5
echo "Starting scheduler..."
#supercronic -passthrough-logs /etc/crontabs/www
exec "$@"
