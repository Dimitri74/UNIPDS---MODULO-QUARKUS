# Guia de Testes - Florinda Eats com Kafka

## Pré-requisitos

- Todos os serviços rodando (Pedidos, Pagamentos, Notas Fiscais)
- Kafka e MySQL iniciados via docker-compose
- Postman ou curl instalado

## Cenário de Teste Completo

### 1. Criar um Pedido (Serviço PEDIDOS)

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
      "endereco": "Rua A, 123 - São Paulo, SP"
    },
    "itensPedido": [],
    "pagamentoId": 1
  }'
```

**Resposta esperada:**
```json
{
  "id": 1,
  "dataHora": "2025-03-17T10:30:00",
  "status": "REALIZADO",
  "cliente": {
    "nome": "João Silva",
    "cpf": "123.456.789-00",
    "celular": "(11) 99999-9999",
    "endereco": "Rua A, 123 - São Paulo, SP"
  },
  "itensPedido": [],
  "pagamentoId": 1
}
```

---

### 2. Criar um Pagamento (Serviço PAGAMENTOS)

```bash
# Nota: O pagamento deve ter o mesmo pedidoId
curl -X POST http://localhost:8081/pagamentos \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 150.00,
    "status": "CRIADO",
    "pedidoId": 1
  }'
```

**Resposta esperada:**
```json
{
  "id": 1,
  "valor": 150.00,
  "status": "CRIADO",
  "pedidoId": 1
}
```

---

### 3. Confirmar Pagamento (Dispara Kafka Event)

```bash
curl -X PUT http://localhost:8081/pagamentos/1
```

**O que acontece:**
1. Status do pagamento muda para `CONFIRMADO`
2. Um evento é publicado no Kafka tópico `pagamentosConfirmados`
3. Serviço PEDIDOS consome o evento e atualiza status do pedido para `PAGO`
4. Serviço NOTAS-FISCAIS consome o evento e registra para auditoria

**Resposta esperada:**
```json
{
  "id": 1,
  "valor": 150.00,
  "status": "CONFIRMADO",
  "pedidoId": 1
}
```

---

### 4. Verificar Status do Pedido (Deve estar PAGO)

```bash
curl http://localhost:8080/pedidos/1
```

**Resposta esperada (status deve ser PAGO):**
```json
{
  "id": 1,
  "dataHora": "2025-03-17T10:30:00",
  "status": "PAGO",
  "cliente": {
    "nome": "João Silva",
    "cpf": "123.456.789-00",
    "celular": "(11) 99999-9999",
    "endereco": "Rua A, 123 - São Paulo, SP"
  },
  "itensPedido": [],
  "pagamentoId": 1
}
```

---

### 5. Gerar Nota Fiscal (Serviço NOTAS-FISCAIS)

```bash
curl http://localhost:8082/nota-fiscal/pedido/1
```

**Resposta esperada (XML):**
```xml
<xml>
  <valor>9.99</valor>
  <cliente>
    <nome>João Silva</nome>
    <cpf>123.456.789-00</cpf>
    <celular>(11) 99999-9999</celular>
    <endereco>Rua A, 123 - São Paulo, SP</endereco>
  </cliente>
