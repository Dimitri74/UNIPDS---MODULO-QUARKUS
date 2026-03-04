# 🚀 START - Guia Passo a Passo Detalhado

## ⚠️ IMPORTANTE: Leia ANTES de executar

Este guia resolve os problemas comuns encontrados no QUICKSTART.

---

## ✅ PRÉ-REQUISITOS OBRIGATÓRIOS

### 1. Docker Desktop
- [ ] Docker Desktop instalado
- [ ] Docker Desktop **ABERTO e RODANDO** (ícone na bandeja do sistema)
- [ ] Teste: Abra PowerShell e digite `docker --version`

### 2. Java
- [ ] Java 21+ instalado
- [ ] Teste: `java -version`

### 3. Terminal
- [ ] Use PowerShell ou CMD (não use Git Bash)
- [ ] Abra como Administrador se tiver problemas de permissão

---

## 📍 PASSO 1: Verificar Docker

Antes de tudo, certifique-se que o Docker está funcionando:

```powershell
# Teste se Docker responde
docker --version

# Deve mostrar algo como: Docker version 24.x.x
```

Se der erro, **PARE AQUI** e:
1. Abra o Docker Desktop
2. Aguarde ele inicializar completamente (ícone fica verde)
3. Tente novamente

---

## 📍 PASSO 2: Navegar para a Pasta do Projeto

```powershell
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"
```

Verifique se está na pasta certa:
```powershell
# Deve listar docker-compose.yml
dir docker-compose.yml
```

---

## 📍 PASSO 3: Iniciar Stack Docker

### Opção A: Docker Compose v2 (Novo)
```powershell
docker compose up -d
```

### Opção B: Docker Compose v1 (Antigo)
```powershell
docker-compose up -d
```

**Se der erro "command not found":**
- Use a outra opção (A ou B)
- Certifique-se que Docker Desktop está rodando

**Aguarde a saída:**
```
[+] Running 4/4
 ✔ Network code-with-quarkus_otel-network  Created
 ✔ Container jaeger                        Started
 ✔ Container prometheus                    Started
 ✔ Container grafana                       Started
```

### Verificar se está rodando:
```powershell
docker ps
```

**Você deve ver 3 containers:**
- `jaeger` (portas: 16686, 4317, 4318)
- `prometheus` (porta: 9090)
- `grafana` (porta: 3000)

**Se não aparecer nada:**
```powershell
# Ver logs de erro
docker compose logs

# Ver se há containers parados
docker ps -a
```

---

## 📍 PASSO 4: Compilar e Executar Quarkus

**IMPORTANTE:** Abra um NOVO terminal (não feche o anterior).

### No Windows:
```powershell
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"

.\mvnw.cmd clean compile quarkus:dev
```

### Se `mvnw.cmd` não funcionar:
```powershell
# Tente sem .cmd
.\mvnw clean compile quarkus:dev

# Ou use Maven instalado
mvn clean compile quarkus:dev
```

**Primeira execução pode demorar 2-5 minutos** (baixa dependências).

**Aguarde até ver:**
```
__  ____  __  _____   ___  __ ____  ______
 --/ __ \/ / / / _ | / _ \/ //_/ / / / __/
 -/ /_/ / /_/ / __ |/ , _/ ,< / /_/ /\ \
--\___\_\____/_/ |_/_/|_/_/|_|\____/___/
2024-XX-XX XX:XX:XX,XXX INFO  [io.quarkus] (Quarkus Main Thread) code-with-quarkus 1.0.0-SNAPSHOT on JVM (powered by Quarkus X.X.X) started in X.XXXs. Listening on: http://0.0.0.0:8080
```

**Se der erro "Porta 8080 ocupada":**
```powershell
# Encontrar processo
netstat -ano | findstr :8080

# Anotar o PID (última coluna)
# Matar processo (substitua 1234 pelo PID real)
taskkill /PID 1234 /F
```

---

## 📍 PASSO 5: Testar

Abra um TERCEIRO terminal:

```powershell
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"

# Testar health
curl http://localhost:8080/q/health

# Testar endpoint
curl http://localhost:8080/pessoa
```

**Se curl não funcionar no Windows:**
```powershell
# Use Invoke-WebRequest
Invoke-WebRequest -Uri http://localhost:8080/q/health

# Ou abra no navegador:
# http://localhost:8080/q/health
```

---

## 📍 PASSO 6: Ver Traces no Jaeger

1. Abra navegador: http://localhost:16686
2. Dropdown "Service": selecione `unipds-quarkus-api`
3. Clique "Find Traces"
4. Veja seus traces! 🎉

**Se não aparecer nada:**
- Faça mais algumas requisições
- Aguarde 10-15 segundos
- Clique "Find Traces" novamente
- Verifique se selecionou o serviço correto

