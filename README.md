# CEML (Clinical Element Modeling Language) Service

This software is an API-only service exposing a REST interface for developers to:

1. Retrieve foundational Clinical Element Model (CEM) types, and 
1. Compile Clinical Element Model (CEM) definitions into other formats.

The API is written in ruby and the underlying complier in Java.

## Usage
A development-only, unauthenticated instance of the latest build is available at https://ceml-transform-service.logicahealth.org. Generated content at this public instance is automatically purged periodically without notice.

## Development

To run a pre-built copy using Docker:
```
  docker run -it --rm -p 4567:4567 --name ceml-transform-service p3000/ceml-transform-service:latest
```

(FIXME Waiting on licensing for this ->) Or to run locally from source code with a copy of the compiled jar:

```
  bundle update # requires a recent ruby runtime and `gem install bundler`
  thin --threaded start
```

## REST API
The API only accepts and responds in JSON using the "Content-Type: application/json" MIME TYPE. Requesting a non-existant file will yield a 404 (not found) response code. POST'ing with invalid JSON body contents will return a 406 (unacceptable).

### Static Assets
The compiler uses a baked-in library of core models and transform configurations. These are accessible by the following endpoints.

  * **GET /cem** The complete list of core models. `curl -s -X GET 'https://ceml-transform-service.logicahealth.org/cem'`
  * **GET /cem/HeartRateMeas.cem** Get a specific model. The model content will be base64 encoded. `curl -s -X GET 'https://ceml-transform-service.logicahealth.org/cem/HeartRateMeas.cem'`
  * **GET /def** The complete list of text definitions used by the model library. `curl -s -X GET 'https://ceml-transform-service.logicahealth.org/def'`
  * **GET /def/HeartRateMeas.def** Get a specific model. The file content will be base64 encoded. `'curl -s -X GET https://ceml-transform-service.logicahealth.org/def/HeartRateMeas.def'`
  * **GET /fhir** The complete list of FHIR mapping definitions used by the model library. `'curl -s -X GET https://ceml-transform-service.logicahealth.org/fhir'`
  * **GET /fhir/Base.resource.map** Get a specific model. The file content will be base64 encoded. `'curl -s -X GET https://ceml-transform-service.logicahealth.org/fhir/Base.resource.map'`

### Compiling Your Own CEM Files
New Clinical Element Models may be compiled by submitting them via POST. Individual outputs are retrievable by REST GET calls.

  * **GET /transforms/forms** Supported output formats, such as 'fsh' and others. `curl -s -X GET 'https://ceml-transform-service.logicahealth.org/transforms/formats'`
  * **POST /transforms** Compile your own model(s) to FHIR Shorthand (FSH) notation, synchronously. May take a few seconds or more. `curl -s -X POST 'https://ceml-transform-service.logicahealth.org/transforms/<format>'`. The body of the POST request MUST contain an array of file names and their base64-encoded contents, as follows:

```
[
  {"name" : "FoozleA.cem", "content" : "..base64-encoded file content.."},
  {"name" : "FoozleB.cem", "content" : "..base64-encoded file content.."},
  {..}
]
```

The service's JSON response is templated as follows:

```
{
  "uuid" : "40bd776a-ea5f-472d-8b9b-d9e889ae8f6e", # Random assigned UUID
  "gets" : # Array of URLs to GET individual outputs
    ["https://ceml-transform-service.logicahealth.org/transforms/40bd776a-ea5f-472d-8b9b-d9e889ae8f6e/FoozleA.fsh",
    "https://ceml-transform-service.logicahealth.org/transforms/40bd776a-ea5f-472d-8b9b-d9e889ae8f6e/FoozleB.fsh"],
  "delete" : # URL to DELETE the job
    "https://ceml-transform-service.logicahealth.org/transforms/40bd776a-ea5f-472d-8b9b-d9e889ae8f6e",
  "message" : "...raw compiler output for troubleshooting..."
}
```

The service instance will retain your generated output until either you DELETE the job or it is administratively purged for you.
### Administrative Functions

  * **POST /reset** "Factory reset" clearing _all_ generated compiler outputs. Applies globally. `curl -s -X POST https://ceml-transform-service.logicahealth.org/reset`

# License
Apache 2.0. All rights reserved.
# Attribution
Preston Lee https://github.com/preston