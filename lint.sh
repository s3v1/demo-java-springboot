#!/bin/bash
set -euo pipefail

export MAVEN_OPTS='-XX:+TieredCompilation -XX:TieredStopAtLevel=1 -Xmx1024m'
./mvnw -T 1C compile spotbugs:check pmd:check #checkstyle:check
