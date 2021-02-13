FROM node:15.7.0-alpine3.10 AS builder

ARG HOME="/app"
ARG PUID=2000
ARG PGUID=2000

RUN addgroup --gid ${PGUID} questcode-backend-frontend && \
  adduser -D -u ${PUID} -G questcode-backend-frontend -s /bin/bash -h ${HOME} questcode-backend-frontend

USER questcode-backend-frontend:questcode-backend-frontend

WORKDIR ${HOME}
COPY --chown=questcode-backend-frontend:questcode-backend-frontend package*.json ./
RUN npm install

COPY --chown=questcode-backend-frontend:questcode-backend-frontend src/  ./src/
COPY --chown=questcode-backend-frontend:questcode-backend-frontend public/  ./public/

RUN npm run build

FROM nginx:1.18.0-alpine as server

COPY ./nginx-config.sh .

RUN chmod +x /nginx-config.sh &&  \
  ./nginx-config.sh && \
  rm -rf ./nginx-config.sh && \
  chown -R nginx:nginx /var/cache/nginx && \
  chown -R nginx:nginx /var/log/nginx && \
  chown -R nginx:nginx /etc/nginx/conf.d && \
  touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid

USER nginx

COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
