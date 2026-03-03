# code-with-quarkus

Este projeto usa Quarkus, o Framework Java Supersônico Subatômico.

Se você quiser aprender mais sobre Quarkus, visite o site oficial: <https://quarkus.io/>.

## Executando a aplicação em modo de desenvolvimento

Você pode executar sua aplicação em modo de desenvolvimento, que habilita live coding, usando uma das opções abaixo:

```shell script
# Opção 1 - Usando o Maven Wrapper (RECOMENDADO)
.\mvnw.cmd clean quarkus:dev

# Opção 2 - Sem clean (mais rápido após primeira execução)
.\mvnw.cmd quarkus:dev

# Opção 3 - Se tiver Maven instalado globalmente
mvn clean quarkus:dev
```

> **_NOTA:_**  O Quarkus agora vem com uma UI de Desenvolvimento, que está disponível apenas em modo dev em <http://localhost:8080/q/dev/>.

## Empacotando e executando a aplicação

A aplicação pode ser empacotada usando:

```shell script
.\mvnw.cmd package
```

Isso produz o arquivo `quarkus-run.jar` no diretório `target/quarkus-app/`.
Esteja ciente de que não é um _über-jar_, pois as dependências são copiadas para o diretório `target/quarkus-app/lib/`.

A aplicação agora pode ser executada usando `java -jar target/quarkus-app/quarkus-run.jar`.

Se você quiser construir um _über-jar_, execute o seguinte comando:

```shell script
.\mvnw.cmd package -Dquarkus.package.jar.type=uber-jar
```

A aplicação, empacotada como um _über-jar_, agora pode ser executada usando `java -jar target/*-runner.jar`.

## Criando um executável nativo

Você pode criar um executável nativo usando:

```shell script
.\mvnw.cmd package -Dnative
```

Ou, se você não tiver o GraalVM instalado, pode executar a compilação do executável nativo em um container usando:

```shell script
.\mvnw.cmd package -Dnative -Dquarkus.native.container-build=true
```

Você pode então executar seu executável nativo com: `.\target\code-with-quarkus-1.0.0-SNAPSHOT-runner`

Se você quiser aprender mais sobre construção de executáveis nativos, consulte <https://quarkus.io/guides/maven-tooling>.

## Guias Relacionados

- REST ([guia](https://quarkus.io/guides/rest)): Uma implementação Jakarta REST utilizando processamento em tempo de build e Vert.x. Esta extensão não é compatível com a extensão quarkus-resteasy, ou qualquer uma das extensões que dependem dela.
- SmallRye OpenAPI ([guia](https://quarkus.io/guides/openapi-swaggerui)): Documente suas APIs REST com OpenAPI - vem com Swagger UI

## Código Fornecido

### REST

Inicie facilmente seus Web Services REST

[Seção do guia relacionada...](https://quarkus.io/guides/getting-started-reactive#reactive-jax-rs-resources)

