# agencia-viagem-ai

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: <https://quarkus.io/>.

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:

```shell script
./mvnw quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at <http://localhost:8080/q/dev/>.

## Packaging and running the application

The application can be packaged using:

```shell script
./mvnw package
```

It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:

```shell script
./mvnw package -Dquarkus.package.jar.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using:

```shell script
./mvnw package -Dnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using:

```shell script
./mvnw package -Dnative -Dquarkus.native.container-build=true
```

You can then execute your native executable with: `./target/agencia-viagem-ai-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult <https://quarkus.io/guides/maven-tooling>.

## Related Guides

- REST ([guide](https://quarkus.io/guides/rest)): A Jakarta REST implementation utilizing build time processing and Vert.x. This extension is not compatible with the quarkus-resteasy extension, or any of the extensions that depend on it.
- LangChain4j Ollama ([guide](https://docs.quarkiverse.io/quarkus-langchain4j/dev/guide-ollama.html)): Provides the basic integration of Ollama with LangChain4j
- LangChain4j PGVector ([guide](https://docs.quarkiverse.io/quarkus-langchain4j/dev/index.html)): Provides a PostgreSQL/pgvector embedding store for RAG scenarios

## PGVector configuration

The project keeps the Ollama chat model enabled and now includes:

- a Maven profile `pgvector` that adds the pgvector/PostgreSQL extensions
- a Quarkus profile `pgvector` with the runtime datasource and embedding-store settings

### What was changed

- `quarkus-langchain4j-pgvector` added under the Maven profile `pgvector`
- Easy RAG references were commented out in `pom.xml` and `application.properties`
- PostgreSQL datasource and pgvector settings were added under the `%pgvector` profile

### Prerequisites

1. PostgreSQL running locally or remotely
2. `vector` extension enabled in the target database:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

### Default pgvector profile values

The profile expects these defaults:

- JDBC URL: `jdbc:postgresql://localhost:5432/agencia_viagem_ai`
- User: `postgres`
- Password: `postgres`
- Table: `travel_embeddings`
- Embedding dimension: `768`

> The dimension `768` matches `nomic-embed-text`. If you switch embedding model, update `quarkus.langchain4j.pgvector.dimension` accordingly.

### Running with pgvector


```powershell
$env:PGVECTOR_DB_URL="jdbc:postgresql://localhost:5432/agencia_viagem_ai"
$env:PGVECTOR_DB_USERNAME="postgres"
$env:PGVECTOR_DB_PASSWORD="postgres"
.\mvnw.cmd -Ppgvector quarkus:dev -Dquarkus.profile=pgvector
```

### One-command local run (Docker + Quarkus + /travel test)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-pgvector-travel-test.ps1
```

### Direct curl to test /travel

```powershell
curl.exe -X POST "http://localhost:8080/travel" -H "Content-Type: text/plain; charset=utf-8" --data-raw "Quais sao as formas de cancelamento dos pacote."
```

### Important note

Adding pgvector config prepares the embedding store, but it does not by itself recreate the automatic ingestion behavior previously provided by Easy RAG. If you want, the next step can be wiring a manual ingestion/retrieval flow to load `src/main/resources/rag/rag.txt` into PostgreSQL.

## Provided Code

### REST

Easily start your REST Web Services

[Related guide section...](https://quarkus.io/guides/getting-started-reactive#reactive-jax-rs-resources)
