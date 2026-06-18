#!/usr/bin/env sh

set -e

role=${CONTAINER_ROLE:-app}

sleep 5 # wait for the database to be ready

if [ "$role" = "app" ]; then

    echo "Running the app..."
    exec php-fpm

elif [ "$role" = "worker" ]; then

    echo "Running the queue..."
    php /var/www/html/artisan queue:work --verbose --tries=3

elif [ "$role" = "scheduler" ]; then
    echo "Running the scheduler..."
    supercronic /etc/crontabs/www

else
    echo "Could not match the container role \"$role\""
    exit 1
fi
