# INFRASTRUCTURE & ENVIRONMENT CONTEXT

## Project Structure
Este proyecto se ejecuta en un entorno Dockerizado (ServerSideUp Images).
La raíz del repositorio contiene carpetas de infraestructura (`docker`, `nginx`, `dbdata`).
**El código de la aplicación Laravel reside exclusivamente en la carpeta: `./code/`.**

## Command Execution Rules
NO tengo PHP ni Composer instalados en mi máquina local (host).
Todos los comandos deben ejecutarse a través de Docker Compose.

Cuando sugieras comandos de terminal, sigue estrictamente estas reglas:

1. **Artisan & PHP:**
   En lugar de `php artisan ...`, genera:
   `docker compose exec -u www-data app php artisan ...`

2. **Composer:**
   En lugar de `composer require ...`, genera:
   `docker compose exec -u www-data app composer require ...`

3. **NPM/Node (si aplica):**
   `docker compose exec -u www-data app npm ...`

4. **Testing (Pest/PHPUnit):**
   `docker compose exec -u www-data app php artisan test`

5. **Utilizar el Model Context Protocol (MCP):**
   `docker compose exec -u www-data app php artisan mcp ...`

6. **Otros comandos relacionados con la aplicación:**
   Siempre usa `docker compose exec -u www-data app ...`

Un caso especial es la ejecución de Laravel Pint, ya que al correr el entorno en un contenedor docker, este no tiene información de GIT, por lo que no puede determinar los archivos modificados. En este caso, el comando recomendado es:
`docker compose exec -u www-data app vendor/bin/pint --format agent`
SIN la opción '--dirty'

## File Paths
Si necesitas referenciar una ruta absoluta del servidor (dentro del contenedor), la base es `/var/www/html`.
Ejemplo: Lo que en el editor ves como `code/storage/logs/laravel.log`, en el contenedor es `/var/www/html/storage/logs/laravel.log`.