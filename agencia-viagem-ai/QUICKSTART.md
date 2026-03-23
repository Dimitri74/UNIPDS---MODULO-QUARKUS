# Quickstart - Agencia Viagem AI

Este guia descreve os passos necessários para iniciar e parar a aplicação localmente no ambiente Windows (PowerShell).

## 📋 Pré-requisitos
- Docker Desktop instalado e em execução.
- [Ollama](https://ollama.com/) instalado e em execução.
- Java 17 ou superior instalado.

---

## 🚀 Como Iniciar a Aplicação

### 1. Iniciar a Infraestrutura (Banco de Dados Vetorial)
Abra o terminal na raiz do projeto e execute:
```powershell
docker compose up -d
```

### 2. Preparar os Modelos de IA (Ollama)
Certifique-se de que o Ollama está rodando e baixe os modelos necessários:
```powershell
ollama pull llama3.2
ollama pull nomic-embed-text
```

### 3. Iniciar a Aplicação Quarkus
Execute o comando abaixo com o perfil `pgvector` ativado. 
**Nota:** No PowerShell, é obrigatório o uso de aspas no argumento da propriedade.
```powershell
.\mvnw.cmd -Ppgvector quarkus:dev "-Dquarkus.profile=pgvector"
```

### 4. Testar a API
Em um novo terminal, você pode validar o funcionamento com o comando:
```powershell
curl.exe -X POST "http://localhost:8080/travel" `
     -H "Content-Type: text/plain; charset=utf-8" `
     --data-raw "Por favor, cancele minha reserva 67890. Meu último nome é Smith."
```

---

## 🛑 Como Parar a Aplicação

### 1. Parar o Quarkus
No terminal onde o Quarkus está rodando, pressione:
`Ctrl + C`

### 2. Parar a Infraestrutura Docker
Para parar e remover os containers do banco de dados, execute na raiz do projeto:
```powershell
docker compose down
```

### 3. (Opcional) Limpar Dados do Banco
Se desejar remover também os volumes (limpar os embeddings gravados), execute:
```powershell
docker compose down -v
```
