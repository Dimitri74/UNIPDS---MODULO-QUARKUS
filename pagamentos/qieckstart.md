# qieckstart - pagamentos

Guia rapido para subir a API `pagamentos` com Quarkus + MySQL local.

## Checklist

- [ ] Docker Desktop em execucao
- [ ] Java 21 instalado
- [ ] Porta `3306` livre (MySQL)
- [ ] Porta `8081` livre (API)

## 1) Abrir a pasta do projeto

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
```

## 2) Subir o MySQL com Docker Compose

O `docker-compose.yml` ja cria o banco `chaves_food` com usuario `quarkus`.

```powershell
docker compose up -d
```

Validar se o container esta em execucao:

```powershell
docker compose ps
```

Ver logs do MySQL (opcional, para confirmar prontidao):

```powershell
docker compose logs -f mysql
```

## 3) Subir a aplicacao Quarkus

Em outro terminal:

```powershell
Set-Location "C:\Users\marcu\workspace\UNIPDS\UNIPDS---MODULO-QUARKUS\pagamentos"
.\mvnw.cmd quarkus:dev
```

A API sobe na porta `8081`.

## 4) Testar a API

Listar pagamentos:

```powershell
Invoke-RestMethod -Uri "http://localhost:8081/pagamentos" -Method GET | ConvertTo-Json -Depth 5
```

Se o Flyway aplicou as migracoes, o retorno deve ter registros.

## 5) Parar o ambiente

Parar Quarkus: `Ctrl + C` no terminal da aplicacao.

Parar banco:

```powershell
docker compose down
```

Se quiser remover tambem o volume de dados:

```powershell
docker compose down -v
```

## Comandos uteis

Rebuild rapido sem testes:

```powershell
.\mvnw.cmd -DskipTests package
```

Build de verificacao:

```powershell
.\mvnw.cmd verify
```

## Troubleshooting

### Erro: `Connection refused`

Nao ha servico ouvindo em `localhost:3306`.

```powershell
docker compose up -d
docker compose ps
```

### Erro: porta `3306` ocupada

Descubra quem esta usando a porta:

```powershell
netstat -ano | findstr :3306
```

Pare o container/processo conflitante e suba novamente o compose.

### Erro de autenticacao MySQL

A aplicacao usa por padrao:

- banco: `chaves_food`
- usuario: `quarkus`
- senha: `quarkus`

Se necessario, sobrescreva no terminal antes de subir o Quarkus:

```powershell
$env:DB_USER="quarkus"
$env:DB_PASSWORD="quarkus"
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
.\mvnw.cmd quarkus:dev
```

