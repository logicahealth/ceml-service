FROM maven:3-openjdk-17-slim AS BUILD
LABEL maintainer=preston.lee@prestonlee.com
RUN mkdir /build
WORKDIR /build

# Cache dependencies for build process.
COPY ceml/pom.xml .
RUN mvn -B dependency:go-offline

# Build the actual jar.
COPY ceml/src .
RUN mvn -B clean install

FROM openjdk:16-slim-buster AS RUN

RUN mkdir /app
WORKDIR /app
COPY --from=BUILD /build/ceml/targte/compiler-3.0.4-jar-with-dependencies.jar .
RUN mvn package
COPY . .
