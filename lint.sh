#!/bin/bash
set -euo pipefail

./mvnw spotbugs:check
#./mvnw checkstyle:check
./mvnw pmd:check
