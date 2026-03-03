# 📊 Pacote HealthCheck - Documentação

## 📁 Estrutura Criada

```
org.unipds/
├── resource/
│   ├── GreetingResource.java
│   └── StarWarsResource.java
├── service/
│   └── StarWarsService.java
└── healthcheck/                    ← NOVO PACOTE
    ├── StarWarsHealthCheck.java
    └── ApplicationReadinessCheck.java
```

## 🏥 Classes de Health Check

### 1. StarWarsHealthCheck
**Objetivo:** Verificar a disponibilidade da API Star Wars

**Tipo:** `@Liveness` - Verifica se a aplicação está viva

**O que faz:**
- Tenta fazer uma chamada à API Star Wars
- Retorna status UP/DOWN baseado na resposta
- Inclui informações sobre o endpoint

**URL:** `http://localhost:8080/q/health/live`

**Resposta quando UP:**
```json
{
  "status": "UP",
  "checks": [
    {
      "name": "StarWars API Health Check",
      "status": "UP",
      "data": {
        "status": "API Star Wars está respondendo",
        "endpoint": "https://swapi.dev/api/starships"
      }
    }
  ]
}
```

---

### 2. ApplicationReadinessCheck
**Objetivo:** Verificar se a aplicação está pronta para receber requisições

**Tipo:** `@Readiness` - Verifica prontidão da aplicação

**O que faz:**
- Verifica se a aplicação iniciou corretamente
- Retorna informações sobre a aplicação
- Sempre retorna UP (indicando que a app está pronta)

**URL:** `http://localhost:8080/q/health/ready`

**Resposta:**
```json
{
  "status": "UP",
  "checks": [
    {
      "name": "Application Readiness Check",
      "status": "UP",
      "data": {
        "status": "Aplicação está pronta",
        "version": "1.0.0",
        "name": "code-with-quarkus"
      }
    }
  ]
}
```

---

## 🔍 Endpoints de Health Check

| URL | Descrição |
|-----|-----------|
| `http://localhost:8080/q/health` | Saúde geral (tudo) |
| `http://localhost:8080/q/health/live` | Liveness - Aplicação está viva? |
| `http://localhost:8080/q/health/ready` | Readiness - Está pronta? |
| `http://localhost:8080/q/health/startup` | Startup - Iniciou corretamente? |

---

## 🧪 Como Testar

### Via Swagger UI
1. Acesse: http://localhost:8080/q/swagger-ui/
2. Procure por **Health Check**
3. Execute os endpoints

### Via PowerShell
```powershell
# Health geral
Invoke-RestMethod -Uri "http://localhost:8080/q/health" | ConvertTo-Json

# Apenas liveness (Star Wars)
Invoke-RestMethod -Uri "http://localhost:8080/q/health/live" | ConvertTo-Json

# Apenas readiness (Aplicação)
Invoke-RestMethod -Uri "http://localhost:8080/q/health/ready" | ConvertTo-Json
```

### Via Browser
- http://localhost:8080/q/health
- http://localhost:8080/q/health/live
- http://localhost:8080/q/health/ready

---

## 🎯 Diferenças: Liveness vs Readiness

| Aspecto | Liveness | Readiness |
|---------|----------|-----------|
| **Verifica** | Aplicação está viva? | Pronta para requisições? |
| **Falha quando** | Serviço externo cai | Recursos não carregaram |
| **Ação quando falha** | Kubernetes faz RESTART | Kubernetes aguarda |
| **Exemplo** | API Star Wars offline | DB ainda não conectou |

---

## 💾 Modificação no application.properties (Opcional)

Se quiser customizar os health checks, você pode adicionar:

```properties
# Habilitar endpoints de health
quarkus.smallrye-health.enabled=true

# Mostrar detalhes mesmo em modo production
quarkus.smallrye-health.include-ui=true

# Customizar status codes
quarkus.smallrye-health.failure-status-code=503
```

---

## 🚀 Próximas Melhorias Opcionais

1. **Health Check do Banco de Dados** (quando implementar)
   ```java
   @Readiness
   public class DatabaseHealthCheck implements HealthCheck { ... }
   ```

2. **Health Check de Cache**
   ```java
   @Liveness
   public class CacheHealthCheck implements HealthCheck { ... }
   ```

3. **Custom Metrics**
   ```java
   @Metric
   Counter requests;
   ```

---

## 📝 Resumo

✅ Dois health checks implementados:
- ✅ `StarWarsHealthCheck` - Verifica API externa
- ✅ `ApplicationReadinessCheck` - Verifica prontidão da app

✅ Pacote criado: `org.unipds.healthcheck`

✅ Acessível via endpoints padrão do Quarkus

