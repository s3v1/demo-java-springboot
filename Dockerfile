# Use an alpine based image as it's smaller to download and matches the run-time image
FROM openjdk:8u131-jdk-alpine as builder

# Create an 'app' user, so we don't run the install as root. 
# There could potentially be malicious code in the package manager repo
RUN addgroup -S app && adduser -S -g app app 
# Create the working folder and change owner
WORKDIR /app
RUN chown -R app:app /app  

# Copy over only the dependency file and the resolver tool. 
# Then we can resolve dependencies as a separate layer, so we can cache the layers and don't need to re-resolve if no dependencies have changed
COPY --chown=app:app .mvn ./.mvn
COPY --chown=app:app pom.xml mvnw ./
RUN ./mvnw dependency:go-offline

# Copy over the rest of the source
COPY --chown=app:app . . 

# Build & verify (linting etc.)
RUN ./mvnw -T 1C verify

# Use a Multistage build to use a smaller JRE-only image that is leaner and safer: https://docs.docker.com/engine/userguide/eng-image/multistage-build/
FROM openjdk:8u131-jre-alpine as runner
# Always get the latest updates, in case there are some security fixes
# Add curl needed for the healthcheck. 
# Add tini to properly run as PID 1 to better handle SIGINT. Tini is now available at /sbin/tini. See: https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md#handling-kernel-signals
RUN apk update \
  && apk upgrade \
  && apk add curl tini \
  && rm -rf /var/cache/apk/*

# Create the working folder and change owner the the low-privilege user "nobody"
WORKDIR /app
RUN chown -R nobody:nobody /app  

#Copy the runtime files from the builder image
COPY --from=builder --chown=nobody:nobody /app/target/gs-spring-boot-0.1.0.jar app.jar

#Switch to the nobody user for security. NEVER run a container as root.
USER nobody

EXPOSE 8080

# Using tini: https://github.com/krallin/tini#using-tini
CMD ["/sbin/tini", "-g", "java", "-jar", "app.jar"]
HEALTHCHECK --interval=10s --start-period=10s --timeout=1s --retries=3 CMD sh -c 'curl -s --connect-timeout 10 'http://localhost:8080' | grep -i -m 1 "Spring Boot" || exit 1'
