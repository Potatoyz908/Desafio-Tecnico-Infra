#!/bin/bash

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker não está instalado!"
        exit 1
    fi
    log_success "Docker encontrado: $(docker --version)"
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose não está instalado!"
        exit 1
    fi
    log_success "Docker Compose encontrado: $(docker-compose --version)"
}

# Função para gerar Fernet Key
generate_fernet_key() {
    python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" 2>/dev/null || \
    python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())" 2>/dev/null || \
    echo "$(openssl rand -base64 32)"
}

# Função para gerar secret key
generate_secret_key() {
    openssl rand -base64 32
}

# Função para configurar .env
setup_env() {
    log_info "Configurando arquivo .env..."
    
    if [ -f .env ]; then
        log_warning "Arquivo .env já existe!"
        read -p "Deseja sobrescrever? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            log_info "Mantendo .env existente"
            return
        fi
    fi
    
    log_info "Gerando chaves secretas..."
    FERNET_KEY=$(generate_fernet_key)
    AIRFLOW_SECRET=$(generate_secret_key)
    SUPERSET_SECRET=$(generate_secret_key)
    
    cp .env.example .env
    
    # Substituir chaves no .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|your_fernet_key_here_generate_one|${FERNET_KEY}|g" .env
        sed -i '' "s|your_secret_key_here|${AIRFLOW_SECRET}|g" .env
        sed -i '' "s|your_superset_secret_key_here|${SUPERSET_SECRET}|g" .env
    else

        sed -i "s|your_fernet_key_here_generate_one|${FERNET_KEY}|g" .env
        sed -i "s|your_secret_key_here|${AIRFLOW_SECRET}|g" .env
        sed -i "s|your_superset_secret_key_here|${SUPERSET_SECRET}|g" .env
    fi
    
    log_success "Arquivo .env criado com chaves secretas geradas!"
}

# Função para criar diretórios
create_directories() {
    log_info "Criando diretórios necessários..."
    
    mkdir -p airflow/dags
    mkdir -p postgres/init
    mkdir -p evidencias
    
    #Ajusta permissões para Airflow
    if [ -d airflow ]; then
        log_info "Ajustando permissões do diretório airflow..."
        chmod -R 755 airflow
    fi
    
    log_success "Diretórios criados!"
}

#Subindo o ambiente
start_environment() {
    log_info "Iniciando ambiente..."
    
    log_info "Fazendo pull das imagens Docker (pode demorar na primeira vez)..."
    docker-compose pull
    
    log_info "Subindo containers..."
    docker-compose up -d
    
    log_success "Containers iniciados!"
}

# Função para verificar saúde dos serviços
check_health() {
    log_info "Verificando saúde dos serviços..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose ps | grep -q "healthy"; then
            log_success "Serviços estão saudáveis!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "Aguardando serviços iniciarem... ($attempt/$max_attempts)"
        sleep 10
    done
    
    log_warning "Alguns serviços podem ainda estar inicializando"
    return 1
}

# Função para mostrar status
show_status() {
    log_info "Status dos serviços:"
    echo ""
    docker-compose ps
    echo ""
}

# Função para mostrar informações de acesso
show_access_info() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         AMBIENTE DE DADOS CONFIGURADO COM SUCESSO!          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}Acesso às Interfaces:${NC}"
    echo ""
    echo -e "  📊 ${BLUE}Airflow${NC}"
    echo "     URL:      http://localhost:8080"
    echo "     Usuário:  admin"
    echo "     Senha:    admin"
    echo ""
    echo -e "  📈 ${BLUE}Superset${NC}"
    echo "     URL:      http://localhost:8088"
    echo "     Usuário:  admin"
    echo "     Senha:    admin"
    echo ""
    echo -e "  🗄️  ${BLUE}PostgreSQL${NC}"
    echo "     Host:     localhost"
    echo "     Porta:    5432"
    echo "     Usuário:  postgres"
    echo "     Senha:    postgres_root_password"
    echo ""
    echo -e "${YELLOW}Próximos Passos:${NC}"
    echo ""
    echo "  1. Aguarde 2-5 minutos para inicialização completa"
    echo "  2. Acesse o Airflow e configure a Connection 'postgres_analytics'"
    echo "  3. Execute a DAG 'exemplo_airflow_postgres'"
    echo "  4. Acesse o Superset e conecte ao database 'analytics'"
    echo "  5. Capture as evidências obrigatórias!"
    echo ""
    echo -e "${BLUE}Comandos Úteis:${NC}"
    echo ""
    echo "  Ver logs:           docker-compose logs -f"
    echo "  Parar ambiente:     docker-compose stop"
    echo "  Reiniciar:          docker-compose restart"
    echo "  Remover tudo:       docker-compose down -v"
    echo ""
    echo "📖 Consulte README.md e COMANDOS.md para mais informações!"
    echo ""
}

#Função principal
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     SETUP - AMBIENTE DE DESENVOLVIMENTO PARA ENG. DADOS      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_dependencies
    setup_env
    create_directories
    start_environment
    
    log_info "Aguardando inicialização dos serviços..."
    sleep 15
    
    check_health || true
    show_status
    show_access_info
}

main
