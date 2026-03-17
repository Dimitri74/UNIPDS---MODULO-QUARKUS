# Guia de Configuração para Produção

Este documento fornece recomendações para deployar o Florinda Eats em ambiente de produção.

## 🏗️ Arquitetura em Produção

```
┌─────────────────────────────────────────────────────────────────┐
│                      Produção                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐        │
│  │  Pedidos-1   │  │  Pagamentos-1│  │Notas Fiscais-1  │        │
│  │  Pedidos-2   │  │  Pagamentos-2│  │Notas Fiscais-2  │        │
│  │  Pedidos-3   │  │  Pagamentos-3│  │Notas Fiscais-3  │        │
│  └──────┬───────┘  └──────┬───────┘  └────────┬────────┘        │
│         │                  │                    │                 │
│         └──────────────────┼────────────────────┘                 │
│                            │                                      │
│          ┌─────────────────▼──────────────────┐                  │
│          │  Apache Kafka Cluster              │                  │
│          │  - 3+ brokers                      │                  │
│          │  - Replication factor: 3           │                  │
│          │  - Min insync replicas: 2          │                  │
│          │  - Tópicos:                        │                  │
│          │    pagamentosConfirmados (rf=3)   │                  │
│          │    notaFiscalGerada (rf=3)        │                  │
│          │    pedidoConfirmado (rf=3)        │                  │
│          └──────────────┬───────────────────┘                   │
│                        │                                         │
│          ┌─────────────┴─────────────┐                          │
│          │                           │                          │
│    ┌─────▼──────┐          ┌────────▼────────┐                │
│    │  MySQL     │          │  Zookeeper      │                │
│    │  Cluster   │          │  Ensemble       │                │
│    │  (3+ nós)  │          │  (3+ nós)       │                │
│    └────────────┘          └─────────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🔐 Variáveis de Ambiente para Produção

### Banco de Dados
```bash
# MySQL
DB_USER=produser
DB_PASSWORD=<strong-password>
DB_HOST=mysql-cluster.internal
DB_PORT=3306

# Replicação MySQL
MYSQL_REPLICATION_USER=repl
MYSQL_REPLICATION_PASSWORD=<strong-password>
```

### Kafka
```bash
# Bootstrap Servers
KAFKA_BOOTSTRAP_SERVERS=kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092

# Segurança
KAFKA_SECURITY_PROTOCOL=SASL_SSL
KAFKA_SASL_MECHANISM=PLAIN
KAFKA_SASL_USERNAME=florinda-prod
KAFKA_SASL_PASSWORD=<strong-password>
KAFKA_TRUSTSTORE_LOCATION=/etc/ssl/certs/kafka-truststore.jks
KAFKA_TRUSTSTORE_PASSWORD=<strong-password>

# Configurações de Replication
KAFKA_REPLICATION_FACTOR=3
KAFKA_MIN_INSYNC_REPLICAS=2
```

### Aplicação
```bash
# Pedidos
PEDIDOS_HTTP_PORT=8080
PEDIDOS_KAFKA_GROUP=pedidos-service-prod

# Pagamentos
PAGAMENTOS_HTTP_PORT=8081
PAGAMENTOS_KAFKA_GROUP=pagamentos-service-prod

# Notas Fiscais
NOTASFISCAIS_HTTP_PORT=8082
NOTASFISCAIS_KAFKA_GROUP=notas-fiscais-service-prod

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json
```

## 📋 application.properties - Produção

### Pedidos (src/main/resources/application-prod.properties)

```properties
# DataSource
quarkus.datasource.db-kind=mysql
quarkus.datasource.username=${DB_USER}
quarkus.datasource.password=${DB_PASSWORD}
quarkus.datasource.jdbc.url=jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/chaves_food
quarkus.datasource.reactive.url=mysql://${DB_HOST:localhost}:${DB_PORT:3306}/chaves_food
quarkus.datasource.devservices.enabled=false

# Connection Pool
quarkus.datasource.jdbc.max-size=20
quarkus.datasource.jdbc.min-size=5

# Hibernate
quarkus.hibernate-orm.database.generation=validate
quarkus.hibernate-orm.log.sql=false

# HTTP
quarkus.http.port=${PEDIDOS_HTTP_PORT:8080}
quarkus.http.read-timeout=30s
quarkus.http.limits.max-body-size=10M

# Kafka
quarkus.kafka.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS}
quarkus.kafka.sasl.mechanism=${KAFKA_SASL_MECHANISM}
quarkus.kafka.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_SASL_USERNAME}" password="${KAFKA_SASL_PASSWORD}";
quarkus.kafka.security.protocol=${KAFKA_SECURITY_PROTOCOL}
quarkus.kafka.ssl.truststore.location=${KAFKA_TRUSTSTORE_LOCATION}
quarkus.kafka.ssl.truststore.password=${KAFKA_TRUSTSTORE_PASSWORD}

