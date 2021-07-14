# The way this is done is very WRONG.
# It is due to the unavailability of the CEML compiler source.
FROM ruby:3-buster AS RUN
LABEL maintainer=preston.lee@prestonlee.com

RUN mkdir /app
WORKDIR /app

# Install JRE
RUN apt search openjdk
RUN apt-get update && apt-get install -y openjdk-11-jre

# Install dependencies
COPY Gemfile* .
RUN bundle install

# WRONG Copy in the compiler. :(
COPY config.ru .
COPY ceml-3.0.4-jar-with-dependencies.jar .
COPY def def
COPY cem cem
COPY fhir fhir
COPY app.rb .

EXPOSE 4567
CMD APP_ENV=production thin --threaded start


# # TODO Once the code is available as open source,
# # it can be built by CI automatically as follows 
# FROM maven:3-openjdk-17-slim AS BUILD
# LABEL maintainer=preston.lee@prestonlee.com
# RUN mkdir /build
# WORKDIR /build

# # Cache dependencies for build process.
# COPY ceml/pom.xml .
# RUN mvn -B dependency:go-offline

# # Build the actual jar.
# COPY ceml/src .
# RUN mvn -B clean install

# FROM openjdk:16-slim-buster AS RUN

# RUN mkdir /app
# WORKDIR /app
# COPY --from=BUILD /build/ceml/targte/compiler-3.0.4-jar-with-dependencies.jar .
# RUN mvn package
# COPY . .
