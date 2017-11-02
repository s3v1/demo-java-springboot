FROM openjdk:8u131-jdk-alpine

# Always get the latest updates, in case there are some security fixes
# Add curl need for the healthcheck. 
# Add tini to properly run as PID 1 to better handle SIGINT. Tini is now available at /sbin/tini. See: https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md#handling-kernel-signals
RUN apk update \
  && apk upgrade \
  && apk add curl tini \
  && rm -rf /var/cache/apk/*

#Create user
RUN addgroup -S app && adduser -S -g app app 
# Create and chown the working folder
WORKDIR /app
RUN chown -R app:app /app  
#Switch to the node user for security. NEVER run a container as root.
USER app

# Resolve dependencies
COPY --chown=app:app gradle ./gradle
COPY --chown=app:app gradlew build.gradle ./
RUN ./gradlew dependencies

# Copy over the rest
COPY --chown=app:app . . 

# Resolve and Build
RUN ./gradlew build

EXPOSE 8080
# Using tini: https://github.com/krallin/tini#using-tini
CMD ["/sbin/tini", "-g", "java", "-jar", "build/libs/gs-spring-boot-0.1.0.jar"]
#CMD /sbin/tini -g java -jar build/libs/gs-spring-boot-0.1.0.jar
HEALTHCHECK --interval=10s --start-period=2s --timeout=1s --retries=3 CMD sh -c 'curl -s --connect-timeout 10 'http://localhost:8080' | grep -i -m 1 "Spring Boot" || exit 1'
