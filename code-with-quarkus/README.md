# 🚀 Aplicação Quarkus - Backend com JWT/RBAC

Aplicação backend desenvolvida com Quarkus demonstrando integração com APIs externas, autenticação JWT e controle de acesso baseado em roles (RBAC).

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

---

## 🛠️ Tecnologias

- **Quarkus 3.17.5** - Framework supersônico
- **Java 21**
- **H2 Database** - Banco em memória
- **MicroProfile JWT** - Autenticação
- **SmallRye Fault Tolerance** - Resiliência
- **RESTEasy Reactive** - REST endpoints
- **Hibernate ORM Panache** - ORM simplificado

---

## 🎯 Endpoints Disponíveis

### **Públicos (sem autenticação)**
- `GET /q/health` - Health check da aplicação
- `GET /starwars/starships` - Lista naves Star Wars

### **Protegidos (requer JWT)**
- `GET /secure/claim` - Retorna username do token
- `GET /secure/info` - Retorna informações completas do JWT

### **Swagger UI**
- `http://localhost:8080/q/swagger-ui`

---

## 🚀 Como Executar

### **1. Iniciar a Aplicação em Modo Dev**
```powershell
.\mvnw.cmd quarkus:dev
```

A aplicação estará disponível em: `http://localhost:8080`

### **2. Executar Testes Automatizados**

Em outro terminal:
```powershell
.\Test-Simple.ps1
```

Este script executa 6 testes:
1. Health Check
2. Star Wars API
3. Endpoint seguro sem token (deve falhar)
4. Download do token JWT
5. Endpoint seguro com token
6. Informações do JWT

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
├── healthcheck/
│   ├── ApplicationReadinessCheck.java
│   └── StarWarsHealthCheck.java      # Health check personalizado
├── resource/
│   ├── PessoaResource.java           # CRUD REST
│   ├── SecureResource.java           # Endpoints protegidos JWT
│   └── StarWarsResource.java         # Proxy API Star Wars
└── service/
    └── StarWarsService.java          # REST Client

src/main/resources/
└── application.properties            # Configurações
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

---

## 🧪 Scripts de Teste

| Script | Descrição |
|--------|-----------|
| `Test-Simple.ps1` | ⭐ Recomendado - 6 testes completos |
| `Test-Complete.ps1` | Testes com output detalhado |
| `Test-JWT.ps1` | Focado em autenticação JWT |

---

## 📝 Documentação Adicional

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

---

## 🎓 Aprendizados

Este projeto demonstra:
- Como criar APIs REST com Quarkus
- Integração com APIs externas usando REST Client
- Implementação de segurança JWT/RBAC
- Health checks personalizados
- Fault tolerance e circuit breakers
- Persistência com Hibernate Panache

---

## 📚 Recursos

- [Quarkus Documentation](https://quarkus.io/guides/)
- [MicroProfile JWT](https://github.com/eclipse/microprofile-jwt-auth)
- [Star Wars API](https://swapi.dev/)

---

## 👥 Autor

**Módulo 01 - Quarkus**  
Desenvolvimento de Aplicações Back-End

---

## 📄 Licença

Este projeto é parte de material educacional.

---

**Versão:** 1.0.0  
**Última Atualização:** 2026-03-04  
**Status:** ✅ Pronto para uso

