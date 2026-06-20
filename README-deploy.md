# Deploy em producao

Este guia usa as imagens publicadas no GitHub Container Registry da organization:

```text
ghcr.io/clube-do-album
```

## Pre-requisitos

- Servidor com Docker e Docker Compose.
- Acesso ao GHCR, caso as imagens estejam privadas.
- PostgreSQL provisionado na nuvem.
- RabbitMQ provisionado na nuvem.
- URLs publicas para:
  - Web: `https://app.exemplo.com`
  - Gateway/API: `https://api.exemplo.com`

## Bancos necessarios

Criar os bancos abaixo no PostgreSQL:

```sql
CREATE DATABASE clube_do_album_identity;
CREATE DATABASE clube_do_album_catalog;
CREATE DATABASE clube_do_album_ratings;
CREATE DATABASE clube_do_album_ranking;
CREATE DATABASE clube_do_album_social;
CREATE DATABASE clube_do_album_feed;
CREATE DATABASE clube_do_album_notification;
```

## Variaveis de ambiente

Copiar o exemplo:

```bash
cp .env.prod.example .env.prod
```

Preencher `.env.prod` com os dados reais da nuvem:

- host, usuario e senha do PostgreSQL
- URLs de banco de cada servico
- RabbitMQ URL e credenciais
- `JWT_SECRET`
- credenciais do Spotify
- URLs publicas de web e gateway

Nao commitar `.env.prod`.

## Atenção sobre o web

O frontend Vite grava `VITE_API_BASE_URL` no momento do build. Se a imagem
`ghcr.io/clube-do-album/clube-do-album-web:latest` foi buildada apontando para
`localhost`, ela precisa ser rebuildada e publicada novamente com a URL publica
do gateway.

Exemplo:

```bash
cd ../clube-do-album-web
docker build \
  --build-arg VITE_API_BASE_URL=https://api.exemplo.com \
  -t ghcr.io/clube-do-album/clube-do-album-web:latest .
docker push ghcr.io/clube-do-album/clube-do-album-web:latest
```

Se o Dockerfile atual do web ainda nao aceitar `--build-arg`, ajustar o
Dockerfile do web antes do deploy ou configurar a URL em runtime.

## Login no GHCR

Se as imagens estiverem privadas:

```bash
docker login ghcr.io
```

Usuario: usuario do GitHub com acesso a organization.

Senha: token com `read:packages`.

## Subir aplicacao

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod pull
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

Ver status:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod ps
```

Ver logs:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f
```

Parar:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod down
```

## Ordem esperada

O PostgreSQL e o RabbitMQ devem estar disponiveis antes de subir a stack.

O Compose sobe:

1. APIs internas e workers
2. Gateway
3. Web

## Migrations e schemas

Os servicos Java usam Hibernate `ddl-auto=update`.

Os servicos Node usam Prisma. Se as imagens nao executarem migrations
automaticamente, rode as migrations antes de liberar a aplicacao:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm catalog-api npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm ranking-worker npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm feed-worker npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm social-api npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm notification-worker npx prisma migrate deploy
```

## Health check manual

Depois de subir, validar:

```bash
curl https://api.exemplo.com/health
curl https://api.exemplo.com/albums
```

E acessar:

```text
https://app.exemplo.com
```

## Deploy pelo GitHub Actions

O repositorio de infra possui um workflow manual:

```text
.github/workflows/deploy-production.yml
```

Ele deve ser executado pelo GitHub em:

```text
Actions > Deploy Production > Run workflow
```

Antes de rodar, configurar os secrets no repositorio ou na organization:

```text
CLOUD_HOST=ip-ou-dominio-do-servidor
CLOUD_USER=usuario-ssh
CLOUD_SSH_PORT=22
CLOUD_SSH_KEY=chave-privada-ssh
CLOUD_DEPLOY_PATH=/caminho/do/clube-do-album-infra
GHCR_USERNAME=usuario-github
GHCR_TOKEN=token-com-read-packages
```

No servidor, o caminho definido em `CLOUD_DEPLOY_PATH` precisa conter:

```text
docker-compose.prod.yml
.env.prod
```

O workflow faz:

```bash
docker login ghcr.io
docker compose -f docker-compose.prod.yml --env-file .env.prod pull
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm catalog-api npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm ranking-worker npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm feed-worker npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm social-api npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm notification-worker npx prisma migrate deploy
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
docker image prune -f
```

As migrations podem ser desativadas no input `run_migrations` ao rodar o workflow manualmente.
