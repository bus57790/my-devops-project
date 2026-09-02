# Replace this deprecated line:
# FROM openjdk:17-jdk-slim

# Option 1: Eclipse Temurin (Recommended)
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