</xml>
```

---

## Testes com Postman

### Collection JSON

Salve como `florinda-eats-kafka-test.json`:

```json
{
  "info": {
    "name": "Florinda Eats - Kafka Integration",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Pedidos",
      "item": [
        {
          "name": "Criar Pedido",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"dataHora\": \"2025-03-17T10:30:00\",\n  \"status\": \"REALIZADO\",\n  \"cliente\": {\n    \"nome\": \"João Silva\",\n    \"cpf\": \"123.456.789-00\",\n    \"celular\": \"(11) 99999-9999\",\n    \"endereco\": \"Rua A, 123 - São Paulo, SP\"\n  },\n  \"itensPedido\": [],\n  \"pagamentoId\": 1\n}"
            },
            "url": {
              "raw": "http://localhost:8080/pedidos",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8080",
              "path": ["pedidos"]
            }
          }
        },
        {
          "name": "Listar Pedidos",
          "request": {
            "method": "GET",
            "url": {
              "raw": "http://localhost:8080/pedidos",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8080",
              "path": ["pedidos"]
            }
          }
        },
        {
          "name": "Obter Pedido",
          "request": {
            "method": "GET",
            "url": {
              "raw": "http://localhost:8080/pedidos/1",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8080",
              "path": ["pedidos", "1"]
            }
          }
        }
      ]
    },
    {
      "name": "Pagamentos",
      "item": [
        {
          "name": "Criar Pagamento",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"valor\": 150.00,\n  \"status\": \"CRIADO\",\n  \"pedidoId\": 1\n}"
            },
            "url": {
              "raw": "http://localhost:8081/pagamentos",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8081",
              "path": ["pagamentos"]
            }
          }
        },
        {
          "name": "Confirmar Pagamento (Kafka Event)",
          "request": {
            "method": "PUT",
            "url": {
              "raw": "http://localhost:8081/pagamentos/1",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8081",
              "path": ["pagamentos", "1"]
            }
          }
        },
        {
          "name": "Listar Pagamentos",
          "request": {
            "method": "GET",
            "url": {
              "raw": "http://localhost:8081/pagamentos",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8081",
              "path": ["pagamentos"]
            }
          }
        }
      ]
    },
    {
      "name": "Notas Fiscais",
      "item": [
        {
          "name": "Gerar Nota Fiscal",
          "request": {
            "method": "GET",
            "url": {
              "raw": "http://localhost:8082/nota-fiscal/pedido/1",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8082",
              "path": ["nota-fiscal", "pedido", "1"]
            }
          }
        }
      ]
    }
  ]
}
```

---

## Verificar Logs dos Serviços

### Verificar Consumer no Pedidos

Procure por logs como:
```
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Recebido evento de pagamento confirmado: {"pagamentoId":1,"pedidoId":1}
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Status do Pedido 1 atualizado para PAGO
```

### Verificar Consumer em Notas Fiscais

Procure por logs como:
```
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Recebido evento de pagamento confirmado em notas-fiscais: {"pagamentoId":1,"pedidoId":1}
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Nota fiscal será gerada para pedido: 1 (Pagamento: 1)
```

### Verificar Producer em Pagamentos

Procure por logs como:
```
2025-03-17 10:35:00 INFO [PagamentoConfirmadoProducer] Publicando evento de pagamento confirmado: {"pagamentoId":1,"pedidoId":1}
```

---

## Monitorar Kafka em Tempo Real

### Terminal para Monitorar Tópico

```bash
docker exec -it <kafka-container> kafka-console-consumer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados \
  --from-beginning
```

### Verificar Consumer Groups

```bash
docker exec -it <kafka-container> kafka-consumer-groups.sh \
  --bootstrap-server localhost:9094 \
  --all-groups \
  --describe
```

---

## Cenários de Teste Adicionais

### Teste 1: Múltiplos Pedidos e Pagamentos

```bash
# Criar 3 pedidos
curl -X POST http://localhost:8080/pedidos ... # pedidoId 1, 2, 3
curl -X POST http://localhost:8081/pagamentos ... # pagamentoId 1, 2, 3

# Confirmar apenas alguns pagamentos
curl -X PUT http://localhost:8081/pagamentos/1
curl -X PUT http://localhost:8081/pagamentos/3

# Verificar que apenas pedidos 1 e 3 tiveram status atualizado para PAGO
curl http://localhost:8080/pedidos
```

### Teste 2: Verificar Idempotência

```bash
# Confirmar o mesmo pagamento duas vezes
curl -X PUT http://localhost:8081/pagamentos/1
curl -X PUT http://localhost:8081/pagamentos/1

# Verificar que o sistema não duplica eventos ou não causa comportamento inesperado
curl http://localhost:8080/pedidos/1
```

### Teste 3: Falha no Pedido (Pedido não existe)

```bash
# Tentar confirmar pagamento para pedido inexistente
curl -X PUT http://localhost:8081/pagamentos/999

# Verificar logs para ver tratamento de erro
# Deve haver log de aviso: "Pedido 999 não encontrado"
```

---

## Métricas Esperadas

Após executar todos os testes:

- **Total de Pedidos Criados**: 1+
- **Total de Pagamentos Criados**: 1+
- **Total de Eventos Publicados**: Número de confirmações de pagamento
- **Pedidos com Status PAGO**: Igual a confirmações de pagamento com sucesso

---

## Troubleshooting

### Problema: Eventos não são consumidos

1. Verifique se Kafka está rodando:
   ```bash
   docker ps | grep kafka
   ```

2. Verifique se o tópico foi criado:
   ```bash
   docker exec -it <kafka-container> kafka-topics.sh \
     --bootstrap-server localhost:9094 --list
   ```

3. Verifique logs do consumer:
   ```bash
   # Nos logs do Quarkus em modo dev
   # Procure por "PagamentoConfirmadoConsumer"
   ```

### Problema: Pedido não atualiza para PAGO

1. Verifique se `pagamentoId` é o mesmo `id` do pagamento criado
2. Verifique se o pedido tem `status: REALIZADO` antes da confirmação
3. Verifique logs para mensagens de erro

### Problema: Conexão Recusada ao MySQL

1. Verifique se docker-compose está rodando:
   ```bash
   docker-compose ps
   ```

2. Aguarde mais tempo (MySQL pode levar 15-30 segundos para iniciar)

3. Verifique se porta 3306 não está em uso

