# demo-java-springboot
A demo of spring boot

## badges
[![Maintainability](https://api.codeclimate.com/v1/badges/96357558930fe1353fd4/maintainability)](https://codeclimate.com/github/svilstrup/demo-java-springboot/maintainability)

[![Docker Build](https://img.shields.io/docker/build/svilstrup/demo-java-springboot.svg)](https://hub.docker.com/r/svilstrup/demo-java-springboot/)

# TODO
- Add spotbugs instead of findbugs: https://spotbugs.github.io/
- Add http://fb-contrib.sourceforge.net/ for spotbugs

# Docker based development
## Get a shell prompt
You can a start a docker container with the java build tools, if you don't have or want to install them locally

    docker run -it --rm -v $PWD:/app -w='/app' openjdk:8u131-jdk-alpine sh

For a disposable sh with the JDK ready to use.
After you get the shell prompt, you do:

    ./mvnw verify

...to build the project. All without java or maven installed locally.

## All-in-one build
As an alternative, you can run the build and terminate the container in one go like this:

    docker run -it --rm -v $PWD:/app -w='/app' openjdk:8u131-jdk-alpine ./mvnw clean verify
