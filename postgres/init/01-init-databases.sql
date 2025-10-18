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

-- Concede privilégios no schema public de cada database
\c airflow_meta
GRANT ALL ON SCHEMA public TO airflow_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO airflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO airflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO airflow_user;

\c superset_meta
GRANT ALL ON SCHEMA public TO superset_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO superset_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO superset_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO superset_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO superset_user;

\c analytics
GRANT ALL ON SCHEMA public TO analytics_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO analytics_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO analytics_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO analytics_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO analytics_user;

-- Permite que airflow_user também crie tabelas no analytics (importante para DAGs)
GRANT ALL ON SCHEMA public TO airflow_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO airflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO airflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO airflow_user;
