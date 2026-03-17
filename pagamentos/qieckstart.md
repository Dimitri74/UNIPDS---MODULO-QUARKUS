# qieckstart - Florinda Eats (3 aplicacoes)

Guia rapido para subir o ambiente completo no Windows PowerShell:
- `pedidos` (porta `8080`)
- `pagamentos` (porta `8081`)
- `notas-fiscais` (porta `8082`)

> Baseado no workspace `C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS`.

## Checklist

- [ ] Docker Desktop instalado
- [ ] Java 21 instalado
- [ ] Maven Wrapper (`mvnw.cmd`) presente nos projetos
- [ ] Portas livres: `8080`, `8081`, `8082`, `9092`, `2181`
- [ ] MySQL disponivel em `localhost:3306` (via container)

---

## 1) Ir para a raiz do workspace

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS"
```

---

## 2) Iniciar Docker (caso nao esteja ativo)

Teste rapido:

```powershell
docker info
```

Se der erro de daemon indisponivel, abra o Docker Desktop e aguarde:

```powershell
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
Start-Sleep -Seconds 20
docker info
```

---

## 3) Subir infraestrutura (MySQL + Kafka + Zookeeper)

Use o compose de `pagamentos` (atende as 3 apps):

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
docker compose up -d
docker compose ps
```

Ver logs (opcional):

```powershell
docker compose logs --tail 100 mysql
docker compose logs --tail 100 kafka
```

---

## 4) Validar MySQL e banco `chaves_food`

Nao precisa cliente MySQL fisico instalado na maquina.
Voce pode usar o cliente que ja vem dentro do proprio container.

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
docker exec chaves-food-mysql mysql -uquarkus -pquarkus -e "SHOW DATABASES;"
```

Se o nome do container nao for `chaves-food-mysql`, troque no comando acima.

---

## 5) Subir as 3 aplicacoes (3 terminais separados)

### Terminal 1 - pedidos (8080)

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pedidos"
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_USER="quarkus"
$env:DB_PASSWORD="quarkus"
.\mvnw.cmd quarkus:dev
```

### Terminal 2 - pagamentos (8081)

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_USER="quarkus"
$env:DB_PASSWORD="quarkus"
.\mvnw.cmd quarkus:dev
```

### Terminal 3 - notas-fiscais (8082)

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\notas-fiscais"
.\mvnw.cmd quarkus:dev
```

---

## 6) Testar endpoints

Em um 4o terminal:

```powershell
Invoke-WebRequest -Uri "http://localhost:8080/pedidos" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8081/pagamentos" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8082/nota-fiscal" -UseBasicParsing
```

Teste por ID (exemplo):

```powershell
Invoke-WebRequest -Uri "http://localhost:8080/pedidos/1" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:8082/nota-fiscal/pedido/1" -UseBasicParsing
```

---

## 7) Troubleshooting rapido

### A) `Connection refused: connect`

Geralmente nao existe servico ouvindo na porta (ex.: MySQL parado).

```powershell
docker compose ps
netstat -ano | findstr :3306
```

Se nao houver MySQL ativo, suba novamente:

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
docker compose up -d
```

### B) Porta `3306` ocupada

Descobrir processo:

```powershell
netstat -ano | findstr :3306
Get-Process -Id <PID>
```

Se outro container estiver usando `3306`, pare ele ou ajuste a porta no compose.

### C) `FlywayValidateException` / checksum mismatch

Quando migracoes antigas mudaram depois de aplicadas, o Flyway bloqueia subida.
Para ambiente local de teste, reset completo do banco costuma resolver:

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
docker compose down -v
docker compose up -d
```

Depois, suba novamente as apps.

### D) `Port already bound: 8080`

Ja existe processo na porta de `pedidos`.

```powershell
netstat -ano | findstr :8080
Get-Process -Id <PID>
Stop-Process -Id <PID> -Force
```

---

## 8) Encerrar ambiente

Parar Quarkus: `Ctrl + C` em cada terminal das apps.

Parar containers:

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
docker compose down
```

Limpar tambem os volumes (reset local total):

```powershell
docker compose down -v
```
