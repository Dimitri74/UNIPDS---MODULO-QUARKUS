# Script de inicialização para Windows PowerShell
# Florinda Eats - Inicialização Completa

Write-Host "=================================================="
Write-Host "  Florinda Eats - Inicialização Completa" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Iniciar Infraestrutura (MySQL + Kafka + Zookeeper)
Write-Host "▶ Iniciando Infraestrutura (MySQL + Kafka + Zookeeper)..." -ForegroundColor Blue
Set-Location pedidos
docker-compose up -d
Start-Sleep -Seconds 15
Write-Host "✓ Infraestrutura iniciada" -ForegroundColor Green
Write-Host ""

# 2. Compilar Projetos
Write-Host "▶ Compilando Projetos..." -ForegroundColor Blue

Set-Location ../pedidos
Write-Host "  → Compilando Pedidos..." -ForegroundColor Blue
.\mvnw clean package -DskipTests -q
Write-Host "  ✓ Pedidos compilado" -ForegroundColor Green

Set-Location ../pagamentos
Write-Host "  → Compilando Pagamentos..." -ForegroundColor Blue
.\mvnw clean package -DskipTests -q
Write-Host "  ✓ Pagamentos compilado" -ForegroundColor Green

Set-Location ../notas-fiscais
Write-Host "  → Compilando Notas Fiscais..." -ForegroundColor Blue
.\mvnw clean package -DskipTests -q
Write-Host "  ✓ Notas Fiscais compilado" -ForegroundColor Green
Write-Host ""

# 3. Criar Tópicos Kafka
Write-Host "▶ Criando Tópicos Kafka..." -ForegroundColor Blue
Start-Sleep -Seconds 10
$kafkaContainer = docker ps | Select-String "kafka" | ForEach-Object { $_ -split '\s+' | Select-Object -First 1 }
if ($kafkaContainer) {
    docker exec -it $kafkaContainer `
        kafka-topics.sh `
        --bootstrap-server localhost:9094 `
        --create --partitions 2 `
        --topic pagamentosConfirmados `
        --if-not-exists
}
Write-Host "✓ Tópicos criados" -ForegroundColor Green
Write-Host ""

# 4. Instruções para iniciar serviços
Write-Host "▶ Iniciando Serviços Quarkus..." -ForegroundColor Blue
Write-Host ""
Write-Host "Inicie os serviços em PowerShells separados:" -ForegroundColor Yellow
Write-Host ""
Write-Host "PowerShell 1 - Pedidos:" -ForegroundColor Blue
Write-Host "  cd pedidos; .\mvnw quarkus:dev" -ForegroundColor Gray
Write-Host ""
Write-Host "PowerShell 2 - Pagamentos:" -ForegroundColor Blue
Write-Host "  cd pagamentos; .\mvnw quarkus:dev" -ForegroundColor Gray
Write-Host ""
Write-Host "PowerShell 3 - Notas Fiscais:" -ForegroundColor Blue
Write-Host "  cd notas-fiscais; .\mvnw quarkus:dev" -ForegroundColor Gray
Write-Host ""

Write-Host "=================================================="
Write-Host "✓ Ambiente Pronto!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Serviços disponíveis em:" -ForegroundColor Yellow
Write-Host "  - Pedidos:      http://localhost:8080/q/swagger-ui/" -ForegroundColor Gray
Write-Host "  - Pagamentos:   http://localhost:8081/q/swagger-ui/" -ForegroundColor Gray
Write-Host "  - Notas Fiscais: http://localhost:8082/q/swagger-ui/" -ForegroundColor Gray
Write-Host ""
Write-Host "Kafka:" -ForegroundColor Yellow
Write-Host "  - Bootstrap: localhost:9092" -ForegroundColor Gray
Write-Host "  - Tópico: pagamentosConfirmados" -ForegroundColor Gray
Write-Host ""
Write-Host "Para mais informacoes, veja KAFKA_INTEGRATION.md" -ForegroundColor Yellow

