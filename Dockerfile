# Use Eclipse Temurin Java 25 JDK
FROM eclipse-temurin:25-jdk

# Set working directory
WORKDIR /app

# Copy the JAR file into the container
COPY target/techfest-0.0.1-SNAPSHOT.jar app.jar

# Expose the Spring Boot port and Actuator port
EXPOSE 8081
EXPOSE 9090

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
