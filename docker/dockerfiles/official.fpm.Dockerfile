FROM php:8.4-fpm-alpine AS base

#Asigno parámetros a entorno
ARG UID
ARG GID
ARG INSTALAR_SOAP
ARG INSTALAR_GD
ARG INSTALAR_IMAGICK
ARG INSTALAR_BACKUP_TOOLS

# Directorio de trabajo
WORKDIR /var/www/html

# Instalo aplicaciones basicas
RUN apk update && \
    apk --no-cache add bash nano && \
    rm -f /var/cache/apk/*

# Install dependencies
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions pdo pdo_mysql pdo_sqlite zip intl redis opcache bcmath

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
    rm -f /var/cache/apk/* && \
    install-php-extensions pcntl \
;fi

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Agrego usuario y grupo para aplicación
RUN addgroup --gid $GID www
RUN adduser --disabled-password --uid $UID --ingroup www www

#Cambio permisos de carpeta de ejecución
RUN chown www:www /var/www

COPY ./docker/scripts/start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
CMD ["/usr/local/bin/start"]

#APP
FROM base AS app
#Cambio a usuario de ejecución si no es scheduler
USER www

#WORKER
FROM app AS worker

#SCHEDULER
FROM app AS scheduler
USER root

RUN apk update && \
    apk --no-cache add supercronic && \
    rm -f /var/cache/apk/*

RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run" >> /etc/crontabs/www

RUN chown www:www /etc/crontabs/www

#Cambio a usuario de ejecución si no es scheduler
USER www