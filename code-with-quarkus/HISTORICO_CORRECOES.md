# 📋 Histórico de Correções e Testes

## 🎯 Resumo Executivo

Este documento consolida todos os problemas encontrados durante o desenvolvimento e testes da aplicação Quarkus com JWT/RBAC, e suas respectivas soluções.

---

## 🔴 Problemas Encontrados e Soluções

### **1. Erro de Compilação - StarWarsHealthCheck**

**Problema:**
```
cannot find symbol: method withData(String, String)
```

**Causa:** Uso incorreto da API `HealthCheckResponse`

**Solução:**
```java
// Antes (ERRADO)
return HealthCheckResponse.up("Message");

// Depois (CORRETO)
return HealthCheckResponse.builder()
    .up()
    .name("StarWars API Health Check")
    .withData("status", "I am Ready!")
    .build();
```

**Arquivo:** `src/main/java/org/unipds/healthcheck/StarWarsHealthCheck.java`

---

### **2. Erro 404 - Endpoints Não Encontrados**

**Problema:**
```
ERRO - (404) Não Localizado
```

**Causa:** Scripts de teste usavam prefixo `/api` inexistente

**Solução:**
| Estava (ERRADO) | Correto |
|---|---|
| `/api/starwars/starships` ❌ | `/starwars/starships` ✅ |
| `/api/secure/claim` ❌ | `/secure/claim` ✅ |

**Arquivos Corrigidos:** 
- `Test-Simple.ps1`
- `Test-Complete.ps1`
- `Test-Simple.bat`

---

### **3. Erro 403 (Forbidden) - JWT com Role Inválida**

**Problema:**
```
ERRO - (403) Proibido
Status: Forbidden
```

**Causa:** Token válido mas role não correspondia ao esperado

**Solução:**
```java
// Antes (ERRADO - só 1 role)
@RolesAllowed("Not-Subscriber")

// Depois (CORRETO - múltiplas roles)
@RolesAllowed({"Not-Subscriber", "Subscriber", "Admin", "User"})
```

**Adicionado em `application.properties`:**
```properties
quarkus.smallrye-jwt.claims.groups.path=groups
```

**Novo endpoint criado:**
- `/secure/info` - Retorna informações completas do token JWT

**Arquivo:** `src/main/java/org/unipds/resource/SecureResource.java`

---

### **4. Problema com Caracteres Especiais no PowerShell**

**Problema:**
```
O termo 'primeiros' não é reconhecido como nome de cmdlet
```

**Causa:** Caracteres Unicode (✓, acentuação) causavam erros no PowerShell

**Solução:** Scripts reescritos sem caracteres especiais, usando apenas ASCII

**Arquivos Corrigidos:**
- `Test-Simple.ps1`
- `Test-JWT.ps1`

---

## 🚀 Como Executar os Testes

### **Passo 1: Iniciar a Aplicação**
```powershell
.\mvnw.cmd quarkus:dev
```

### **Passo 2: Executar Testes (em outro terminal)**
```powershell
.\Test-Simple.ps1
```

---

## 📊 Testes Disponíveis

### **Test-Simple.ps1** (Recomendado - 6 testes)
1. Health Check (`/q/health`)
2. Star Wars API (`/starwars/starships`)
3. Endpoint seguro SEM token - deve retornar 401
4. Download do token JWT
5. Endpoint seguro COM token (`/secure/claim`)
6. Informações do JWT (`/secure/info`)

### **Test-Complete.ps1** (Completo - 5 testes)
- Testes similares ao Test-Simple mas com saída mais detalhada

### **Test-JWT.ps1** (Focado em JWT)
- Foca apenas em testes de autenticação JWT

---

## 🎯 Endpoints da Aplicação

| Endpoint | Método | Auth | Descrição |
|----------|--------|------|-----------|
| `/q/health` | GET | ❌ | Health check da aplicação |
| `/starwars/starships` | GET | ❌ | Lista naves Star Wars (API externa) |
| `/secure/claim` | GET | ✅ JWT | Retorna username do token |
| `/secure/info` | GET | ✅ JWT | Retorna informações completas do JWT |

---

## 🔐 Testando JWT Manualmente

### **Baixar Token:**
```powershell
$token = curl.exe -s https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token
```

### **Testar Endpoint Protegido:**
```powershell
curl.exe -H "Authorization: Bearer $token" http://localhost:8080/secure/claim
```

### **Ver Informações do Token:**
```powershell
curl.exe -H "Authorization: Bearer $token" http://localhost:8080/secure/info
```

---

## 📝 Códigos HTTP

| Código | Nome | Significado |
|--------|------|-------------|
| **200** | OK | ✅ Sucesso |
| **401** | Unauthorized | ❌ Token não enviado/inválido |
| **403** | Forbidden | ❌ Token válido mas sem permissão |
| **404** | Not Found | ❌ Endpoint não existe |

---

## ✨ Arquivos Principais

```
code-with-quarkus/
├── src/main/java/org/unipds/
│   ├── entity/
│   │   └── Pessoa.java
│   ├── healthcheck/
│   │   ├── ApplicationReadinessCheck.java
│   │   └── StarWarsHealthCheck.java
│   ├── resource/
│   │   ├── PessoaResource.java
│   │   ├── SecureResource.java          # JWT/RBAC
│   │   └── StarWarsResource.java
│   └── service/
│       └── StarWarsService.java
├── src/main/resources/
│   └── application.properties           # Configurações JWT
├── Test-Simple.ps1                      # Script de testes (6 testes)
├── Test-Complete.ps1                    # Script completo
├── Test-JWT.ps1                         # Testes JWT
└── README.md                            # Documentação principal
```

---

## 🔧 Configurações Importantes

### **application.properties**
```properties
# Banco H2 em memória
quarkus.datasource.db-kind=h2
quarkus.datasource.jdbc.url=jdbc:h2:mem:test

# REST Client - Star Wars API
quarkus.rest-client."org.unipds.service.StarWarsService".url=https://swapi.dev/api

# JWT/RBAC
mp.jwt.verify.publickey.location=https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.pub
mp.jwt.verify.issuer=https://quarkus.io/using-jwt-rbac
quarkus.smallrye-jwt.claims.groups.path=groups
```

---

## 💡 Dicas de Troubleshooting

### **Erro: Connection refused**
- Solução: Verifique se a aplicação está rodando em `http://localhost:8080`

### **Erro: Token expirado**
- Solução: Baixe um novo token (o token de exemplo expira em 2029)

### **Erro: 403 mesmo com token válido**
- Solução: Verifique se a role do token está em `@RolesAllowed`

---

## 📚 Referências

- [Quarkus JWT Guide](https://quarkus.io/guides/security-jwt)
- [MicroProfile JWT](https://github.com/eclipse/microprofile-jwt-auth)
- [Star Wars API](https://swapi.dev/)

---

**Última Atualização:** 2026-03-04  
**Versão:** 1.0  
**Status:** ✅ Todos os problemas resolvidos

