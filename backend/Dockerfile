# Use Eclipse Temurin Java 25 JDK
FROM eclipse-temurin:25-jdk

# Set working directory
WORKDIR /app

# Copy the JAR built by Maven (mvn package) into the container.
# Build the jar first with: mvn clean package -DskipTests
COPY target/techfest-0.0.1-SNAPSHOT.jar app.jar

# App port + Actuator (health/metrics) port
EXPOSE 8081
EXPOSE 9090

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
