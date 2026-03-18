#!/bin/bash

# Script de gerenciamento de Kafka para Florinda Eats
# Este script contém comandos para criar tópicos, testar producers e consumers

echo "=== Criando tópico pagamentosConfirmados ==="
docker exec -it florinda-eats-kafka-1 kafka-topics.sh --bootstrap-server localhost:9094 --create --partitions 2 --topic pagamentosConfirmados --if-not-exists

echo ""
echo "=== Descrevendo tópico pagamentosConfirmados ==="
docker exec -it florinda-eats-kafka-1 kafka-topics.sh --bootstrap-server localhost:9094 --describe --topic pagamentosConfirmados

echo ""
echo "=== Listando todos os tópicos ==="
docker exec -it florinda-eats-kafka-1 kafka-topics.sh --bootstrap-server localhost:9094 --list

echo ""
echo "=== Testando Producer (Publique mensagens para o tópico) ==="
echo "Comando: docker exec -it florinda-eats-kafka-1 kafka-console-producer.sh --bootstrap-server localhost:9094 --topic pagamentosConfirmados --property \"parse.key=true\" --property \"key.separator=;\""
echo "Exemplo de mensagem: 1;{\"pagamentoId\": 1, \"pedidoId\": 1}"
echo ""

# Descomente para testar interativamente:
# docker exec -it florinda-eats-kafka-1 kafka-console-producer.sh --bootstrap-server localhost:9094 --topic pagamentosConfirmados --property "parse.key=true" --property "key.separator=;"

echo ""
echo "=== Testando Consumer (Consumindo mensagens) ==="
echo "Comando: docker exec -it florinda-eats-kafka-1 kafka-console-consumer.sh --bootstrap-server localhost:9094 --topic pagamentosConfirmados --from-beginning --group teste"
echo ""

# Descomente para testar interativamente:
# docker exec -it florinda-eats-kafka-1 kafka-console-consumer.sh --bootstrap-server localhost:9094 --topic pagamentosConfirmados --from-beginning --group teste

echo ""
echo "=== Verificando Consumer Groups ==="
docker exec -it florinda-eats-kafka-1 kafka-consumer-groups.sh --bootstrap-server localhost:9094 --all-groups --describe
