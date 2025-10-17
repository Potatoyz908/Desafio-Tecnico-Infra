# Guia Rápido de Comandos

## 🚀 Iniciar o Ambiente

```bash
# Subir todos os serviços
docker-compose up -d

# Subir e acompanhar logs
docker-compose up

# Subir apenas serviços específicos
docker-compose up -d postgres airflow-webserver
```

## 📊 Monitoramento

```bash
# Ver status de todos os containers
docker-compose ps

# Ver logs de todos os serviços
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f airflow-webserver
docker-compose logs -f superset
docker-compose logs -f postgres

# Ver últimas 100 linhas de log
docker-compose logs --tail=100 airflow-scheduler
```

## 🔧 Gerenciamento

```bash
# Parar todos os serviços
docker-compose stop

# Parar um serviço específico
docker-compose stop airflow-webserver

# Reiniciar todos os serviços
docker-compose restart

# Reiniciar um serviço específico
docker-compose restart superset

# Remover containers (mantém volumes)
docker-compose down

# Remover containers E volumes (CUIDADO: apaga dados!)
docker-compose down -v

# Recriar um container específico
docker-compose up -d --force-recreate airflow-webserver
```

## 🗄️ Postgres

```bash
# Conectar ao Postgres via psql
docker exec -it postgres psql -U postgres

# Conectar diretamente a um database específico
docker exec -it postgres psql -U postgres -d analytics

# Executar query direto do terminal
docker exec -it postgres psql -U postgres -c "SELECT version();"

# Backup de um database
docker exec postgres pg_dump -U postgres analytics > backup_analytics.sql

# Restaurar um database
cat backup_analytics.sql | docker exec -i postgres psql -U postgres analytics
```

### Comandos psql (dentro do container)

```sql
-- Listar todos os databases
\l

-- Conectar a um database
\c analytics

-- Listar tabelas do database atual
\dt

-- Descrever estrutura de uma tabela
\d exemplo_vendas

-- Listar usuários/roles
\du

-- Ver conexões ativas
SELECT * FROM pg_stat_activity;

-- Sair do psql
\q
```

## ✈️ Airflow

```bash
# Ver lista de DAGs
docker exec airflow-webserver airflow dags list

# Executar uma DAG manualmente
docker exec airflow-webserver airflow dags trigger exemplo_airflow_postgres

# Ver status de execuções de uma DAG
docker exec airflow-webserver airflow dags list-runs -d exemplo_airflow_postgres

# Pausar/Despausar uma DAG
docker exec airflow-webserver airflow dags pause exemplo_airflow_postgres
docker exec airflow-webserver airflow dags unpause exemplo_airflow_postgres

# Testar uma task específica
docker exec airflow-webserver airflow tasks test exemplo_airflow_postgres check_connection 2025-01-01

# Listar connections
docker exec airflow-webserver airflow connections list

# Criar connection via CLI
docker exec airflow-webserver airflow connections add 'postgres_analytics' \
    --conn-type 'postgres' \
    --conn-host 'postgres' \
    --conn-schema 'analytics' \
    --conn-login 'analytics_user' \
    --conn-password 'analytics_password' \
    --conn-port 5432

# Acessar shell Python do Airflow
docker exec -it airflow-webserver airflow shell
```

## 📈 Superset

```bash
# Acessar shell do Superset
docker exec -it superset superset shell

# Criar usuário admin
docker exec -it superset superset fab create-admin

# Atualizar database (migrations)
docker exec -it superset superset db upgrade

# Carregar exemplos (opcional)
docker exec -it superset superset load_examples

# Reinicializar Superset
docker exec -it superset superset init
```

## 🐳 Docker - Limpeza

```bash
# Ver uso de espaço
docker system df

# Limpar containers parados
docker container prune

# Limpar imagens não utilizadas
docker image prune

# Limpar volumes não utilizados (CUIDADO!)
docker volume prune

# Limpar tudo não utilizado
docker system prune -a

# Ver volumes criados
docker volume ls

# Inspecionar um volume
docker volume inspect desafio-tecnico-infra_postgres-data
```

## 🔍 Debug e Troubleshooting

```bash
# Ver recursos consumidos pelos containers
docker stats

# Inspecionar um container
docker inspect postgres

# Ver processos rodando em um container
docker top airflow-webserver

# Executar comando bash dentro de um container
docker exec -it postgres bash
docker exec -it airflow-webserver bash
docker exec -it superset bash

# Ver networks
docker network ls

# Inspecionar network
docker network inspect desafio-tecnico-infra_dataeng-network

# Testar conectividade entre containers
docker exec airflow-webserver ping postgres
docker exec superset nc -zv postgres 5432
```

## 🧪 Testes Rápidos

```bash
# Testar se Postgres está aceitando conexões
docker exec postgres pg_isready -U postgres

# Testar conexão do Airflow com Postgres
docker exec airflow-webserver python -c "
from airflow.providers.postgres.hooks.postgres import PostgresHook
hook = PostgresHook(postgres_conn_id='postgres_analytics')
conn = hook.get_conn()
print('Conexão OK!' if conn else 'Falha na conexão')
"

# Verificar se DAG está carregada
docker exec airflow-webserver airflow dags show exemplo_airflow_postgres

# Testar query no Postgres
docker exec postgres psql -U analytics_user -d analytics -c "SELECT * FROM exemplo_vendas LIMIT 5;"
```

## 📦 Variáveis de Ambiente

```bash
# Ver variáveis de ambiente de um container
docker exec airflow-webserver env | grep AIRFLOW

# Recarregar variáveis após mudança no .env
docker-compose down
docker-compose up -d
```

## 🔄 Atualização de Código

```bash
# Após modificar DAGs
# (Não precisa reiniciar, Airflow detecta automaticamente)
# Mas se quiser forçar:
docker-compose restart airflow-scheduler

# Após modificar docker-compose.yml
docker-compose down
docker-compose up -d

# Rebuild de imagens (se tiver Dockerfile customizado)
docker-compose build
docker-compose up -d
```

## 💾 Backup e Restore

```bash
# Backup completo do Postgres
docker exec postgres pg_dumpall -U postgres > backup_completo.sql

# Backup de databases individuais
docker exec postgres pg_dump -U postgres airflow_meta > backup_airflow.sql
docker exec postgres pg_dump -U postgres superset_meta > backup_superset.sql
docker exec postgres pg_dump -U postgres analytics > backup_analytics.sql

# Restore de database
cat backup_analytics.sql | docker exec -i postgres psql -U postgres analytics

# Backup de volumes do Docker
docker run --rm -v desafio-tecnico-infra_postgres-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres-backup.tar.gz /data
```

## 🎯 Acessos Rápidos

```bash
# Abrir Airflow no navegador (Linux)
xdg-open http://localhost:8080

# Abrir Superset no navegador (Linux)
xdg-open http://localhost:8088

# Credentials padrão (ver .env):
# Airflow:  admin / admin
# Superset: admin / admin
```

## 📝 Notas

- Sempre use `docker-compose` (com hífen) ao invés de `docker compose` para compatibilidade
- Mantenha o `.env` sempre atualizado e NUNCA o versione
- Para mudanças em volumes, use `docker-compose down -v` com cuidado (apaga dados)
- Logs podem crescer muito; considere rotação periódica em produção
