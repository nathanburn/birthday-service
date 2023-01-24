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
