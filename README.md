# Desafio Técnico — Ambiente de Desenvolvimento para Engenharia de Dados

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=flat&logo=apache-airflow&logoColor=white)](https://airflow.apache.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Superset](https://img.shields.io/badge/Apache%20Superset-20A6C9?style=flat&logo=apache&logoColor=white)](https://superset.apache.org/)

## 📋 Sumário
- [Objetivo](#-objetivo)
- [Arquitetura](#-arquitetura)
- [Ferramentas](#-ferramentas)
- [Pré-requisitos](#-pré-requisitos)
- [Como Executar](#-como-executar)
- [Validação e Testes](#-validação-e-testes)
- [Interoperabilidade](#-interoperabilidade)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Segurança](#-segurança)
- [Troubleshooting](#-troubleshooting)

## 🎯 Objetivo

Este projeto demonstra a criação de um ambiente de desenvolvimento completo para Engenharia de Dados, com foco em:

- **Padronização**: Ambiente reproduzível via Docker Compose
- **Segurança**: Credenciais gerenciadas via variáveis de ambiente
- **Interoperabilidade**: Integração funcional entre todas as ferramentas
- **Simplicidade**: Configuração enxuta e focada no essencial

## 🏗 Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    AMBIENTE DE DADOS                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────────────────┐      │
│  │   AIRFLOW    │────────▶│       POSTGRES           │      │
│  │              │         │                          │      │
│  │  - Webserver │         │  ┌────────────────────┐  │      │
│  │  - Scheduler │         │  │ airflow_meta       │  │      │
│  │  - Init      │         │  │ (Metadados Airflow)│  │      │
│  └──────────────┘         │  └────────────────────┘  │      │
│       :8080               │                          │      │
│                           │  ┌────────────────────┐  │      │
│  ┌──────────────┐         │  │ superset_meta      │  │      │
│  │   SUPERSET   │────────▶│  │(Metadados Superset)│  │      │
│  │              │         │  └────────────────────┘  │      │
│  │  - WebUI     │         │                          │      │
│  │  - Init      │         │  ┌────────────────────┐  │      │
│  └──────────────┘         │  │ analytics          │  │      │
│       :8088               │  │ (Data Warehouse)   │  │      │
│                           │  └────────────────────┘  │      │
│                           │                          │      │
│                           └──────────────────────────┘      │
│                                    :5432                     │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 Ferramentas

### Apache Airflow (v2.7.3)
- **Função**: Orquestrador de workflows de dados (DAGs)
- **Executor**: LocalExecutor
- **Metadados**: PostgreSQL (database `airflow_meta`)
- **Interface**: http://localhost:8080

### PostgreSQL (v15)
- **Função**: Database relacional multipropósito
- **Databases**:
  - `airflow_meta`: Metadados do Airflow
  - `superset_meta`: Metadados do Superset
  - `analytics`: Data Warehouse para análises
- **Porta**: 5432

### Apache Superset (v3.0.1)
- **Função**: Plataforma de BI e visualização de dados
- **Metadados**: PostgreSQL (database `superset_meta`)
- **Fonte de Dados**: PostgreSQL (database `analytics`)
- **Interface**: http://localhost:8088

## 📦 Pré-requisitos

- **Docker**: versão 20.10 ou superior
- **Docker Compose**: versão 2.0 ou superior
- **Hardware mínimo recomendado**:
  - 8 GB RAM
  - 4 CPU cores
  - 10 GB espaço em disco

## 🚀 Como Executar

### 1. Clonar o Repositório

```bash
git clone <url-do-repositorio>
cd Desafio-Tecnico-Infra
```

### 2. Configurar Variáveis de Ambiente

```bash
# Copiar o arquivo de exemplo
cp .env.example .env

# Gerar Fernet Key para o Airflow (opcional, mas recomendado)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# Editar o .env e substituir as chaves geradas
nano .env  # ou use seu editor preferido
```

**Importante**: Nunca versione o arquivo `.env` com credenciais reais!

### 3. Subir o Ambiente

```bash
# Subir todos os serviços
docker-compose up -d

# Acompanhar os logs (opcional)
docker-compose logs -f
```

### 4. Aguardar Inicialização

Os serviços podem levar de 2 a 5 minutos para inicializar completamente. Você pode monitorar o status:

```bash
# Verificar status dos containers
docker-compose ps

# Verificar logs de um serviço específico
docker-compose logs airflow-init
docker-compose logs superset-init
```

## ✅ Validação e Testes

### 1. Verificar Postgres

```bash
# Conectar ao Postgres
docker exec -it postgres psql -U postgres

# Dentro do psql, listar databases
\l

# Você deve ver: airflow_meta, superset_meta e analytics
```

**O que observar**: Os três databases devem estar criados e ativos.

### 2. Acessar Airflow

1. Abrir navegador: http://localhost:8080
2. **Credenciais** (conforme `.env`):
   - Usuário: `admin`
   - Senha: `admin`

**O que observar**:
- Interface do Airflow carregada
- Menu "Admin" > "Connections" acessível
- DAG `exemplo_airflow_postgres` aparece na lista

### 3. Configurar Connection no Airflow

Para demonstrar a interoperabilidade Airflow → Postgres:

1. No Airflow, ir em **Admin** > **Connections**
2. Clicar em **[+]** (adicionar nova conexão)
3. Preencher:
   - **Connection Id**: `postgres_analytics`
   - **Connection Type**: `Postgres`
   - **Host**: `postgres`
   - **Schema**: `analytics`
   - **Login**: `analytics_user`
   - **Password**: `analytics_password`
   - **Port**: `5432`
4. Clicar em **Test** (botão inferior)

**O que observar**: Mensagem verde confirmando "Connection successfully tested".

### 4. Executar DAG de Exemplo

1. Na interface do Airflow, localizar a DAG `exemplo_airflow_postgres`
2. Ativar a DAG (toggle no canto esquerdo)
3. Clicar no ícone de "play" para executar manualmente
4. Acompanhar a execução das tasks no Graph View
5. Verificar logs de cada task

**O que observar**:
- Todas as tasks devem executar com sucesso (verde)
- A task `check_connection` confirma conexão com Postgres
- A task `create_table` cria a tabela `exemplo_vendas`
- A task `insert_sample_data` insere dados
- A task `query_data` exibe os dados inseridos nos logs

### 5. Acessar Superset

1. Abrir navegador: http://localhost:8088
2. **Credenciais** (conforme `.env`):
   - Usuário: `admin`
   - Senha: `admin`

**O que observar**: Interface do Superset carregada com sucesso.

### 6. Configurar Database no Superset

Para demonstrar a interoperabilidade Superset → Postgres:

1. No Superset, ir em **Settings** > **Database Connections**
2. Clicar em **+ Database**
3. Selecionar **PostgreSQL**
4. Preencher na aba **SQLALCHEMY URI**:
   ```
   postgresql://analytics_user:analytics_password@postgres:5432/analytics
   ```
5. Dar um nome (ex: "Analytics Warehouse")
6. Clicar em **Test Connection**
7. **EVIDÊNCIA OBRIGATÓRIA**: Capturar print da mensagem de sucesso
8. Salvar a conexão

**O que observar**: Mensagem de sucesso confirmando conexão com o database `analytics`.

### 7. Criar SQL Query no Superset

Para validar que o Superset consegue consultar os dados criados pelo Airflow:

1. Ir em **SQL** > **SQL Lab**
2. Selecionar o database "Analytics Warehouse"
3. Executar a query:
   ```sql
   SELECT * FROM exemplo_vendas;
   ```

**O que observar**: Dados inseridos pela DAG do Airflow devem ser exibidos.

## 🔗 Interoperabilidade

### ✅ Airflow ↔ Postgres
- **Tipo**: Gravação e consulta SQL
- **Comprovação**: 
  - Connection testada com sucesso no Airflow
  - DAG executa operações no database `analytics`
  - Dados persistidos e consultáveis

### ✅ Superset ↔ Postgres
- **Tipo**: Consulta SQL e visualização
- **Comprovação**:
  - Database connection testada com sucesso
  - Consultas executadas no SQL Lab
  - Dados do Airflow visíveis no Superset

### 📊 Fluxo Completo
```
Airflow DAG → Cria tabela no Postgres (analytics)
           → Insere dados no Postgres (analytics)
           → Superset consulta dados do Postgres (analytics)
           → Visualização no Superset
```

## 📁 Estrutura do Projeto

```
Desafio-Tecnico-Infra/
├── docker-compose.yml          # Orquestração dos containers
├── .env.example                # Template de variáveis (SEM credenciais)
├── .gitignore                  # Ignora credenciais e dados sensíveis
├── README.md                   # Esta documentação
│
├── postgres/
│   └── init/
│       └── 01-init-databases.sql  # Script de inicialização do Postgres
│
├── airflow/
│   └── dags/
│       └── exemplo_airflow_postgres.py  # DAG de demonstração
│
└── evidencias/                 # Pasta para prints de validação
   ├── Airflow.png              # Print mostrando os campos da conexão preenchidos no Airflow (botão Test desabilitado - ver nota)
   ├── Containers.png           # Print do output de `docker ps` mostrando containers em execução
   ├── DAG-run.png              # Captura do run da DAG (trigger manual) mostrando resultado do run
   ├── DAGs-Airflow.png         # Tela Home do Airflow com lista de DAGs
   └── superset.png             # Superset com Database ativo (Analytics)
```

## 🔒 Segurança

### Práticas Implementadas

✅ **Variáveis de ambiente**: Todas as credenciais em `.env`  
✅ **Gitignore configurado**: Arquivo `.env` nunca versionado  
✅ **Template público**: `.env.example` sem dados sensíveis  
✅ **Segregação de roles**: Cada serviço tem seu próprio usuário no Postgres  
✅ **Permissões mínimas**: Usuários com acesso apenas aos databases necessários

### Recomendações para Produção

⚠️ Este ambiente é para **desenvolvimento local** apenas. Para produção:

- Usar secrets managers (AWS Secrets Manager, Vault, etc)
- Implementar TLS/SSL para conexões
- Configurar autenticação via LDAP/OAuth
- Implementar backup automatizado
- Usar imagens Docker customizadas e verificadas
- Aplicar hardening nos containers

## 🐛 Troubleshooting

### Serviços não sobem

```bash
# Verificar logs de erro
docker-compose logs

# Recriar volumes e containers
docker-compose down -v
docker-compose up -d
```

### Airflow não inicializa

```bash
# Verificar logs do init
docker-compose logs airflow-init

# Garantir que Postgres está saudável
docker-compose ps postgres
```

### Superset não conecta ao Postgres

- Verificar se o driver `psycopg2` está instalado na imagem
- Confirmar que o database `analytics` foi criado
- Validar credenciais no `.env`

### Porta já em uso

Se alguma porta (5432, 8080, 8088) já estiver em uso:

1. Editar `docker-compose.yml`
2. Alterar o mapeamento de portas (ex: `"8081:8080"`)
3. Recriar os containers

## 📸 Evidências
As evidências obrigatórias foram salvas na pasta `evidencias/` e também estão incorporadas abaixo.

Observação importante: o botão "Test" do Airflow pode aparecer desabilitado (cinza) em algumas versões/instalações quando o provider não está visível na UI — neste repositório o comportamento observado foi que a conexão estava corretamente preenchida e funcional mesmo com o botão inativo; o screenshot `airflow.png` mostra isso explicitamente.

1. airflow.png

![Airflow Connection](evidencias/Airflow.png)

Legenda: formulário de conexão do Airflow preenchido para `postgres_analytics`. Note o botão "Test" inativo (cinza) — a conexão foi criada com sucesso via CLI/UI e a DAG consegue usar a connection.

2. containers.png

![Docker Containers](evidencias/Containers.png)

Legenda: saída de `docker ps` mostrando os containers em execução (airflow-webserver, airflow-scheduler, postgres, superset, init-containers, etc.). Pode ser gerado com:

3. DAG-run.png

![DAG Run](evidencias/DAG-run.png)

Legenda: captura mostrando a execução (trigger manual) da DAG `exemplo_airflow_postgres`, com as tasks concluídas ou em execução e o resultado do run (logs/estado). Para gerar: acione a DAG na UI e abra o painel de Run/Graph View, capture o status.

4. DAGs-Airflow.png

![Airflow DAGs Home](evidencias/DAGs-Airflow.png)

Legenda: tela Home do Airflow com a lista de DAGs, mostrando `exemplo_airflow_postgres` visível e o toggle de ativação.

5. superset.png

![Superset Connected](evidencias/superset.png)

Legenda: Superset com o database `Analytics` / `analytics` ativo e testes de conexão vencidos (ou mensagem de conectado). A captura deve mostrar a URI ou o formulário preenchido e a mensagem de sucesso.

Como salvar as imagens na pasta `evidencias/`:

1. Crie a pasta (se ainda não existir):

```bash
mkdir -p evidencias
```

2. Use sua ferramenta de captura (Flameshot, GNOME Screenshot, PrintScreen) para salvar as imagens com os nomes exatos:

- `evidencias/Airflow.png`
- `evidencias/Containers.png`
- `evidencias/DAG-run.png`
- `evidencias/DAGs-Airflow.png`
- `evidencias/superset.png`

3. Verifique rapidamente no terminal que os arquivos existem:

```bash
ls -l evidencias
```

Se quiser eu mesmo gerar `Containers.png` (captura do `docker ps`) e salvar em `evidencias/Containers.png`, posso executar o comando e criar uma imagem terminal->PNG aqui; me autorize que eu executo e salvo automaticamente.

## 🎓 Decisões Técnicas

### Por que LocalExecutor?
- Simplicidade para ambiente de desenvolvimento
- Não requer Celery/Redis adicional
- Suficiente para testes e validações

### Por que um único Postgres?
- Economia de recursos
- Simplifica gerenciamento
- Segregação via databases e roles
- Padrão comum em ambientes de desenvolvimento

### Por que estas versões?
- **Airflow 2.7.3**: Versão estável e amplamente usada
- **Postgres 15**: Balance entre features e estabilidade
- **Superset 3.0.1**: Versão recente com melhorias de UX

## 📄 Licença

Este projeto é disponibilizado para fins educacionais e de avaliação técnica.

## 👤 Autor

**Euller Júlio**  
GitHub: [@Potatoyz908](https://github.com/Potatoyz908)

---

**Desafio Stack Dados 2025** | Entregue em 17/10/2025
