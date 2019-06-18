#!/bin/bash
set -euo pipefail

#export MAVEN_OPTS='-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xmx1024m'
#./mvnw -T2 verify

DOCKER_BUILDKIT=1 docker build --tag s3v1/demo-java-springboot:latest .

echo "INFO: To run: docker run --rm -it -P 8080:8080 s3v1/demo-java-springboot:latest"
echo "      Then check http://localhost:8080"
