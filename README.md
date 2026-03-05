# 🚀 Aplicação Quarkus - Backend com JWT/RBAC

Aplicação backend desenvolvida com Quarkus demonstrando integração com APIs externas, autenticação JWT, controle de acesso baseado em roles (RBAC) e **observabilidade completa com OpenTelemetry**.

---

## 📋 Sobre o Projeto

Esta aplicação demonstra os principais conceitos do Quarkus:

- ✅ **REST APIs** - Endpoints RESTful
- ✅ **JWT Authentication** - Segurança com JSON Web Tokens
- ✅ **RBAC** - Role-Based Access Control
- ✅ **REST Client** - Integração com API externa (Star Wars)
- ✅ **Health Checks** - Monitoramento da aplicação
- ✅ **Hibernate ORM** - Persistência com H2 em memória
- ✅ **OpenAPI/Swagger** - Documentação automática
- ✅ **OpenTelemetry** - Tracing distribuído e observabilidade
- ✅ **Jaeger** - Visualização de traces distribuídos
- ✅ **Prometheus** - Coleta de métricas
- ✅ **Grafana** - Dashboards visuais

---

## 🛠️ Tecnologias

### **Core**
- **Quarkus 3.17.5** - Framework supersônico
- **Java 21**
- **H2 Database** - Banco em memória
- **MicroProfile JWT** - Autenticação
- **SmallRye Fault Tolerance** - Resiliência
- **RESTEasy Reactive** - REST endpoints
- **Hibernate ORM Panache** - ORM simplificado

### **Observabilidade** 🔍
- **OpenTelemetry** - Framework padrão de observabilidade
- **Jaeger** - Distributed tracing
- **Prometheus** - Coleta de métricas
- **Grafana** - Visualização de dashboards
- **MicroProfile Metrics** - Métricas customizadas
- **SmallRye Health** - Health checks avançados

---

## 📊 Observabilidade (OpenTelemetry Stack)

### **O que é Observabilidade?**

Observabilidade permite entender o que está acontecendo dentro da sua aplicação através de:

1. **Traces (Jaeger)** 👁️ - Rastreamento distribuído de requisições
2. **Métricas (Prometheus)** 📈 - Dados numéricos em tempo real
3. **Logs (Estruturados)** 📝 - Eventos detalhados

### **Tecnologias de Observabilidade**

#### **1. OpenTelemetry** (Framework)
Framework padrão da indústria para coleta de traces, métricas e logs.

```properties
# Ativado automaticamente
quarkus.otel.enabled=true
quarkus.otel.service.name=unipds-quarkus-api
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
```

**Recursos:**
- `@WithSpan` - Cria spans automáticos
- `@SpanAttribute` - Captura parâmetros
- Integração automática com HTTP, JDBC, JVM

#### **2. Jaeger** (Distributed Tracing)
Visualizar e analisar traces distribuídos.

**URL:** `http://localhost:16686`

**Funcionalidades:**
- Visualizar traces completos de requisições
- Analisar latência por operação
- Identificar gargalos
- Ver dependências entre serviços
- Buscar por trace ID ou service name

**Como usar:**
1. Abra http://localhost:16686
2. Service: `unipds-quarkus-api`
3. Clique "Find Traces"
4. Veja detalhes de cada requisição

#### **3. Prometheus** (Metrics)
Coleta de métricas em tempo real.

**URL:** `http://localhost:9090`

**Métricas Disponíveis:**
- `http_server_requests_seconds_count` - Contagem de requisições
- `http_server_requests_seconds_sum` - Tempo total
- `jvm_memory_used_bytes` - Memória JVM
- `process_cpu_usage` - CPU da aplicação
- `counted.getPessoa` - Métrica customizada

**Como usar:**
1. Abra http://localhost:9090
2. Digite uma métrica na barra de busca
3. Clique "Execute"
4. Visualize o gráfico

#### **4. Grafana** (Dashboards)
Visualização de dashboards baseados em Prometheus.

**URL:** `http://localhost:3000`  
**Credenciais:** `admin` / `admin`

