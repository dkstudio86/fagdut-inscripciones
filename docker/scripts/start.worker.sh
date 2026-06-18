#!/usr/bin/sh

# Start the worker
sleep 5
echo "Starting worker..."
#php /var/www/html/artisan queue:work --tries=3
exec "$@"
