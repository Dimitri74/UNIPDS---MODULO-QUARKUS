# Integração Kafka - Florinda Eats

## Visão Geral

Este projeto implementa uma arquitetura de microsserviços com comunicação assíncrona via Apache Kafka para os serviços:
- **Pedidos** (porta 8080) - Serviço principal de gerenciamento de pedidos
- **Pagamentos** (porta 8081) - Serviço de processamento de pagamentos
- **Notas Fiscais** (porta 8082) - Serviço de geração de notas fiscais

## Fluxo de Integração

```
┌─────────────────────────────────────────────────────────────────┐
│ Cliente faz requisição PUT /pagamentos/{id}                     │
│ para confirmar um pagamento                                      │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ PagamentoResource           │
        │ confirma(id) atualiza       │
        │ status → CONFIRMADO         │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │ PagamentoConfirmadoProducer│
        │ Publica evento no Kafka    │
        │ tópico: pagamentosConfirmados
        └────────────┬─────────────────┘
                     │
        ┌────────────┴──────────────┬──────────────────────┐
        │                           │                      │
        ▼                           ▼                      ▼
   ┌──────────────┐        ┌──────────────┐      ┌──────────────┐
   │   Pedidos    │        │ Pagamentos   │      │Notas Fiscais │
   │  Consumer    │        │  (ignored)   │      │  Consumer    │
   │ atualiza     │        │              │      │ registra     │
   │ Pedido:      │        │              │      │ para gerar   │
   │REALIZADO→PAGO│        │              │      │ nota fiscal  │
   └──────────────┘        └──────────────┘      └──────────────┘
```

## Componentes Criados/Modificados

### 1. Projeto PEDIDOS

#### Arquivos Criados:
- `PagamentoConfirmado.java` - DTO/Evento para representar pagamento confirmado
- `PagamentoConfirmadoConsumer.java` - Consumer que atualiza status do pedido quando recebe evento

#### Arquivos Modificados:
- `application.properties` - Adicionadas configurações de consumer Kafka
- `docker-compose.yml` - Adicionados serviços Zookeeper e Kafka

### 2. Projeto PAGAMENTOS

#### Arquivos Criados:
- `PagamentoConfirmado.java` - DTO/Evento
- `PagamentoConfirmadoProducer.java` - Producer que publica eventos

#### Arquivos Modificados:
- `PagamentoResource.java` - Adicionado @Inject de produtor e publicação de evento
- `application.properties` - Adicionadas configurações de producer Kafka
- `pom.xml` - Adicionada dependência quarkus-messaging-kafka
- `docker-compose.yml` - Adicionados serviços Zookeeper e Kafka

### 3. Projeto NOTAS-FISCAIS

#### Arquivos Criados:
- `event/PagamentoConfirmado.java` - DTO/Evento
- `consumer/PagamentoConfirmadoConsumer.java` - Consumer que registra eventos para auditoria
- `docker-compose.yml` - Novo arquivo com configuração Kafka

#### Arquivos Modificados:
- `application.properties` - Adicionadas configurações de consumer Kafka
- `pom.xml` - Adicionada dependência quarkus-messaging-kafka

## Configuração Kafka

### Bootstrap Servers
- **Desenvolvimento**: `localhost:9092`
- **Variável de Ambiente**: `KAFKA_BOOTSTRAP_SERVERS`

### Tópicos

#### pagamentosConfirmados
- **Partições**: 2
- **Producers**: `com.unipds.PagamentoConfirmadoProducer` (projeto pagamentos)
- **Consumers**:
  - `com.unipds.PagamentoConfirmadoConsumer` (projeto pedidos)
  - `com.unipds.consumer.PagamentoConfirmadoConsumer` (projeto notas-fiscais)
- **Formato**: JSON
  ```json
  {
    "pagamentoId": 1,
    "pedidoId": 1
  }
  ```

### Consumer Groups

| Grupo | Projeto | Tópicos |
|-------|---------|---------|
| `pedidos-service` | Pedidos | pagamentosConfirmados |
| `notas-fiscais-service` | Notas Fiscais | pagamentosConfirmados |

## Como Executar

### 1. Iniciar Infraestrutura

```bash
# Ir para o diretório do projeto pedidos
cd pedidos

# Iniciar MySQL + Kafka + Zookeeper
docker-compose up -d
```

