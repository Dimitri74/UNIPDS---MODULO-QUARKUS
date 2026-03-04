# 🚀 Comandos Prontos - OpenTelemetry

## Copie e Cole estes Comandos

### ⚡ Setup Inicial (Execute uma vez)

```bash
# Inicie toda a stack observabilidade
docker-compose up -d

# Aguarde ~30 segundos para tudo subir
# Verifique: docker-compose ps
```

### 🔧 Desenvolvimento

```bash
# Compile e inicie em modo dev
./mvnw clean compile quarkus:dev

# Em outro terminal, execute testes
.\Test-OpenTelemetry.ps1
```

### 📊 Acesso aos Dashboards

Abra em seu navegador:

```
Jaeger Traces:    http://localhost:16686
Prometheus:       http://localhost:9090
Grafana:          http://localhost:3000 (admin/admin)
API:              http://localhost:8080
Métricas:         http://localhost:8080/q/metrics
```

### 🧪 Testes Manuais

```bash
# Test 1: Listar pessoas
curl http://localhost:8080/pessoa

# Test 2: Criar pessoa
curl -X POST http://localhost:8080/pessoa \
  -H "Content-Type: application/json" \
  -d "{\"nome\":\"João\",\"anoNascimento\":1990}"

# Test 3: Star Wars
curl http://localhost:8080/starwars/starships

# Test 4: Health Check
curl http://localhost:8080/q/health
```

### 🛑 Parar Tudo

```bash
# Parar containers
docker-compose down

# Parar app (Ctrl+C no terminal dev)
```

### 🏗️ Build para Produção

```bash
# Build JAR
./mvnw clean package -DskipTests

# Build com Docker
docker build -f src/main/docker/Dockerfile.jvm -t app:latest .

# Rodar com Docker
docker run -p 8080:8080 \
  -e QUARKUS_OTEL_EXPORTER_OTLP_ENDPOINT=http://seu-jaeger:4317 \
  app:latest
```

### 🔍 Verificação de Status

```bash
# Ver containers rodando
docker-compose ps

# Ver logs
docker-compose logs -f quarkus-app
docker-compose logs -f jaeger
docker-compose logs -f prometheus

# Verificar se app está pronto
curl http://localhost:8080/q/health

# Verificar métricas
curl http://localhost:8080/q/metrics | grep http_server_requests
```

### 📈 Exemplos de PromQL (Prometheus)

```
# Contagem total de requisições
http_server_requests_seconds_count

# Taxa de requisições por segundo
rate(http_server_requests_seconds_count[1m])

# Latência P95
histogram_quantile(0.95, http_server_requests_seconds_bucket)

# Erro rate
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m]))
```

### 🎯 Workflow Típico

```bash
# Terminal 1: Docker
docker-compose up -d

# Terminal 2: Quarkus Dev
./mvnw quarkus:dev

# Terminal 3: Testes
.\Test-OpenTelemetry.ps1

# Browser 1: Jaeger
http://localhost:16686

# Browser 2: Prometheus
http://localhost:9090

# Browser 3: Grafana
http://localhost:3000
```

---

## ✅ Checklist Rápido

- [ ] `docker-compose up -d` ✓
- [ ] App compilada e rodando ✓
- [ ] Testes passando ✓
- [ ] Jaeger mostrando traces ✓
- [ ] Prometheus coletando métricas ✓

Quando tudo estiver verde, você tem observabilidade completa! 🎉


