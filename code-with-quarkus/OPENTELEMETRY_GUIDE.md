# OpenTelemetry Integration Guide

## 📊 Visão Geral

Esta aplicação Quarkus foi integrada com **OpenTelemetry** para observabilidade completa através de:
- **Tracing Distribuído** (Jaeger)
- **Métricas** (Prometheus)
- **Visualização** (Grafana)

## 🚀 Como Começar

### 1. Pré-requisitos

- Docker e Docker Compose instalados
- Maven 3.8+ 
- Java 21+

### 2. Inicie a Stack de Observabilidade

```bash
cd code-with-quarkus
docker-compose up -d
```

Isso inicia:
- **Jaeger UI**: http://localhost:16686
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **Aplicação Quarkus**: http://localhost:8080

### 3. Compile e Execute a Aplicação

**Modo Desenvolvimento (sem Docker):**
```bash
./mvnw clean compile quarkus:dev
```

**Com Docker Compose:**
```bash
docker-compose up
```

## 📈 Acessando os Dashboards

### Jaeger (Tracing Distribuído)
- **URL**: http://localhost:16686
- **Recurso**: unipds-quarkus-api
- Visualize traces de requisições end-to-end

### Prometheus (Métricas)
- **URL**: http://localhost:9090
- Consulte métricas em PromQL
- Exemplo: `http_server_requests_seconds_count{service_name="unipds-quarkus-api"}`

### Grafana (Visualização)
- **URL**: http://localhost:3000
- **Credenciais**: admin / admin
- Importe dashboards para visualizar métricas

## 🔧 Configuração

### application.properties (Desenvolvimento)

```ini
# OpenTelemetry
quarkus.otel.enabled=true
quarkus.otel.service.name=unipds-quarkus-api
quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
quarkus.otel.traces.sampler=always_on
```

### application-prod.properties (Produção)

```ini
# Sampling reduzido em produção
quarkus.otel.traces.sampler=parentbased_traceidratio
quarkus.otel.traces.sampler.arg=0.1
quarkus.otel.exporter.otlp.endpoint=https://seu-otel-collector.com
```

## 📝 Implementação no Código

### Adicionar Tracing a um Método

```java
import io.opentelemetry.instrumentation.annotations.WithSpan;
import io.opentelemetry.instrumentation.annotations.SpanAttribute;

@WithSpan
public Response processarDados(@SpanAttribute String id) {
    // seu código
    return response;
}
```

### Usar ObservabilityService

```java
@Inject
ObservabilityService observabilityService;

// Tracer manual
Tracer tracer = observabilityService.getTracer();
Span span = tracer.spanBuilder("minha-operacao").startSpan();
try {
    // seu código
} finally {
    span.end();
}
```

## 🔍 Exemplos de Uso

### Testar Tracing

```bash
# Requisição simples
curl http://localhost:8080/starwars/starships

# Com dados
curl -X POST http://localhost:8080/pessoa \
  -H "Content-Type: application/json" \
  -d '{"nome":"João", "anoNascimento":1990}'
```

Após fazer requisições, vá para http://localhost:16686 e procure por "unipds-quarkus-api" para ver os traces.

## 📊 Métricas Disponíveis

### Automáticas (Quarkus)

- `http_server_requests_seconds_count` - Contagem de requisições HTTP
- `http_server_requests_seconds_sum` - Tempo total de requisições
- `http_server_requests_seconds_max` - Requisição mais lenta
- `jvm_memory_used_bytes` - Memória JVM utilizada
- `process_cpu_usage` - CPU da aplicação

### Customizadas

- `counted.getPessoa` - Contagem de chamadas `getPessoa()`
- Spans customizados via `@WithSpan`

## 🐳 Docker - Ambiente Completo

O `docker-compose.yml` inclui:

```yaml
- jaeger:4317        # OTLP gRPC receiver
- jaeger:16686       # UI
- prometheus:9090    # Métricas
- grafana:3000       # Visualização
- quarkus-app:8080   # Sua aplicação
```

## 🔐 Produção - Configurações Importantes

### 1. Sampling Reduzido
```ini
quarkus.otel.traces.sampler=parentbased_traceidratio
quarkus.otel.traces.sampler.arg=0.1  # 10% de sampling
```

### 2. Batch Processing
```ini
quarkus.otel.bsp.max.queue.size=512
quarkus.otel.bsp.max.export.batch.size=256
```

### 3. Atributos de Contexto
```ini
quarkus.otel.resource.attributes=environment=production,region=br-sp,team=backend
```

## 🛠️ Troubleshooting

### Jaeger não conecta

```bash
# Verifique se Jaeger está rodando
docker ps | grep jaeger

# Logs do Jaeger
docker logs jaeger
```

### Sem traces no Jaeger

1. Verifique se `QUARKUS_OTEL_ENABLED=true`
2. Confira o endpoint OTLP
3. Faça uma requisição: `curl http://localhost:8080/pessoa`
4. Aguarde 5-10 segundos e recarregue Jaeger

### Métricas não aparecem no Prometheus

1. Verifique `quarkus.otel.metrics.exporter=otlp`
2. Acesse http://localhost:8080/q/metrics (formato Prometheus)
3. Configure scrape_interval apropriado

## 📚 Recursos Adicionais

- [OpenTelemetry Docs](https://opentelemetry.io/docs/)
- [Quarkus OpenTelemetry](https://quarkus.io/guides/opentelemetry)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Prometheus Queries](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## 🎯 Próximos Passos

1. ✅ Integração básica completa
2. 📊 Criar dashboards no Grafana
3. 🚨 Configurar alertas (AlertManager)
4. 🔄 Implementar trace correlation em microserviços
5. 📉 Otimizar sampling em produção

