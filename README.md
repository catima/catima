# CATIMA

Master:
[![ci](https://github.com/catima/catima/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/catima/catima/actions/workflows/ci.yml)

Development:
[![ci](https://github.com/catima/catima/actions/workflows/ci.yml/badge.svg?branch=development)](https://github.com/catima/catima/actions/workflows/ci.yml)

## Introduction

CATIMA is a Web app to create easily and quickly online catalogs of structured documents, by defining the data schema of the documents.

Each document is described by several data fields and represents a specific object. Many different types of objects can be created. The content of the document is used to make links between the different objects. CATIMA has also an integrated search option to search for different documents, as well as list views for each object type.

For some applications, CATIMA can be a replacement for databases such as FileMaker, but without offering many of the more advanced features. CATIMA is inteded to just work out of the box after defining the structure of the documents. CATIMA offers by purpose only relatively few personalization options. It still allows for creating custom content pages along with the catalog content.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/catima/catima)

## Documentation

CATIMA is a Rails 8 app.

This README describes the purpose of this repository and how to set up a development environment. Other sources of documentation are as follows:

* End-user documentation is in [catima/userdoc](https://github.com/catima/userdoc)
* Development documentation is in [catima/devdoc](https://github.com/catima/devdoc)

## Development with Docker

### Prerequisites

A working [Docker](https://docs.docker.com/engine/install/) installation is mandatory.

### Environment files

Please make sure to copy & rename the **example.env** file to **.env**.

``cp example.env .env``

You can replace the values if needed, but the default ones should work for local development.

Please also make sure to copy & rename the docker-compose.override.yml.dev file to docker-compose.override.yml.

``cp docker-compose.override.yml.dev docker-compose.override.yml``

You can replace the values if needed, but the default ones should work for local development.

### Edit hosts file

Edit hosts file to point **catima.lan** to your docker host.

### Environment installation & configuration

Run the following docker command from the project root directory.

Build & run all the containers for this project.

``docker-compose up`` (add -d if you want to run in the background and silence the logs)

Now you just have to wait for all containers to be created and ready to accept connections (Puma should be started and listening). The setup script will configure the application automatically.

Data for the redis, and postgres services are persisted using docker named volumes. You can see what volumes are currently present with:

``docker volume ls``

If you want to remove a volume (e.g. to start with a fresh database), you can use the following command.

``docker volume rm volume_name``

### Frontend

To access the main application, please use the following link.

[http://catima.lan:8383](http://catima.lan:8383)

+ admin@example.com / admin123

### MailHog

To access mails please use the following link.

[http://catima.lan:8028](http://catima.lan:8028)

Or to get the messages in JSON format.

[http://catima.lan:8028/api/v2/messages](http://catima.lan:8028/api/v2/messages)

## Tests & API specs

### Local
* To run the full suite, run `rails test`
* To run a single test, specify the line with `rails test path/to/file:line_number`
* To view the integration tests running in the browser prepend `HEADLESS=0` to the commands above
* To run API requests specs and generate API doc `rails swag:run`. The API doc is not versioned and should be added to the project during deployment

### Docker
* To run the full suite, run `docker exec -it -e NO_COVERAGE=1 catima-app bin/rails test`
* To run a single test, specify the line with `docker exec -it -e NO_COVERAGE=1 catima-app bin/rails test path/to/file:line_number`
* To run without coverage (improve performances), add `-e NO_COVERAGE=1` to `docker exec` args
* To view the integration tests running in the browser, add `-e HEADLESS=0` to `docker exec` args, then connect to the VNC server [vnc://catima.lan:5900](vnc://catima.lan:5900) with "secret" as password. Or go to [http://catima.lan:4444](http://catima.lan:4444), click on Sessions, you should see a line corresponding to the running tests and a camera icon next to it, click on it to open a VNC viewer
* To run API requests specs and generate API doc `docker exec -it catima-app rails swag:run`. The API doc is not versioned and should be added to the project during deployment
