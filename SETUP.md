# Florinda Eats - Integração Kafka

Arquitetura de microsserviços com comunicação assíncrona via Apache Kafka para o sistema de pedidos, pagamentos e notas fiscais.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Serviços](#serviços)
- [Instalação](#instalação)
- [Execução](#execução)
- [Documentação](#documentação)

## 🎯 Visão Geral

Este projeto implementa uma arquitetura de microsserviços desacoplada onde:

1. **Serviço de Pedidos** gerencia o ciclo de vida dos pedidos
2. **Serviço de Pagamentos** processa pagamentos e publica eventos quando confirmados
3. **Serviço de Notas Fiscais** consome eventos de pagamento para auditoria e geração automática

A comunicação entre serviços é assíncrona via **Apache Kafka**, permitindo escalabilidade e resiliência.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                     Florinda Eats                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │   Pedidos    │  │  Pagamentos  │  │ Notas Fiscais   │   │
│  │  (8080)      │  │   (8081)     │  │    (8082)       │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘   │
│         │                  │                    │             │
│         └──────────────────┼────────────────────┘             │
│                            │                                  │
│                    ┌───────▼────────┐                        │
│                    │ Apache Kafka   │                        │
│                    │ (tópicos)      │                        │
│                    │ - pagamentos   │                        │
│                    │   Confirmados  │                        │
│                    └────────────────┘                        │
│                            │                                  │
│         ┌──────────────────┴──────────────────┐              │
│         │                                      │              │
│  ┌──────▼──────┐                    ┌────────▼────────┐     │
│  │   MySQL     │                    │   Zookeeper    │     │
│  │(Persistência)│                    │(Coordenação)   │     │
│  └─────────────┘                    └────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Serviços

### Pedidos
- **Porta**: 8080
- **Banco de Dados**: MySQL
- **Responsabilidades**:
  - Criar e gerenciar pedidos
  - Consumir eventos de pagamento confirmado
  - Atualizar status de pedidos automaticamente

**Endpoints principais**:
- `GET /pedidos` - Listar todos os pedidos
- `GET /pedidos/{id}` - Obter pedido específico
- `POST /pedidos` - Criar novo pedido

### Pagamentos
- **Porta**: 8081
- **Banco de Dados**: MySQL
- **Responsabilidades**:
  - Criar e gerenciar pagamentos
  - Confirmar pagamentos
  - Publicar eventos quando pagamento é confirmado

**Endpoints principais**:
- `GET /pagamentos` - Listar pagamentos
- `GET /pagamentos/{id}` - Obter pagamento específico
- `PUT /pagamentos/{id}` - **Confirmar pagamento (publica evento Kafka)**
- `POST /pagamentos` - Criar novo pagamento

### Notas Fiscais
- **Porta**: 8082
- **Banco de Dados**: Nenhum (apenas leitura via API)
- **Responsabilidades**:
  - Consumir eventos de pagamento
  - Registrar eventos para auditoria
  - Gerar notas fiscais sob demanda

**Endpoints principais**:
- `GET /nota-fiscal/pedido/{pedidoId}` - Gerar nota fiscal em XML

## 📦 Tecnologias

- **Framework**: Quarkus 3.32.3
- **Linguagem**: Java 21
- **Message Broker**: Apache Kafka
- **Banco de Dados**: MySQL 9.5
- **Build Tool**: Maven
- **Coordenação**: Zookeeper

## 💾 Instalação

### Pré-requisitos
- Docker e Docker Compose
- Java 21+
- Maven 3.8+
- Git

### Clone e Prepare

```bash
# Clonar repositório
git clone <repo-url>
cd UNIPDS---MODULO-QUARKUS

# Iniciar infraestrutura (MySQL + Kafka + Zookeeper)
cd pedidos
docker-compose up -d
cd ..
```

## ▶️ Execução

### Opção 1: Desenvolvimento (Recomendado)

Abra 3 terminais e execute em cada um:

**Terminal 1 - Pedidos**
```bash
cd pedidos
./mvnw quarkus:dev
```

**Terminal 2 - Pagamentos**
```bash
cd pagamentos
./mvnw quarkus:dev
```

**Terminal 3 - Notas Fiscais**
```bash
cd notas-fiscais
./mvnw quarkus:dev
```

### Opção 2: Script Automático (Windows PowerShell)

```powershell
.\start-all.ps1
```

### Opção 3: Script Automático (Linux/Mac)

```bash
chmod +x start-all.sh
./start-all.sh
```

### Opção 4: Compilar e Executar JARs

```bash
# Compilar todos os projetos
cd pedidos && ./mvnw clean package && cd ..
cd pagamentos && ./mvnw clean package && cd ..
cd notas-fiscais && ./mvnw clean package && cd ..

# Executar JARs
java -jar pedidos/target/quarkus-app/quarkus-run.jar
java -jar pagamentos/target/quarkus-app/quarkus-run.jar
java -jar notas-fiscais/target/quarkus-app/quarkus-run.jar
```

## 📚 Documentação

### Guias Detalhados

1. **[KAFKA_INTEGRATION.md](KAFKA_INTEGRATION.md)** - Guia completo de integração Kafka
   - Fluxo detalhado
   - Componentes criados
   - Configurações Kafka
   - Gerenciamento de tópicos
   - Monitoramento

2. **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Guia de testes com exemplos
   - Cenário de teste completo
   - Requisições curl e Postman
   - Collection JSON para importar
   - Troubleshooting
   - Testes adicionais

## 🧪 Teste Rápido

### 1. Criar Pedido
```bash
curl -X POST http://localhost:8080/pedidos \
  -H "Content-Type: application/json" \
  -d '{
    "dataHora": "2025-03-17T10:30:00",
    "status": "REALIZADO",
    "cliente": {
      "nome": "João Silva",
      "cpf": "123.456.789-00",
      "celular": "(11) 99999-9999",
      "endereco": "Rua A, 123"
    },
    "itensPedido": [],
    "pagamentoId": 1
  }'
```

### 2. Confirmar Pagamento (dispara Kafka)
```bash
curl -X PUT http://localhost:8081/pagamentos/1
```

### 3. Verificar Pedido (status deve ser PAGO)
```bash
curl http://localhost:8080/pedidos/1
```

## 🔍 Monitorar Kafka

```bash
# Listar tópicos
docker exec -it <kafka-container> kafka-topics.sh \
  --bootstrap-server localhost:9094 --list

# Consumir mensagens em tempo real
docker exec -it <kafka-container> kafka-console-consumer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados \
  --from-beginning

# Ver consumer groups
docker exec -it <kafka-container> kafka-consumer-groups.sh \
  --bootstrap-server localhost:9094 \
  --all-groups --describe
```

## 🌐 Swagger UI

Cada serviço expõe documentação interativa:

- Pedidos: http://localhost:8080/q/swagger-ui/
- Pagamentos: http://localhost:8081/q/swagger-ui/
- Notas Fiscais: http://localhost:8082/q/swagger-ui/

## 📊 Estrutura de Diretórios

```
UNIPDS---MODULO-QUARKUS/
├── pedidos/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/unipds/
│   │   │   │   ├── Pedido.java
│   │   │   │   ├── PedidoResource.java
│   │   │   │   ├── PagamentoConfirmado.java          (NOVO)
│   │   │   │   ├── PagamentoConfirmadoConsumer.java  (NOVO)
│   │   │   │   └── ...
│   │   │   └── resources/
│   │   │       └── application.properties (MODIFICADO)
│   │   └── test/
│   ├── pom.xml
│   ├── docker-compose.yml (MODIFICADO)
│   └── ...
├── pagamentos/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/unipds/
│   │   │   │   ├── Pagamento.java
│   │   │   │   ├── PagamentoResource.java (MODIFICADO)
│   │   │   │   ├── PagamentoConfirmado.java          (NOVO)
│   │   │   │   ├── PagamentoConfirmadoProducer.java  (NOVO)
│   │   │   │   └── ...
│   │   │   └── resources/
│   │   │       └── application.properties (MODIFICADO)
│   │   └── test/
│   ├── pom.xml (MODIFICADO)
│   ├── docker-compose.yml (MODIFICADO)
│   └── ...
├── notas-fiscais/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/unipds/
│   │   │   │   ├── event/
│   │   │   │   │   └── PagamentoConfirmado.java      (NOVO)
│   │   │   │   ├── consumer/
│   │   │   │   │   └── PagamentoConfirmadoConsumer.java (NOVO)
│   │   │   │   ├── resource/
│   │   │   │   ├── service/
│   │   │   │   └── ...
│   │   │   └── resources/
│   │   │       └── application.properties (MODIFICADO)
│   │   └── test/
│   ├── pom.xml (MODIFICADO)
│   ├── docker-compose.yml (NOVO)
│   └── ...
├── KAFKA_INTEGRATION.md (NOVO)
├── TESTING_GUIDE.md (NOVO)
├── README.md (este arquivo)
├── start-all.sh (NOVO)
└── start-all.ps1 (NOVO)
```

## 🐛 Troubleshooting

### Porta Já em Uso
```bash
# Encontrar processo usando porta
lsof -i :8080  # Linux/Mac
netstat -ano | findstr :8080  # Windows

# Matar processo
kill -9 <PID>  # Linux/Mac
taskkill /PID <PID> /F  # Windows
```

### Kafka Não Conecta
```bash
# Verificar se está rodando
docker ps | grep kafka

# Reiniciar
docker-compose down
docker-compose up -d
```

### MySQL Sem Conexão
```bash
# Aguardar inicialização (pode levar 30 segundos)
docker logs <mysql-container>

# Verificar saúde
docker ps
```

## 📝 Logs

### Ver Logs de um Serviço (modo dev)
Os logs aparecem no terminal onde o serviço está rodando.

### Ver Logs de um Container Docker
```bash
docker logs -f <container-name>
```

## 🔐 Variáveis de Ambiente

```bash
# Banco de Dados
DB_USER=quarkus
DB_PASSWORD=quarkus
DB_HOST=localhost
DB_PORT=3306

# Kafka
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
```

## 📌 Fluxo Esperado

1. Cliente cria pedido → Status: `REALIZADO`
2. Cliente cria pagamento → Status: `CRIADO`
3. Cliente confirma pagamento via PUT `/pagamentos/{id}`
4. Sistema publica evento `PagamentoConfirmado` no Kafka
5. Serviço PEDIDOS consome evento e atualiza pedido → Status: `PAGO`
6. Serviço NOTAS-FISCAIS consome evento e registra para auditoria
7. Cliente gera nota fiscal sob demanda

## 🤝 Contribuindo

Para adicionar novas funcionalidades:

1. Criar branch: `git checkout -b feature/nova-funcionalidade`
2. Fazer commits: `git commit -am 'Adicionar nova funcionalidade'`
3. Push: `git push origin feature/nova-funcionalidade`
4. Abrir Pull Request

## 📄 Licença

[Defina a licença conforme necessário]

## 👥 Autor

Desenvolvido como parte do curso UNIPDS - Módulo Quarkus

## 📞 Suporte

Para dúvidas ou problemas:
- Consulte [KAFKA_INTEGRATION.md](KAFKA_INTEGRATION.md) para arquitetura
- Consulte [TESTING_GUIDE.md](TESTING_GUIDE.md) para testes
- Verifique logs dos serviços

