FROM serversideup/php:8.5-cli-alpine AS base

#Asigno parámetros a entorno
ARG UID
ARG GID
ARG INSTALAR_SOAP
ARG INSTALAR_GD
ARG INSTALAR_IMAGICK
ARG INSTALAR_BACKUP_TOOLS
ARG INSTALAR_PDF_TOOLS


# Cambio a root para definir UID y GID
USER root

# Defino UID y GID
RUN docker-php-serversideup-set-id www-data $UID:$GID  && \
    docker-php-serversideup-set-file-permissions --owner $UID:$GID --service cli

# Install dependencies
RUN install-php-extensions intl bcmath

# Para usar SOAP (Ej. AFIP)
RUN if [ $INSTALAR_SOAP = true ]; then \
      install-php-extensions soap \
    ;fi

# Para usar GD (trabajar con imágenes)
RUN if [ $INSTALAR_GD = true ]; then \
      install-php-extensions gd \
    ;fi

# Para usar imagick (trabajar con imágenes avanzado)
RUN if [ $INSTALAR_IMAGICK = true ]; then \
      install-php-extensions imagick \
    ;fi

# Para realizar backups (mysqldump) desde el contenedor, también debe instalarse 'pcntl, para el Spatie laravel-backup
RUN if [ $INSTALAR_BACKUP_TOOLS = true ]; then \
        apk update && \
        apk add --no-cache mariadb-client && \
        rm -f /var/cache/apk/* \
    ;fi

USER www-data

#SCHEDULER
FROM base AS scheduler

USER root

RUN apk update && \
    apk --no-cache add supercronic && \
    rm -f /var/cache/apk/*

RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run" >> /etc/crontabs/www

RUN chown www-data:www-data /etc/crontabs/www

COPY ./docker/scripts/start.scheduler.sh /usr/local/bin/start.scheduler.sh
RUN chmod +x /usr/local/bin/start.scheduler.sh

#Cambio a usuario de ejecución si no es scheduler
USER www-data

ENTRYPOINT ["/usr/local/bin/start.scheduler.sh"]
CMD ["supercronic", "-passthrough-logs", "/etc/crontabs/www"]

#WORKER
FROM base AS worker
USER root
COPY ./docker/scripts/start.worker.sh /usr/local/bin/start.worker.sh
RUN chmod +x /usr/local/bin/start.worker.sh
USER www-data
ENTRYPOINT ["sh", "/usr/local/bin/start.worker.sh"]
CMD ["php", "/var/www/html/artisan", "queue:work", "--tries=3"]
