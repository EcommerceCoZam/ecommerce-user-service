# Multi-stage build
FROM maven:3.8.4-openjdk-11-slim AS build
WORKDIR /app

# Copiar settings.xml si existe
COPY settings.xml /root/.m2/settings.xml

# Cache de dependencias
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# Compilar aplicación
COPY src ./src
RUN mvn clean package -DskipTests

# Imagen final
FROM openjdk:11-jre-slim

# Instalar curl para el healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Variables de entorno
ENV SPRING_PROFILES_ACTIVE=dev
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseContainerSupport"
ENV SERVER_PORT=8700

# Usuario no-root
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser

# Directorio de aplicación
RUN mkdir -p /home/app && \
    chown -R appuser:appuser /home/app

WORKDIR /home/app
USER appuser

# Copiar JAR
COPY --from=build --chown=appuser:appuser /app/target/*.jar user-service.jar

# Exponer puertos
EXPOSE ${SERVER_PORT}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://0.0.0.0:${SERVER_PORT}/actuator/health || exit 1

# Punto de entrada
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE -Dserver.port=$SERVER_PORT -Dmanagement.server.port=$SERVER_PORT -jar user-service.jar"]