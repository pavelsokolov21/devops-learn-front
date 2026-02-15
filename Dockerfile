# ---------- build ----------
FROM node:20-alpine AS build

WORKDIR /src

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build


# ---------- artifact (no nginx) ----------
FROM alpine:3.20

WORKDIR /app
COPY --from=build /src/dist ./dist

# Контейнер "экспортирует" сборку в /out, если туда примонтирован volume.
# Никакого nginx здесь нет.
CMD ["sh", "-c", "\
  if [ -d /out ]; then \
    rm -rf /out/* && cp -r /app/dist/* /out/ && echo 'Frontend dist exported to /out'; \
  else \
    echo 'No /out volume mounted. This image contains dist at /app/dist.'; \
  fi \
"]
