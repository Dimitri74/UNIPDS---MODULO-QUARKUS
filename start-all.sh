#!/bin/bash

# Script de inicialização completa do Florinda Eats com Kafka
# Este script instancia todos os serviços necessários

set -e

echo "=================================================="
echo "  Florinda Eats - Inicialização Completa"
echo "=================================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir seções
print_section() {
    echo -e "${BLUE}▶ $1${NC}"
}

# 1. Iniciar Infraestrutura (MySQL + Kafka + Zookeeper)
print_section "Iniciando Infraestrutura (MySQL + Kafka + Zookeeper)..."
cd pedidos
docker-compose up -d
sleep 15
echo -e "${GREEN}✓ Infraestrutura iniciada${NC}"
echo ""

# 2. Compilar Projetos
print_section "Compilando Projetos..."
cd ../pedidos
echo -e "${BLUE}  → Compilando Pedidos...${NC}"
./mvnw clean package -DskipTests -q
echo -e "${GREEN}  ✓ Pedidos compilado${NC}"

cd ../pagamentos
echo -e "${BLUE}  → Compilando Pagamentos...${NC}"
./mvnw clean package -DskipTests -q
echo -e "${GREEN}  ✓ Pagamentos compilado${NC}"

cd ../notas-fiscais
echo -e "${BLUE}  → Compilando Notas Fiscais...${NC}"
./mvnw clean package -DskipTests -q
echo -e "${GREEN}  ✓ Notas Fiscais compilado${NC}"
echo ""

# 3. Criar Tópicos Kafka
print_section "Criando Tópicos Kafka..."
sleep 10
docker exec -it $(docker ps | grep kafka | awk '{print $1}') \
    kafka-topics.sh \
    --bootstrap-server localhost:9094 \
    --create --partitions 2 \
    --topic pagamentosConfirmados \
    --if-not-exists
echo -e "${GREEN}✓ Tópicos criados${NC}"
echo ""

# 4. Iniciar Serviços em Paralelo
print_section "Iniciando Serviços Quarkus..."
echo ""

# Usar gnome-terminal se disponível, caso contrário usar xterm
TERMINAL_CMD="gnome-terminal -- "
if ! command -v gnome-terminal &> /dev/null; then
    TERMINAL_CMD="xterm -e "
fi

# Iniciar cada serviço em terminal separado (comentado para ambiente Windows)
# Para Windows PowerShell, descomente as linhas abaixo e use Start-Process

echo "Inicie os serviços em terminais separados:"
echo ""
echo -e "${BLUE}Terminal 1 - Pedidos:${NC}"
echo "  cd pedidos && ./mvnw quarkus:dev"
echo ""
echo -e "${BLUE}Terminal 2 - Pagamentos:${NC}"
echo "  cd pagamentos && ./mvnw quarkus:dev"
echo ""
echo -e "${BLUE}Terminal 3 - Notas Fiscais:${NC}"
echo "  cd notas-fiscais && ./mvnw quarkus:dev"
echo ""

echo "=================================================="
echo -e "${GREEN}✓ Ambiente Pronto!${NC}"
echo "=================================================="
echo ""
echo "Serviços disponíveis em:"
echo "  - Pedidos: http://localhost:8080/q/swagger-ui/"
echo "  - Pagamentos: http://localhost:8081/q/swagger-ui/"
echo "  - Notas Fiscais: http://localhost:8082/q/swagger-ui/"
echo ""
echo "Kafka:"
echo "  - Bootstrap: localhost:9092"
echo "  - Tópico: pagamentosConfirmados"
echo ""
echo "Para mais informações, veja KAFKA_INTEGRATION.md"