---

## 📍 PASSO 7: Explorar Dashboards

### Jaeger (Traces)
**URL:** http://localhost:16686
- Ver traces de requisições
- Analisar latência
- Identificar gargalos

### Prometheus (Métricas)
**URL:** http://localhost:9090
- Consultar métricas com PromQL
- Exemplo: `http_server_requests_seconds_count`

### Grafana (Visualização)
**URL:** http://localhost:3000
- **Credenciais:** admin / admin
- Importar dashboards
- Criar alertas

---

## 🛑 PARAR TUDO (Limpeza)

### Terminal 1 (Quarkus):
Pressione `Ctrl+C`

### Terminal 2 (Docker):
```powershell
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"

docker compose down
```
ou
```powershell
docker-compose down
```

**Para limpar tudo (incluindo volumes):**
```powershell
docker compose down -v
```

---

## 🔧 TROUBLESHOOTING COMUM

### ❌ "docker: command not found"
**Causa:** Docker não instalado ou não está no PATH  
**Solução:**
1. Instale Docker Desktop
2. Reinicie o terminal
3. Teste: `docker --version`

### ❌ "Cannot connect to the Docker daemon"
**Causa:** Docker Desktop não está rodando  
**Solução:**
1. Abra Docker Desktop
2. Aguarde inicializar (ícone verde)
3. Tente novamente

### ❌ "port is already allocated"
**Causa:** Porta já está em uso  
**Solução:**
```powershell
# Ver processos nas portas
netstat -ano | findstr :8080
netstat -ano | findstr :16686
netstat -ano | findstr :9090

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

### ❌ "mvnw.cmd is not recognized"
**Causa:** Arquivo não encontrado ou sem permissão  
**Solução:**
```powershell
# Verificar se existe
dir mvnw.cmd

# Usar Maven instalado
mvn clean compile quarkus:dev

# Ou tentar sem .cmd
.\mvnw clean compile quarkus:dev
```

### ❌ "Jaeger não mostra traces"
**Causa:** Aplicação não está enviando ou service name errado  
**Solução:**
1. Verifique se aplicação está rodando: http://localhost:8080/q/health
2. Faça requisições: `curl http://localhost:8080/pessoa`
3. Aguarde 10-15 segundos
4. No Jaeger, selecione: `unipds-quarkus-api`
5. Clique "Find Traces"
6. Verifique configuração em `application.properties`:
   ```ini
   quarkus.otel.enabled=true
   quarkus.otel.exporter.otlp.endpoint=http://localhost:4317
   ```

### ❌ "Connection refused ao acessar localhost:4317"
**Causa:** Jaeger não está rodando  
**Solução:**
```powershell
# Verificar se Jaeger está rodando
docker ps | findstr jaeger

# Ver logs
docker logs jaeger

# Reiniciar
docker restart jaeger
```

---

## ✅ CHECKLIST DE VALIDAÇÃO

Após executar tudo, verifique:

- [ ] `docker ps` mostra 3 containers (jaeger, prometheus, grafana)
- [ ] http://localhost:8080/q/health responde
- [ ] http://localhost:8080/pessoa responde
- [ ] http://localhost:16686 abre Jaeger UI
- [ ] http://localhost:9090 abre Prometheus
- [ ] http://localhost:3000 abre Grafana (admin/admin)
- [ ] Jaeger mostra traces após fazer requisições
- [ ] `curl http://localhost:8080/q/metrics` mostra métricas

---

## 📞 AINDA COM PROBLEMAS?

### Verificar Logs

```powershell
# Logs da aplicação Quarkus
# (aparecem no terminal onde executou quarkus:dev)

# Logs do Jaeger
docker logs jaeger

# Logs do Prometheus
docker logs prometheus

# Logs do Grafana
docker logs grafana

# Todos os logs do Docker
docker compose logs -f
```

### Reiniciar Tudo

```powershell
# Parar tudo
docker compose down
Ctrl+C (no terminal do Quarkus)

# Limpar
docker compose down -v

# Iniciar novamente
docker compose up -d
.\mvnw.cmd clean compile quarkus:dev
```

---

## 🎯 RESUMO DOS COMANDOS

```powershell
# TERMINAL 1: Docker Stack
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"
docker compose up -d

# TERMINAL 2: Quarkus
cd "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"
.\mvnw.cmd clean compile quarkus:dev

# TERMINAL 3: Testes
curl http://localhost:8080/pessoa

# BROWSER:
# http://localhost:16686 (Jaeger)
# http://localhost:9090 (Prometheus)
# http://localhost:3000 (Grafana)
```

---

**Boa sorte! 🚀**

Se seguir este guia passo a passo, tudo deve funcionar perfeitamente!