**Funcionalidades:**
- Dashboards personalizados
- Alertas baseados em métricas
- Integração com Prometheus
- Exportar relatórios

**Como usar:**
1. Abra http://localhost:3000
2. Faça login (admin/admin)
3. Importe dashboards do Grafana.com
4. Crie alertas customizados

### **Stack de Observabilidade Completo**

```
┌─────────────────────────────────────┐
│  Quarkus Application (8080)         │
│  - @WithSpan annotations            │
│  - Automatic HTTP/JDBC tracing      │
│  - JVM Metrics                      │
└────────────────┬────────────────────┘
                 │ (OTLP gRPC)
        ┌────────┴────────┐
        │                 │
   ┌────▼────┐      ┌────▼────┐
   │  Jaeger  │      │Prometheus│
   │ (16686)  │      │  (9090)  │
   └──────────┘      └────┬─────┘
                           │
                      ┌────▼────┐
                      │ Grafana  │
                      │ (3000)   │
                      └──────────┘
```

---

## 🎯 Endpoints Disponíveis

### **Públicos (sem autenticação)**
- `GET /q/health` - Health check da aplicação
- `GET /q/metrics` - Métricas em formato Prometheus
- `GET /starwars/starships` - Lista naves Star Wars

### **Protegidos (requer JWT)**
- `GET /secure/claim` - Retorna username do token
- `GET /secure/info` - Retorna informações completas do JWT

### **CRUD Pessoa**
- `GET /pessoa` - Listar todas as pessoas
- `GET /pessoa/findByAnoNascimento?anoNascimento=1990` - Filtrar por ano
- `POST /pessoa` - Criar nova pessoa
- `PUT /pessoa` - Atualizar pessoa
- `DELETE /pessoa?id=1` - Deletar pessoa

### **Documentação**
- `GET /q/swagger-ui` - Documentação interativa (Swagger)
- `GET /q/openapi` - OpenAPI JSON

---

## 🚀 Como Executar

### **1. Inicie a Stack de Observabilidade**

**Opção A - Scripts Automáticos (Recomendado):**
```powershell
# Duplo clique em:
start-docker.bat
```

**Opção B - Manual:**
```powershell
docker compose up -d
```

Aguarde ~30 segundos até ver todos os 3 containers rodando:
- ✅ Jaeger
- ✅ Prometheus
- ✅ Grafana

### **2. Inicie a Aplicação em Modo Dev**

**Opção A - Scripts Automáticos:**
```powershell
# Duplo clique em:
start-quarkus.bat
```

**Opção B - Manual:**
```powershell
.\mvnw.cmd clean compile quarkus:dev
```

A aplicação estará disponível em: `http://localhost:8080`

### **3. Verifique Observabilidade**

```powershell
# Fazer uma requisição
curl http://localhost:8080/pessoa

# Aguarde 5-10 segundos

# Abra Jaeger para ver o trace
http://localhost:16686
```

---

## 🔐 Autenticação JWT

### **Obter Token de Teste**
```powershell
$token = curl.exe -s https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token
```

### **Fazer Requisição Autenticada**
```powershell
curl.exe -H "Authorization: Bearer $token" http://localhost:8080/secure/claim
```

---

## 📦 Estrutura do Projeto

```
src/main/java/org/unipds/
├── entity/
│   └── Pessoa.java                   # Entidade JPA
├── observability/
│   └── ObservabilityService.java     # Serviço de observabilidade (NOVO)
├── healthcheck/
│   ├── ApplicationReadinessCheck.java
│   └── StarWarsHealthCheck.java      # Health check personalizado
├── resource/
│   ├── PessoaResource.java           # CRUD REST com @WithSpan
│   ├── SecureResource.java           # Endpoints protegidos JWT
│   └── StarWarsResource.java         # Proxy API Star Wars com @WithSpan
└── service/
    └── StarWarsService.java          # REST Client

src/main/resources/
├── application.properties            # Configurações (dev)
└── application-prod.properties       # Configurações (prod)

Docker & Infrastructure:
├── docker-compose.yml                # Stack: Jaeger, Prometheus, Grafana
├── prometheus.yml                    # Config Prometheus scrape
├── start-docker.bat                  # Script automático Docker
└── start-quarkus.bat                 # Script automático Quarkus
```

