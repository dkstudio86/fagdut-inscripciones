FROM node:22-alpine

#Asigno parámetros a entorno
ARG UID
ARG GID

# Directorio de trabajo
WORKDIR /var/www/html

# Cambio UID y GID de usuario node
RUN deluser node
RUN addgroup --gid $GID www
RUN adduser --disabled-password --uid $UID --ingroup www www

EXPOSE 5173

# Cambio a user node
USER www

#CMD ["npm", "run", "dev", "--", "--host" ]
CMD ["npm", "run", "dev" ]
