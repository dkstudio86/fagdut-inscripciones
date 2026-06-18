# FAGDUT - Envío de Fondos

## Pasos

- Clonar repositorio
- Copiar .env.example a .env y configurar según necesidades.
```sh
cp .env.example .env
```
- Copiar "docker-compose.ssu.fpm.yml" a "docker-compose.yml"
```sh
cp docker-compose.ssu.fpm.yml docker-compose.yml
```
- Levantar docker
```sh
docker-compose up
```
- Instalar Laravel y agregados
```sh
docker exec -ti <name>_app sh
composer install
exit
```
- Copiar .env.example a .env en la carpeta "code" y configurar según necesidades.
```sh
cp code/.env.example code/.env
```
- Ejecutar migraciones y seeds
```sh
docker exec -ti <name>_app sh
php artisan key:generate
php artisan migrate
php artisan db:seed
exit
```
- Generar documentación de API
```sh
docker exec -ti <name>_app bash
php artisan optimize
php artisan scribe:generate --force
exit
```

## Documentación de API

Con el stack iniciado acceder a:
[https://localhost/docs](http://localhost/docs "https://localhost/docs")