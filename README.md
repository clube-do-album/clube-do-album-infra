# Clube do Album Infra

Repositorio de infraestrutura local compartilhada do projeto Clube do Album.

Este projeto sobe apenas os servicos de infraestrutura usados pelo ecossistema. As APIs e workers ficam em repositorios separados e ganharao seus proprios Dockerfiles em tasks futuras.

## Objetivo

Preparar o ambiente local inicial para a plataforma distribuida de ranking e rede social de albuns musicais.

## Servicos de infraestrutura

- PostgreSQL 16
- RabbitMQ
- RabbitMQ Management

## Servicos da plataforma

- `clube-do-album-catalog-api`
- `clube-do-album-feed-worker`
- `clube-do-album-gateway-api`
- `clube-do-album-identity-api`
- `clube-do-album-notification-worker`
- `clube-do-album-ranking-worker`
- `clube-do-album-ratings-api`
- `clube-do-album-social-api`
- `clube-do-album-web`

## Como subir localmente

```bash
docker compose up -d
```

Para visualizar os containers:

```bash
docker compose ps
```

Para acompanhar logs:

```bash
docker compose logs -f
```

Para parar a infraestrutura:

```bash
docker compose down
```

Para parar e remover os volumes locais:

```bash
docker compose down -v
```

## RabbitMQ Management

Disponivel em:

```text
http://localhost:15672
```

Usuario:

```text
clube
```

Senha:

```text
clube
```

## PostgreSQL

Disponivel em:

```text
localhost:5432
```

Banco:

```text
clube_do_album
```

Usuario:

```text
clube
```

Senha:

```text
clube
```

## Status atual

Projeto inicial criado apenas com infraestrutura local compartilhada. Ainda nao ha APIs ou workers no Docker Compose, nem migrations, tabelas ou integracoes reais configuradas.
