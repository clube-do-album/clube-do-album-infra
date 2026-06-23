#!/bin/bash
# Cria os bancos adicionais usados por cada servico.
# Executado automaticamente pelo entrypoint do Postgres na primeira inicializacao
# (apenas quando o volume de dados esta vazio).
set -e

DATABASES=(
  clube_do_album_catalog
  clube_do_album_identity
  clube_do_album_ratings
  clube_do_album_ranking
  clube_do_album_feed
  clube_do_album_social
  clube_do_album_notification
)

for db in "${DATABASES[@]}"; do
  echo "Criando database '$db'..."
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    SELECT 'CREATE DATABASE $db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
EOSQL
done
