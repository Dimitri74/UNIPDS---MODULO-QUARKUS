# 🏗️ Arquitetura OpenTelemetry - Seu Setup Completo

## Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                       CLIENTE (Browser/API)                         │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    Requisição HTTP / REST
                                 │
┌────────────────────────────────▼────────────────────────────────────┐
│                   QUARKUS APPLICATION (8080)                         │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  REST Endpoints                                              │  │
│  │  ├─ /pessoa (CRUD com @WithSpan)                           │  │
│  │  ├─ /starwars/starships (com @WithSpan)                    │  │
│  │  ├─ /q/health (Health Check)                              │  │
│  │  └─ /q/metrics (Prometheus Metrics)                        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼──────────────────────────────┐   │
│  │  OpenTelemetry Instrumentation                             │   │
│  │  ├─ Tracer (@WithSpan automatic)                           │   │
│  │  ├─ Metrics (HTTP, JVM, Custom)                            │   │
│  │  └─ ObservabilityService (Injectable)                      │   │
│  └──────────────────────────────────────────────────────────────┘  │
│                                 │                                    │
│  ┌──────────────────────────────▼──────────────────────────────┐   │
│  │  OTLP Exporter (gRPC)                                      │   │
│  │  └─ localhost:4317                                         │   │
│  └──────────────────────────────┬──────────────────────────────┘   │
│                                 │                                    │
└─────────────────────────────────┼────────────────────────────────────┘
                                  │
                    OTLP Protocol (gRPC/HTTP)
                                  │
                  ┌───────────────┼───────────────┐
                  │               │               │
    ┌─────────────▼──────┐   ┌────▼────────┐   ┌─▼──────────────┐
    │   JAEGER (16686)   │   │ PROMETHEUS  │   │  GRAFANA       │
    │   Tracing Server   │   │  (9090)     │   │  (3000)        │
    │                    │   │             │   │                │
    │ - Distributed      │   │ - Scrapes   │   │ - Visualizes   │
    │   Traces           │   │   metrics   │   │   Dashboards   │
    │ - Latency          │   │ - Stores    │   │ - Alerts       │
    │ - Dependencies     │   │   TSDB      │   │ - Reports      │
    │ - UI Explorer      │   │ - PromQL    │   │                │
    └────────────────────┘   └─────────────┘   └────────────────┘
```

---

## 📊 Flow de Dados

### Request → Trace → Storage → Visualization

```
1. CLIENTE FAZ REQUISIÇÃO
   │
   └──► http://localhost:8080/pessoa
        │
        
2. QUARKUS INTERCEPTA
   │
   ├─► @WithSpan cria Span automaticamente
   ├─► Executa lógica de negócio
   ├─► Coleta métricas (latência, status)
   └─► Retorna resposta

3. OPENTELEMETRY EXPORTER
   │
   └──► Envia via OTLP (gRPC) para
        │
        ├─► Jaeger (Traces)
        ├─► Prometheus (Metrics)
        └─► Grafana (Dashboard)

4. ARMAZENAMENTO & VISUALIZAÇÃO
   │
   ├─► Jaeger mostra trace timeline
   ├─► Prometheus acumula séries temporais
   └─► Grafana cria dashboards visuais
```

---

## 🔄 Componentes Integrados

```
┌──────────────────────────────────────────────────────────┐
│                   QUARKUS (Aplicação)                    │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  PessoaResource              StarWarsResource            │
│  ├─ @WithSpan                ├─ @WithSpan               │
│  ├─ @SpanAttribute           └─ ObservabilityService    │
│  └─ @Counted (Metrics)                                  │
│                              ObservabilityService       │
│                              ├─ Tracer injection        │
│                              ├─ Meter injection         │
│                              └─ Custom spans            │
│                                                           │
├──────────────────────────────────────────────────────────┤
│              OpenTelemetry Auto-Instrumentation          │
│  ├─ HTTP Server (automatic)                             │
│  ├─ JDBC (database queries)                             │
│  ├─ JVM Metrics (memory, threads)                       │
│  └─ Custom Metrics (@Counted, @WithSpan)               │
│                                                           │
├──────────────────────────────────────────────────────────┤
│               OTLP Exporter (gRPC)                       │
│  └─ Endpoint: localhost:4317                            │
│                                                           │
└──────────────────────────────────────────────────────────┘
         ↓         ↓              ↓
      JAEGER   PROMETHEUS      GRAFANA
