FROM serversideup/php:8.5-fpm-nginx-alpine AS base

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
    docker-php-serversideup-set-file-permissions --owner $UID:$GID --service fpm && \
    docker-php-serversideup-set-file-permissions --owner $UID:$GID --service nginx

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

# Install nodejs, npm and puppeteer
RUN if [ $INSTALAR_PDF_TOOLS = true ]; then \
        apk update && \
        apk --no-cache add npm && \
        rm -f /var/cache/apk/* && \
        npm install -g puppeteer && \
        npm install -g npm \
    ;fi

USER www-data

#APP
FROM base AS dev

USER root

# Instalo aplicaciones básicas para facilitar el uso de la consola
RUN apk update && \
    apk --no-cache add bash nano && \
    rm -f /var/cache/apk/*

USER www-data
RUN echo 'alias pint="/var/www/html/vendor/bin/pint"' >> ~/.bashrc

#PROD
FROM base AS prod