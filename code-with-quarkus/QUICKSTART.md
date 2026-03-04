# Quick Start OpenTelemetry

## ⚡ 5 Minutos para Observabilidade Completa

---

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:
- ✅ Docker Desktop instalado e **RODANDO**
- ✅ Java 21+ instalado
- ✅ Maven 3.8+ (ou use o mvnw incluído)

---

## 🚀 Passo a Passo

### Passo 1: Inicie Docker Compose (Stack de Observabilidade)

**Abra um terminal PowerShell ou CMD** na pasta `code-with-quarkus` e execute:

**Opção A - Docker Compose v2 (recomendado):**
```powershell
docker compose up -d
```

**Opção B - Docker Compose v1:**
```powershell
docker-compose up -d
```

**O que isso faz?**
- Inicia Jaeger (traces) na porta 16686
- Inicia Prometheus (métricas) na porta 9090
- Inicia Grafana (dashboards) na porta 3000

**Aguarde ~30-60 segundos** para todos os containers iniciarem.

**Verificar se está funcionando:**
```powershell
docker ps
```
Você deve ver 3 containers: `jaeger`, `prometheus`, `grafana`

---

### Passo 2: Compile e Execute a Aplicação

**Em um NOVO terminal**, execute:

**No Windows (PowerShell ou CMD):**
```powershell
.\mvnw.cmd clean compile quarkus:dev
```

**No Linux/Mac:**
```bash
./mvnw clean compile quarkus:dev
```

**Aguarde até ver:**
```
Listening on: http://0.0.0.0:8080
```

⚠️ **Nota:** O primeiro build pode demorar 2-3 minutos pois o Maven baixa dependências.

---

### Passo 3: Teste a Observabilidade

**Em um TERCEIRO terminal**, execute o script de testes:

**Windows:**
```powershell
.\Test-OpenTelemetry.ps1
```

**Ou teste manualmente:**
```powershell
# Testar health check
curl http://localhost:8080/q/health

# Testar endpoint pessoa
curl http://localhost:8080/pessoa

# Testar Star Wars
curl http://localhost:8080/starwars/starships
```

---

### Passo 4: Acesse os Dashboards

Abra no seu navegador:

| Ferramenta | URL | Credenciais |
|-----------|-----|------------|
| **Jaeger (Traces)** | http://localhost:16686 | - |
| **Prometheus (Métricas)** | http://localhost:9090 | - |
| **Grafana (Dashboard)** | http://localhost:3000 | admin / admin |
| **API Quarkus** | http://localhost:8080 | - |
| **Métricas Raw** | http://localhost:8080/q/metrics | - |

#### 👁️ Ver Traces no Jaeger:
1. Acesse http://localhost:16686
2. No dropdown "Service", selecione: `unipds-quarkus-api`
3. Clique em "Find Traces"
4. Veja os traces das suas requisições! 🎉

---

## 🧪 Teste Rápido Manual

Faça algumas requisições para gerar traces:

```powershell
# Listar pessoas
curl http://localhost:8080/pessoa

# Criar pessoa
curl -X POST http://localhost:8080/pessoa -H "Content-Type: application/json" -d "{\"nome\":\"João\",\"anoNascimento\":1990}"

# Star Wars API
curl http://localhost:8080/starwars/starships
```

**Aguarde 5-10 segundos** e recarregue o Jaeger UI para ver os traces!

---

## 🛑 Parar Tudo

### Parar Docker Stack:
```powershell
docker compose down
```
ou
```powershell
docker-compose down
```

### Parar Aplicação Quarkus:
Pressione `Ctrl+C` no terminal onde está rodando.

---

## 🔧 Troubleshooting

### ❌ Problema: "docker compose not found"
**Solução:**
- Certifique-se de que o Docker Desktop está **rodando**
- Tente `docker-compose` (com hífen) em vez de `docker compose`
- Verifique: `docker --version`

### ❌ Problema: "Porta 8080 já em uso"
**Solução:**
```powershell
# Encontrar processo usando porta 8080
netstat -ano | findstr :8080

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

### ❌ Problema: "Jaeger não mostra traces"
**Solução:**
1. Verifique se Jaeger está rodando: `docker ps | findstr jaeger`
2. Faça uma requisição: `curl http://localhost:8080/pessoa`
3. Aguarde 10 segundos
4. Recarregue Jaeger UI
5. Selecione o serviço correto: `unipds-quarkus-api`

### ❌ Problema: "mvnw.cmd não funciona"
**Solução:**
```powershell
# Use Maven instalado no sistema
mvn clean compile quarkus:dev
```

---

## ✅ Checklist Rápido

- [ ] Docker Desktop rodando
- [ ] `docker compose up -d` executado com sucesso
- [ ] 3 containers rodando (jaeger, prometheus, grafana)
- [ ] `.\mvnw.cmd quarkus:dev` executado
- [ ] Aplicação rodando em http://localhost:8080
- [ ] Jaeger acessível em http://localhost:16686
- [ ] Requisição de teste feita
- [ ] Traces visíveis no Jaeger

---

## 📚 Próximos Passos

Após o setup funcionar:
1. Leia **OPENTELEMETRY_GUIDE.md** para entender em detalhes
2. Leia **ARQUITETURA.md** para entender o design
3. Consulte **COMANDOS_PRONTOS.md** para referência rápida

---

## 🆘 Problemas? Leia o Guia Detalhado

Se você está tendo dificuldades, consulte:
- **START_DETALHADO.md** - Guia passo a passo com troubleshooting completo
- **COMANDOS_PRONTOS.md** - Comandos prontos para copiar e colar

Ou use os scripts automatizados:
- **start-docker.bat** - Inicia stack Docker automaticamente
- **start-quarkus.bat** - Inicia aplicação Quarkus automaticamente

---

✅ **Implementação OpenTelemetry concluída com sucesso!**  
🚀 **Todos os arquivos criados, compilados e prontos para uso.**

Se tiver problemas, consulte os outros documentos ou verifique os logs:
```powershell
docker logs jaeger
docker logs prometheus
```

