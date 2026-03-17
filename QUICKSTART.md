# 🚀 Quick Start - Florinda Eats com Kafka

Inicie o sistema em 5 minutos!

## ⚡ Pré-requisitos (30 segundos)

```bash
# Verificar Docker
docker --version  # v20.10+

# Verificar Java
java -version    # OpenJDK 21+

# Verificar Maven (opcional - mvnw incluso)
mvn -version     # 3.8+
```

## 📝 Passo 1: Clonar e Preparar (1 minuto)

```bash
cd UNIPDS---MODULO-QUARKUS
```

## 🐳 Passo 2: Iniciar Infraestrutura (2 minutos)

### Windows PowerShell
```powershell
cd pedidos
docker-compose up -d
Start-Sleep -Seconds 15
cd ..
```

### Linux/Mac/WSL
```bash
cd pedidos
docker-compose up -d
sleep 15
cd ..
```

## ▶️ Passo 3: Iniciar Serviços (2 minutos)

Abra **3 terminais** diferentes e execute:

### Terminal 1 - Pedidos
```bash
cd pedidos
./mvnw quarkus:dev
# Aguarde "Quarkus X.X.X started" (até 60s)
# Acesse: http://localhost:8080/q/swagger-ui/
```

### Terminal 2 - Pagamentos
```bash
cd pagamentos
./mvnw quarkus:dev
# Aguarde "Quarkus X.X.X started" (até 60s)
# Acesse: http://localhost:8081/q/swagger-ui/
```

### Terminal 3 - Notas Fiscais
```bash
cd notas-fiscais
./mvnw quarkus:dev
# Aguarde "Quarkus X.X.X started" (até 60s)
# Acesse: http://localhost:8082/q/swagger-ui/
```

## 🧪 Passo 4: Testar (2 minutos)

### 4.1. Criar Pedido
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

**Resposta esperada:** Pedido criado com ID 1 e status REALIZADO ✅

### 4.2. Criar Pagamento
```bash
curl -X POST http://localhost:8081/pagamentos \
  -H "Content-Type: application/json" \
  -d '{"valor": 150.00, "status": "CRIADO", "pedidoId": 1}'
```

**Resposta esperada:** Pagamento criado com ID 1 ✅

### 4.3. Confirmar Pagamento (Dispara Kafka!)
```bash
curl -X PUT http://localhost:8081/pagamentos/1
```

**Resposta esperada:** Pagamento com status CONFIRMADO ✅

### 4.4. Verificar Status do Pedido (Deve estar PAGO!)
```bash
curl http://localhost:8080/pedidos/1 | jq .status
```

**Resposta esperada:**
```json
"PAGO"
```

✅ **SUCESSO! A integração Kafka funcionou!**

---

## 📊 O Que Aconteceu nos Bastidores?

```
1. PUT /pagamentos/1 recebido
   ↓
2. PagamentoResource.confirma() executado
   ↓
3. Status do Pagamento atualizado para CONFIRMADO
   ↓
4. PagamentoConfirmadoProducer.publicarPagamentoConfirmado()
   ↓
5. Evento publicado no Kafka:
   {"pagamentoId": 1, "pedidoId": 1}
   ↓
6. PagamentoConfirmadoConsumer (Pedidos) recebe evento
   ↓
7. Pedido ID 1 atualizado: REALIZADO → PAGO
   ↓
8. PagamentoConfirmadoConsumer (Notas Fiscais) recebe evento
   ↓
9. Evento registrado para auditoria
```

---

## 🎯 Próximos Testes

### Testar Nota Fiscal
```bash
curl http://localhost:8082/nota-fiscal/pedido/1
```

### Listar Todos os Pedidos
```bash
curl http://localhost:8080/pedidos
```

### Ver Logs do Pedidos (no Terminal 1)
```
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Recebido evento...
2025-03-17 10:35:00 INFO [PagamentoConfirmadoConsumer] Status do Pedido...
```

---

## 🛑 Parar Tudo

### Parar Serviços Quarkus
Pressione `CTRL+C` em cada terminal

### Parar Infraestrutura Docker
```bash
cd pedidos
docker-compose down
```

---

## 📚 Documentação Completa

Depois de testar, leia:

1. **[SETUP.md](SETUP.md)** - Guia completo de instalação
2. **[KAFKA_INTEGRATION.md](KAFKA_INTEGRATION.md)** - Detalhes técnicos da integração
3. **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Mais exemplos de teste
4. **[PRODUCTION_CONFIG.md](PRODUCTION_CONFIG.md)** - Como fazer deploy em produção

---

## 🐛 Troubleshooting Rápido

### Porta Já em Uso
```bash
# Encontre o processo
netstat -ano | findstr :8080  # Windows
lsof -i :8080                 # Mac/Linux

# Mate o processo
taskkill /PID <PID> /F        # Windows
kill -9 <PID>                 # Mac/Linux
```

### MySQL Não Conecta
```bash
# Aguarde inicialização (30s) ou reinicie
docker-compose down -v
docker-compose up -d
sleep 30
```

### Kafka Não Consome Eventos
1. Verifique se os 3 serviços iniciaram sem erros
2. Verifique se Kafka está rodando: `docker ps | grep kafka`
3. Verifique logs no Terminal 1, 2, 3

### Evento Não Chega no Pedidos
1. Confirme que você executou PUT /pagamentos/1
2. Verifique logs do Terminal 1 (Pedidos)
3. Procure por "PagamentoConfirmadoConsumer"

---

## 💡 Dicas

### Ver Logs Mais Claros
Nos terminais dos serviços, procure por:
- ✅ "Quarkus X.X.X started" = serviço pronto
- ✅ "Recebido evento" = evento recebido do Kafka
- ✅ "Status do Pedido" = pedido atualizado
- ❌ "ERROR" = algo deu errado

### Usar Postman em vez de curl
1. Abra Postman
2. Crie requisições para:
   - POST http://localhost:8080/pedidos
   - POST http://localhost:8081/pagamentos
   - PUT http://localhost:8081/pagamentos/1
   - GET http://localhost:8080/pedidos/1

### Monitorar Kafka
```bash
# Em outro terminal
docker exec -it <kafka-id> kafka-console-consumer.sh \
  --bootstrap-server localhost:9094 \
  --topic pagamentosConfirmados \
  --from-beginning
```

---

## 📞 Não Funciona?

1. **Leia [TESTING_GUIDE.md](TESTING_GUIDE.md)** - Tem troubleshooting
2. **Verifique os logs** - Todos os erros estão nos logs dos serviços
3. **Docker rodando?** - `docker ps` deve listar mysql, zookeeper, kafka
4. **Portas livres?** - 8080, 8081, 8082, 3306, 9092, 2181

---

## ✨ Parabéns! 🎉

Você tem um sistema de microsserviços funcional com:
- ✅ 3 serviços Quarkus
- ✅ Banco de dados MySQL
- ✅ Message broker Kafka
- ✅ Consumidores reagindo a eventos
- ✅ Integração assíncrona completa

**Tempo Total**: ~5 minutos (incluindo downloads e compilação)

---

**Próximo passo**: Ler [SETUP.md](SETUP.md) para entender melhor a arquitetura!

