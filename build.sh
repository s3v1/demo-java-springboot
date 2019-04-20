#!/bin/bash
set -euo pipefail
DOCKER_BUILDKIT=1 docker build --tag s3v1/demo-java-springboot:latest .