---

## ⚙️ Configurações Principais

### **Banco de Dados**
```properties
quarkus.datasource.db-kind=h2
quarkus.datasource.jdbc.url=jdbc:h2:mem:test
```

### **JWT**
```properties
mp.jwt.verify.publickey.location=https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.pub
mp.jwt.verify.issuer=https://quarkus.io/using-jwt-rbac
```

### **REST Client**
```properties
quarkus.rest-client."org.unipds.service.StarWarsService".url=https://swapi.dev/api
```

### **OpenTelemetry (Desenvolvimento)**
```properties
quarkus.otel.enabled=true
quarkus.otel.service.name=unipds-quarkus-api
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
quarkus.otel.traces.sampler=always_on
quarkus.otel.metrics.exporter=otlp
```

### **OpenTelemetry (Produção)**
```properties
quarkus.otel.traces.sampler=parentbased_traceidratio
quarkus.otel.traces.sampler.arg=0.1  # 10% sampling
quarkus.otel.exporter.otlp.endpoint=https://seu-otel-collector.com
```

---

## 🧪 Scripts de Teste

| Script | Descrição |
|--------|-----------|
| `Test-Simple.ps1` | ⭐ Recomendado - 6 testes completos |
| `Test-Complete.ps1` | Testes com output detalhado |
| `Test-JWT.ps1` | Focado em autenticação JWT |
| `Test-OpenTelemetry.ps1` | Testa observabilidade (Jaeger, Prometheus, Grafana) |

---

## 📊 Dashboards Disponíveis

Após iniciar a stack, acesse:

| Dashboard | URL | Propósito |
|-----------|-----|----------|
| **Jaeger** | http://localhost:16686 | 👁️ Ver traces distribuídos |
| **Prometheus** | http://localhost:9090 | 📈 Consultar métricas |
| **Grafana** | http://localhost:3000 | 📊 Visualizar dashboards |
| **Swagger UI** | http://localhost:8080/q/swagger-ui | 📚 Documentação API |
| **Métricas Raw** | http://localhost:8080/q/metrics | 📝 Prometheus format |

---

## 📝 Documentação Adicional

### **OpenTelemetry & Observabilidade**
- `QUICKSTART.md` - Guia rápido (5 minutos)
- `START_DETALHADO.md` - Passo a passo com troubleshooting
- `OPENTELEMETRY_GUIDE.md` - Guia técnico completo
- `ARQUITETURA.md` - Diagramas e arquitetura
- `COMANDOS_PRONTOS.md` - Referência de comandos

### **Projeto**
- `HISTORICO_CORRECOES.md` - Histórico de problemas e soluções
- `http://localhost:8080/q/swagger-ui` - Documentação interativa (quando app rodando)

---

## 🔧 Comandos Úteis

### **Compilar**
```powershell
.\mvnw.cmd clean compile
```

### **Executar Testes**
```powershell
.\mvnw.cmd test
```

### **Empacotar**
```powershell
.\mvnw.cmd package
```

### **Executar JAR**
```powershell
java -jar target/quarkus-app/quarkus-run.jar
```

### **Parar Stack Docker**
```powershell
docker compose down
```

---

## 📦 Adicionar Extensões Quarkus

### **Sintaxe Correta**

Para adicionar novas bibliotecas (extensões) ao projeto Quarkus, use:

```powershell
.\mvnw.cmd quarkus:add-extension -Dextensions="<nome-da-extensao>"
```

### **Exemplos**

**Exemplo 1: Adicionar suporte a PostgreSQL**
```powershell
.\mvnw.cmd quarkus:add-extension -Dextensions="quarkus-jdbc-postgresql"
```

**Exemplo 2: Adicionar MongoDB**
```powershell
.\mvnw.cmd quarkus:add-extension -Dextensions="quarkus-mongodb-panache"
```