### 2. Compilar Projetos

```bash
# Projeto Pedidos
cd pedidos
./mvnw clean package -DskipTests

# Projeto Pagamentos
cd ../pagamentos
./mvnw clean package -DskipTests

# Projeto Notas Fiscais
cd ../notas-fiscais
./mvnw clean package -DskipTests
```

### 3. Executar em Modo Dev (recomendado para desenvolvimento)

```bash
# Terminal 1 - Pedidos
cd pedidos
./mvnw quarkus:dev

# Terminal 2 - Pagamentos
cd pagamentos
./mvnw quarkus:dev

# Terminal 3 - Notas Fiscais
cd notas-fiscais
./mvnw quarkus:dev
```

### 4. Testar o Fluxo

#### Criar um Pedido
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

#### Confirmar Pagamento (dispara evento Kafka)
```bash
curl -X PUT http://localhost:8081/pagamentos/1
```

#### Verificar Status do Pedido
```bash
curl http://localhost:8080/pedidos/1
```

O status do pedido deve mudar de `REALIZADO` para `PAGO` automaticamente.

## Gerenciamento de Tópicos Kafka

### Criar Tópico Manualmente
```bash
docker exec -it <kafka_container> kafka-topics.sh \
  --bootstrap-server localhost:9094 \
  --create --partitions 2 \
  --topic pagamentosConfirmados \
  --if-not-exists
```

### Listar Tópicos
```bash
docker exec -it <kafka_container> kafka-topics.sh \
  --bootstrap-server localhost:9094 \
  --list
```

### Testar Producer
```bash
docker exec -it <kafka_container> kafka-console-producer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados
# Digite: {"pagamentoId": 1, "pedidoId": 1}
```

### Testar Consumer
```bash
docker exec -it <kafka_container> kafka-console-consumer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados \
  --from-beginning \
  --group teste
```

### Ver Consumer Groups
```bash
docker exec -it <kafka_container> kafka-consumer-groups.sh \
  --bootstrap-server localhost:9094 \
  --all-groups \
  --describe
```

## Configurações Importantes

### application.properties - Consumer

```properties
quarkus.kafka.bootstrap.servers=localhost:9092
mp.messaging.incoming.pagamentos-confirmados.connector=smallrye-kafka
mp.messaging.incoming.pagamentos-confirmados.topic=pagamentosConfirmados
mp.messaging.incoming.pagamentos-confirmados.value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
mp.messaging.incoming.pagamentos-confirmados.group.id=pedidos-service
```

### application.properties - Producer

```properties
quarkus.kafka.bootstrap.servers=localhost:9092
mp.messaging.outgoing.pagamentos-confirmados.connector=smallrye-kafka
mp.messaging.outgoing.pagamentos-confirmados.topic=pagamentosConfirmados
mp.messaging.outgoing.pagamentos-confirmados.value.serializer=org.apache.kafka.common.serialization.StringSerializer
```

## Tratamento de Erros

Ambos os consumers implementam:
- **Retry automático**: Quarkus Kafka com configuração padrão
- **Logging**: Via JBoss Logging (Logger)
- **Blocking**: Operações de banco de dados são blocadas para evitar problemas de concorrência

## Monitoramento

Para monitorar eventos em tempo real, use:

```bash
# Terminal dedicado para monitorar tópico
docker exec -it <kafka_container> kafka-console-consumer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados \
  --group monitor \
  --from-beginning
```

## Próximas Melhorias

1. **Dead Letter Queue (DLQ)**: Implementar fila de mensagens com falha
2. **Serialização Avro**: Usar Avro em vez de JSON para eficiência
3. **Idempotência**: Adicionar ID único a eventos para detectar duplicatas
4. **Schema Registry**: Usar Confluent Schema Registry
5. **Transações**: Implementar saga pattern para transações distribuídas
6. **Métricas**: Adicionar Micrometer para monitorar producers e consumers
7. **Tópicos Adicionais**: Criar tópicos para `notaFiscalGerada` e `pedidoConfirmado`

## Referências

- [Quarkus Kafka Guide](https://quarkus.io/guides/kafka)
- [SmallRye Reactive Messaging](https://smallrye.io/smallrye-reactive-messaging/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)