# Consumer
mp.messaging.incoming.pagamentos-confirmados.connector=smallrye-kafka
mp.messaging.incoming.pagamentos-confirmados.topic=pagamentosConfirmados
mp.messaging.incoming.pagamentos-confirmados.value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
mp.messaging.incoming.pagamentos-confirmados.group.id=${PEDIDOS_KAFKA_GROUP:pedidos-service}
mp.messaging.incoming.pagamentos-confirmados.auto.offset.reset=earliest
mp.messaging.incoming.pagamentos-confirmados.enable.auto.commit=true
mp.messaging.incoming.pagamentos-confirmados.max.poll.records=100
mp.messaging.incoming.pagamentos-confirmados.session.timeout.ms=30000

# Logging
quarkus.log.level=INFO
quarkus.log.category."com.unipds".level=INFO
quarkus.log.console.format=%d{yyyy-MM-dd HH:mm:ss} [%t] %-5p %c - %m%n
quarkus.log.file.enable=true
quarkus.log.file.path=/var/log/florinda/pedidos.log
quarkus.log.file.rotation.max-file-size=10M
quarkus.log.file.rotation.max-backup-index=10

# Metrics
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true
```

### Pagamentos (src/main/resources/application-prod.properties)

```properties
# DataSource
quarkus.datasource.db-kind=mysql
quarkus.datasource.username=${DB_USER}
quarkus.datasource.password=${DB_PASSWORD}
quarkus.datasource.jdbc.url=jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/chaves_food
quarkus.datasource.reactive.url=mysql://${DB_HOST:localhost}:${DB_PORT:3306}/chaves_food
quarkus.datasource.devservices.enabled=false

# Connection Pool
quarkus.datasource.jdbc.max-size=20
quarkus.datasource.jdbc.min-size=5

# Hibernate
quarkus.hibernate-orm.database.generation=validate
quarkus.hibernate-orm.log.sql=false

# HTTP
quarkus.http.port=${PAGAMENTOS_HTTP_PORT:8081}
quarkus.http.read-timeout=30s
quarkus.http.limits.max-body-size=10M

# Kafka
quarkus.kafka.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS}
quarkus.kafka.sasl.mechanism=${KAFKA_SASL_MECHANISM}
quarkus.kafka.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_SASL_USERNAME}" password="${KAFKA_SASL_PASSWORD}";
quarkus.kafka.security.protocol=${KAFKA_SECURITY_PROTOCOL}
quarkus.kafka.ssl.truststore.location=${KAFKA_TRUSTSTORE_LOCATION}
quarkus.kafka.ssl.truststore.password=${KAFKA_TRUSTSTORE_PASSWORD}

# Producer
mp.messaging.outgoing.pagamentos-confirmados.connector=smallrye-kafka
mp.messaging.outgoing.pagamentos-confirmados.topic=pagamentosConfirmados
mp.messaging.outgoing.pagamentos-confirmados.value.serializer=org.apache.kafka.common.serialization.StringSerializer
mp.messaging.outgoing.pagamentos-confirmados.acks=all
mp.messaging.outgoing.pagamentos-confirmados.compression.type=snappy
mp.messaging.outgoing.pagamentos-confirmados.batch.size=32768
mp.messaging.outgoing.pagamentos-confirmados.linger.ms=10

# Logging
quarkus.log.level=INFO
quarkus.log.category."com.unipds".level=INFO
quarkus.log.console.format=%d{yyyy-MM-dd HH:mm:ss} [%t] %-5p %c - %m%n
quarkus.log.file.enable=true
quarkus.log.file.path=/var/log/florinda/pagamentos.log
quarkus.log.file.rotation.max-file-size=10M
quarkus.log.file.rotation.max-backup-index=10

# Metrics
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true
```

### Notas Fiscais (src/main/resources/application-prod.properties)

```properties
# HTTP
quarkus.http.port=${NOTASFISCAIS_HTTP_PORT:8082}
quarkus.http.read-timeout=30s
quarkus.http.limits.max-body-size=10M