```

---

## 📁 Estrutura de Arquivos

```
code-with-quarkus/
│
├── Docker & Infrastructure
│   ├── docker-compose.yml              ← Orquestra tudo
│   ├── prometheus.yml                  ← Config scrape
│   └── src/main/docker/Dockerfile.jvm  ← App container
│
├── Java Code
│   └── src/main/java/org/unipds/
│       ├── observability/
│       │   └── ObservabilityService.java    ← Novo!
│       │
│       ├── resource/
│       │   ├── PessoaResource.java          ← @WithSpan
│       │   └── StarWarsResource.java        ← @WithSpan
│       │
│       └── entity/, service/, healthcheck/
│
├── Configuration
│   └── src/main/resources/
│       ├── application.properties           ← Dev config
│       └── application-prod.properties      ← Prod config
│
├── Maven
│   └── pom.xml                         ← OpenTelemetry deps
│
├── Documentation
│   ├── OPENTELEMETRY_GUIDE.md         ← Guia completo
│   ├── IMPLEMENTACAO_RESUMO.md        ← Resumo técnico
│   └── QUICKSTART.md                  ← Quick start
│
└── Testing
    ├── Test-OpenTelemetry.ps1         ← Suite de testes
    └── Test-*.ps1                     ← Outros testes
```

---

## 🔄 Cycle de Observabilidade

```
REQUEST
  │
  ▼
┌─────────────────────────────┐
│  Quarkus Application        │
│  - Processa requisição      │
│  - Cria spans               │
│  - Coleta métricas          │
└────────────────┬────────────┘
                 │
                 ▼ (OTLP gRPC)
         ┌───────────────┐
         │ JAEGER Agent  │
         └───────┬───────┘
                 │
         ┌───────┴─────────┐
         │                 │
         ▼                 ▼
    ┌────────┐         ┌──────────┐
    │ JAEGER │         │PROMETHEUS│
    │  (UI)  │         │ (Metrics)│
    └────────┘         └────┬─────┘
                             │
                             ▼
                        ┌──────────┐
                        │ GRAFANA  │
                        │(Dashboard)
                        └──────────┘

         ▲
         └─── HUMAN VISUALIZATION ───┘
```

---

## 🎯 Que tipo de dados são coletados?

### Traces (Jaeger)
```
GET /pessoa
├─ Start: 14:30:25.123
├─ End: 14:30:25.273
├─ Duration: 150ms
│
├─ Span: HTTP Request Handler
│   └─ Duration: 150ms
│
├─ Span: Database Query
│   └─ Duration: 50ms
│   └─ SQL: SELECT * FROM pessoa
│
└─ Span: JSON Serialization
    └─ Duration: 20ms
```

### Metrics (Prometheus)
```
http_server_requests_seconds_count{
    method="GET",
    path="/pessoa",
    status="200"
} 42

http_server_requests_seconds_sum{
    method="GET",
    path="/pessoa"
} 6.3

jvm_memory_used_bytes{area="heap"} 256000000
```

### Dashboards (Grafana)
```
┌─────────────────────────────────────────┐
│ API Performance Dashboard               │
├─────────────────────────────────────────┤
│                                         │
│  Requests/sec: 127         Status:✅    │
│  Avg Latency: 45ms         P95: 120ms  │
│  Error Rate: 0.2%          P99: 250ms  │
│                                         │
│  [Graph] Latency Trend                 │
│  [Graph] Request Distribution           │
│  [Graph] Error Rate                     │
│  [Graph] JVM Memory Usage               │
│                                         │
└─────────────────────────────────────────┘
```

---

## ⚙️ Configurações por Ambiente

### 🔧 Development (application.properties)
```ini
quarkus.otel.traces.sampler=always_on        # Trace tudo
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
quarkus.log.level=INFO
```

### 🏢 Production (application-prod.properties)
```ini
quarkus.otel.traces.sampler=parentbased_traceidratio
quarkus.otel.traces.sampler.arg=0.1           # Trace 10%
quarkus.otel.exporter.otlp.endpoint=https://otel.prod.com
quarkus.log.level=WARN
```

---

## 📊 Dashboard URLs

| Ferramenta | URL | Função |
|-----------|-----|--------|
| **Jaeger** | http://localhost:16686 | Visualizar traces distribuídos |
| **Prometheus** | http://localhost:9090 | Consultar métricas com PromQL |
| **Grafana** | http://localhost:3000 | Dashboard visual (admin/admin) |
| **App** | http://localhost:8080 | API REST |
| **Metrics** | http://localhost:8080/q/metrics | Raw Prometheus metrics |

---

## 🔌 Conexões

```
Quarkus → OTLP (localhost:4317, gRPC) → Jaeger
                                      → Prometheus
                                      → Grafana
```

---

## ✅ Status da Implementação

```
┌─────────────────────────────────────┐
│  OPENTELEMETRY INTEGRATION COMPLETE │
├─────────────────────────────────────┤
│ ✅ Dependências Maven               │
│ ✅ Configuração OTEL               │
│ ✅ Docker Compose Stack             │
│ ✅ Prometheus Setup                 │
│ ✅ Grafana Setup                    │
│ ✅ ObservabilityService             │
│ ✅ @WithSpan Annotations            │
│ ✅ Dockerfile Updated               │
│ ✅ Documentation                    │
│ ✅ Test Scripts                     │
│ ✅ Project Compiled ✓              │
└─────────────────────────────────────┘
```

---

**Tudo pronto! Inicie com: `docker-compose up -d && ./mvnw quarkus:dev`** 🚀

