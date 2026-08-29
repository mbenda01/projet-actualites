FROM eclipse-temurin:25-jdk-alpine AS build

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

COPY src src
RUN ./mvnw package -Dmaven.test.skip=true -B

FROM eclipse-temurin:25-jre-alpine

WORKDIR /app

RUN addgroup -S actualites && adduser -S actualites -G actualites
USER actualites

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
