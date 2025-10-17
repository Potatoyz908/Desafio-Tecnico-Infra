-- Script de inicialização do PostgreSQL
-- Cria os databases e roles necessários de forma idempotente

-- Database e role para metadados do Airflow
CREATE ROLE airflow_user WITH LOGIN PASSWORD 'airflow_password';
CREATE DATABASE airflow_meta OWNER airflow_user;
GRANT ALL PRIVILEGES ON DATABASE airflow_meta TO airflow_user;

-- Database e role para metadados do Superset
CREATE ROLE superset_user WITH LOGIN PASSWORD 'superset_password';
CREATE DATABASE superset_meta OWNER superset_user;
GRANT ALL PRIVILEGES ON DATABASE superset_meta TO superset_user;

-- Database para o Data Warehouse (analytics)
CREATE ROLE analytics_user WITH LOGIN PASSWORD 'analytics_password';
CREATE DATABASE analytics OWNER analytics_user;
GRANT ALL PRIVILEGES ON DATABASE analytics TO analytics_user;

-- Concede permissões de conexão
GRANT CONNECT ON DATABASE airflow_meta TO airflow_user;
GRANT CONNECT ON DATABASE superset_meta TO superset_user;
GRANT CONNECT ON DATABASE analytics TO analytics_user;

-- Permite que airflow_user também acesse o analytics (para DAGs)
GRANT CONNECT ON DATABASE analytics TO airflow_user;
