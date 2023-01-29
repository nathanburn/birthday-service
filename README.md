# Revolut birthday-service by Nathan Burn

## Table Of Contents

- [Plan](#plan)
- [Code](#code)
- [Build](#build)
- [Test](#test)
- [Release](#release)
- [Deploy](#deploy)
- [Operate](#operate)
- [Monitor](#monitor)

## Build

### Run with Docker Compose

Pre-requisties:

- Installed Docker (and Docker Compose is enabled)

Steps:

1. Run App and Postgres Database with Docker Compose:

    ```bash
    docker compose up --force-recreate --build -d
    ```

2. Navigate to `http://localhost:8080` in your browser.

3. Check running containers and logs with Docker Compose:

    ```bash
    docker compose ps
    docker compose logs
    ```

4. Tear down with Docker Compose:

    ```bash
    docker compose down
    ```

#### Get export from Postgres Database in container

Execute to capture mysqldump of the `dev` database:

```bash
docker exec -i db pg_dump -U birthday-service-user -h db -p 5432 birthday-service >> /Users/nathanbu/Documents/dumpFile.sql
```

### Build and Run Locally

Pre-requisties:

- Installed Java 17 JDK or higher
- Installed Maven

#### Run App with Maven Spring-Boot

1. Run with `maven` spring boot:

    ```bash
    mvn spring-boot:run
    ```

2. Navigate to `http://localhost:8080` in your browser.

#### Or run App with JAR file

1. Build with `maven` package:

    ```bash
    mvn clean package
    ```

2. Run with `jar` file:

    ```bash
    java -jar target/birthday-service-0.0.1-SNAPSHOT.jar
    ```

3. Navigate to `http://localhost:8080` in your browser.
