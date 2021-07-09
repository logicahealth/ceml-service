# CEML (Clinical Element Modeling Language) Service

This software is an API-only service exposing a REST interface for developers to:

1. Compile Clinical Element Model (CEM) definitions into application code. 
2. Retrieval of foundational Clinical Element Model (CEM) types,

The API is written in ruby and the underlying complier in Java.

## Usage
A development-only, unauthenticated instance of the latest build is available at https://cem-service.logicahealth.org

Generated content is periodically purged automatically and without notice.

## Development
To run locally from source:

  bundle update
  thin --threaded start

Alternatively, to run a pre-built copy:

  docker run -it --rm -p 4567:4567 --name ceml-service p3000/ceml-service:latest
## REST API
The API only accetps and responds in JSON using the "Content-Type: application/json" MIME TYPE. Requesting a non-existant file will yield a 404 response code.
  * **GET /cem** The complete list of core models. (`curl -s -X GET http://localhost:4567/cem`)
  * **GET /cem/HeartRateMeas.cem** Get a specific model. The model content will be base64 encoded. (`curl -s -X GET http://localhost:4567/cem/HeartRateMeas.cem`)
  * **GET /def** The complete list of text definitions used by the model library. (`curl -s -X GET http://localhost:4567/def`)
  * **GET /def/HeartRateMeas.def** Get a specific model. The file content will be base64 encoded. (`curl -s -X GET http://localhost:4567/def/HeartRateMeas.def`)
  * **GET /fhir** The complete list of FHIR mapping definitions used by the model library. (`curl -s -X GET http://localhost:4567/fhir`)
  * **GET /fhir/Base.resource.map** Get a specific model. The file content will be base64 encoded. (`curl -s -X GET http://localhost:4567/def/Base.resource.map`)
  * **POST /reset** "Factory reset" to remove all generated output from user requests. Applies globally.
  *  **POST /** Compile your own model(s) to FHIR Shorthand (FSH) notation, synchronously. May take a few seconds or more. `curl -s -X POST http://localhost:4567/` The body of the request MUST contain an array of base64-encoded files to compile as follows:

```
[
  {"name" : "FoozleA.cem", "..base64-encoded content.."},
  {..}
]
```

# License
Apache 2.0. All rights reserved.
# Attribution
Preston Lee https://github.com/preston