**Exemplo 3: Adicionar Redis**
```powershell
.\mvnw.cmd quarkus:add-extension -Dextensions="quarkus-redis-client"
```

**Exemplo 4: Adicionar múltiplas extensões**
```powershell
.\mvnw.cmd quarkus:add-extension -Dextensions="quarkus-jdbc-postgresql,quarkus-redis-client,quarkus-logging-json"
```

### **Encontrar Nome de Extensões**

Para listar todas as extensões disponíveis:

```powershell
.\mvnw.cmd quarkus:list-extensions
```

Ou visite: https://quarkus.io/extensions/

### **O Que Acontece**

Quando você executa o comando `quarkus:add-extension`:
1. A extensão é adicionada automaticamente ao `pom.xml`
2. As dependências são baixadas
3. A aplicação fica pronta para usar a nova funcionalidade

### **Extensões Mais Comuns**

| Extensão | Comando |
|----------|---------|
| **PostgreSQL** | `quarkus-jdbc-postgresql` |
| **MySQL** | `quarkus-jdbc-mysql` |
| **MongoDB** | `quarkus-mongodb-panache` |
| **Redis** | `quarkus-redis-client` |
| **Kafka** | `quarkus-kafka-client` |
| **AMQP** | `quarkus-amqp` |
| **S3/MinIO** | `quarkus-amazon-s3` |
| **Logging JSON** | `quarkus-logging-json` |
| **Metrics** | `quarkus-micrometer` |
| **OpenTelemetry** | `quarkus-opentelemetry` ✅ |

---

## 🐳 Docker

### **Build Imagem Docker**
```powershell
docker build -f src/main/docker/Dockerfile.jvm -t quarkus-app .
```

### **Executar Container**
```powershell
docker run -p 8080:8080 quarkus-app
```

### **Com OpenTelemetry**
```powershell
docker run -p 8080:8080 \
  -e QUARKUS_OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317 \
  quarkus-app
```

---

## ⚠️ Notas Importantes

### **Comando ERRADO para adicionar extensões:**
```powershell
# ❌ ISSO NÃO FUNCIONA
mvn quarkus:add-extension quarkus-jdbc-postgresql

# ❌ ISSO TAMBÉM NÃO
.\mvnw.cmd quarkus:add quarkus-jdbc-postgresql
```

### **Comando CORRETO:**
```powershell
# ✅ ISSO FUNCIONA
.\mvnw.cmd quarkus:add-extension -Dextensions="quarkus-jdbc-postgresql"
```

---

## 🎓 Conceitos Aprendidos

Este projeto demonstra:

### **Backend & APIs**
- Criar APIs REST com Quarkus
- Integração com APIs externas usando REST Client
- Persistência com Hibernate Panache
- Health checks personalizados

### **Segurança**
- Implementação de segurança JWT/RBAC
- MicroProfile JWT integration
- Role-based access control

### **Resiliência**
- Fault tolerance e circuit breakers
- Timeout e retry policies

### **Observabilidade** 🔍 (NOVO)
- Distributed tracing com OpenTelemetry & Jaeger
- Coleta de métricas com Prometheus
- Visualização com Grafana
- Custom spans e metrics
- Integração automática de HTTP, JDBC, JVM metrics
- Sampling strategies (dev vs prod)

---

## 📚 Recursos

- [Quarkus Documentation](https://quarkus.io/guides/)
- [OpenTelemetry](https://opentelemetry.io/)
- [Jaeger Tracing](https://www.jaegertracing.io/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [MicroProfile JWT](https://github.com/eclipse/microprofile-jwt-auth)
- [Star Wars API](https://swapi.dev/)

---

## 👥 Autor : Marcus Dimitri B.Costa

**Módulo 01 - Quarkus**  
Desenvolvimento de Aplicações Back-End

---

## 📄 Licença

Este projeto é parte de material educacional.

---

**Versão:** 1.1.0  
**Última Atualização:** 2026-03-04  
**Status:** ✅ Pronto para uso com Observabilidade Completa