# REST Client
quarkus.rest-client."com.unipds.service.PedidoService".url=${PEDIDOS_SERVICE_URL:http://pedidos:8080}
quarkus.rest-client."com.unipds.service.PedidoService".connect-timeout=5000
quarkus.rest-client."com.unipds.service.PedidoService".read-timeout=10000

# Kafka
quarkus.kafka.bootstrap.servers=${KAFKA_BOOTSTRAP_SERVERS}
quarkus.kafka.sasl.mechanism=${KAFKA_SASL_MECHANISM}
quarkus.kafka.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${KAFKA_SASL_USERNAME}" password="${KAFKA_SASL_PASSWORD}";
quarkus.kafka.security.protocol=${KAFKA_SECURITY_PROTOCOL}
quarkus.kafka.ssl.truststore.location=${KAFKA_TRUSTSTORE_LOCATION}
quarkus.kafka.ssl.truststore.password=${KAFKA_TRUSTSTORE_PASSWORD}

# Consumer
mp.messaging.incoming.pagamentos-confirmados.connector=smallrye-kafka
mp.messaging.incoming.pagamentos-confirmados.topic=pagamentosConfirmados
mp.messaging.incoming.pagamentos-confirmados.value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
mp.messaging.incoming.pagamentos-confirmados.group.id=${NOTASFISCAIS_KAFKA_GROUP:notas-fiscais-service}
mp.messaging.incoming.pagamentos-confirmados.auto.offset.reset=earliest
mp.messaging.incoming.pagamentos-confirmados.enable.auto.commit=true

# Logging
quarkus.log.level=INFO
quarkus.log.category."com.unipds".level=INFO
quarkus.log.console.format=%d{yyyy-MM-dd HH:mm:ss} [%t] %-5p %c - %m%n
quarkus.log.file.enable=true
quarkus.log.file.path=/var/log/florinda/notas-fiscais.log
quarkus.log.file.rotation.max-file-size=10M
quarkus.log.file.rotation.max-backup-index=10

# Metrics
quarkus.micrometer.enabled=true
quarkus.micrometer.export.prometheus.enabled=true
```

## 🐳 Docker Compose para Produção

```yaml
version: '3.8'

services:
  mysql-1:
    image: mysql:9.5
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: chaves_food
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data_1:/var/lib/mysql
      - ./mysql-replication.cnf:/etc/mysql/conf.d/replication.cnf
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 10

  zookeeper-1:
    image: confluentinc/cp-zookeeper:7.5.0
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
      ZOOKEEPER_SERVER_ID: 1
    ports:
      - "2181:2181"

  kafka-1:
    image: confluentinc/cp-kafka:7.5.0
    depends_on:
      - zookeeper-1
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper-1:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-1:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
      KAFKA_MIN_INSYNC_REPLICAS: 2
      KAFKA_NUM_PARTITIONS: 3
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'false'

  pedidos:
    image: florinda/pedidos:latest
    depends_on:
      mysql-1:
        condition: service_healthy
    environment:
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_HOST: mysql-1
      KAFKA_BOOTSTRAP_SERVERS: kafka-1:29092
    ports:
      - "8080:8080"
    deploy:
      replicas: 3

  pagamentos:
    image: florinda/pagamentos:latest
    depends_on:
      mysql-1:
        condition: service_healthy
    environment:
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
      DB_HOST: mysql-1
      KAFKA_BOOTSTRAP_SERVERS: kafka-1:29092
    ports:
      - "8081:8081"
    deploy:
      replicas: 3

  notas-fiscais:
    image: florinda/notas-fiscais:latest
    depends_on:
      kafka-1:
        condition: service_healthy
    environment:
      KAFKA_BOOTSTRAP_SERVERS: kafka-1:29092
      PEDIDOS_SERVICE_URL: http://pedidos:8080
    ports:
      - "8082:8082"
    deploy:
      replicas: 3

volumes:
  mysql_data_1:
```

## ☸️ Kubernetes Deployment

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: florinda-config
data:
  application.properties: |
    quarkus.datasource.db-kind=mysql
    quarkus.kafka.bootstrap.servers=kafka-cluster:9092

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pedidos
spec:
  replicas: 3
  selector:
    matchLabels:
      app: pedidos
  template:
    metadata:
      labels:
        app: pedidos
    spec:
      containers:
      - name: pedidos
        image: florinda/pedidos:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: mysql-service
        - name: KAFKA_BOOTSTRAP_SERVERS
          value: kafka-cluster:9092
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /q/health/live
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /q/health/ready
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: pedidos
spec:
  selector:
    app: pedidos
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
  type: LoadBalancer
```

## 🔒 Segurança

### Checklist de Produção

- [ ] Senhas de banco de dados geradas aleatoriamente
- [ ] SASL/SSL habilitado no Kafka
- [ ] Certificados SSL válidos
- [ ] Network policies do Kubernetes configuradas
- [ ] Logs centralizados (ELK, Splunk)
- [ ] Monitoramento com Prometheus/Grafana
- [ ] Alertas configurados para degradação de performance
- [ ] Backup automático do MySQL
- [ ] Rate limiting nas APIs
- [ ] WAF (Web Application Firewall) na frente dos serviços

## 📊 Monitoramento

### Métricas Importantes

```properties
# Adicionar ao pom.xml
quarkus-micrometer
quarkus-micrometer-registry-prometheus

# Endpoints
GET /q/metrics - Métricas em formato Prometheus
GET /q/health/live - Health check liveness
GET /q/health/ready - Health check readiness
```

### Dashboard Grafana

Importar dashboards:
- Quarkus Application Metrics (ID: 11699)
- Kafka Cluster (ID: 7589)
- MySQL (ID: 7991)

## 🚀 Deploy Checklist

- [ ] Configurar secrets no Kubernetes ou Docker Swarm
- [ ] Testar failover do MySQL
- [ ] Testar failover do Kafka
- [ ] Configurar PersistentVolumes para dados
- [ ] Configurar backups automáticos
- [ ] Testar disaster recovery
- [ ] Configurar CI/CD pipeline
- [ ] Testes de carga (locust/JMeter)
- [ ] Documentação operacional
- [ ] Runbooks para incidents

## 📞 Suporte

Para dúvidas sobre produção, consulte:
- Documentação Quarkus: https://quarkus.io/guides/deploying-to-kubernetes
- Documentação Kafka: https://kafka.apache.org/documentation/
- Documentação MySQL: https://dev.mysql.com/doc/

