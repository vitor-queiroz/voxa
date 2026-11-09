# Imagem do backend para o Render (ou qualquer host com Docker)

# Etapa 1: compila o projeto com Maven (imagem oficial já traz Maven + JDK 21)
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copia primeiro só o pom.xml para baixar as dependências.
# Assim o Docker reaproveita essa camada enquanto o pom.xml não mudar.
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src src
RUN mvn -B -q -DskipTests package

# Etapa 2: imagem final, só com o Java e o .jar
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# O plano free do Render tem 512 MB: limita a memória da JVM para não estourar
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+UseSerialGC -XX:TieredStopAtLevel=1"

# O Render informa a porta pela variável PORT (o application.properties lê ela)
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
