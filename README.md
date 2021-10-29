# CATIMA

Master:
![ci](https://github.com/catima/catima/workflows/ci/badge.svg?branch=master)

Development:
![ci](https://github.com/catima/catima/workflows/ci/badge.svg?branch=development)

## Introduction

CATIMA is a Web app to create easily and quickly online catalogs of structured documents, by defining the data schema of the documents.

Each document is described by several data fields and represents a specific object. Many different types of objects can be created. The content of the document is used to make links between the different objects. CATIMA has also an integrated search option to search for different documents, as well as list views for each object type.

For some applications, CATIMA can be a replacement for databases such as FileMaker, but without offering many of the more advanced features. CATIMA is inteded to just work out of the box after defining the structure of the documents. CATIMA offers by purpose only relatively few personalization options. It still allows for creating custom content pages along with the catalog content.

## Documentation

CATIMA is a Rails 6.1 app.

This README describes the purpose of this repository and how to set up a development environment. Other sources of documentation are as follows:

* End-user documentation is in [catima/userdoc](https://github.com/catima/userdoc)
* Development documentation is in [catima/devdoc](https://github.com/catima/devdoc)

## Prerequisites

This project requires:

* Ruby 2.6.5, preferably managed using [rbenv][]
* PostgreSQL 12 must be installed and accepting connections
* [Redis][] must be installed and running on localhost with the default port
* Imagemagick must be installed (`brew install imagemagick`, `sudo apt install imagemagick`, ...)
* Sodium must be installed (`brew install libsodium`, ...)
* Chrome (for testing with Selenium)

## Getting started

### bin/setup

Run the `bin/setup` script. This script will:

* Check you have the required Ruby version
* Install gems using Bundler
* Create local copies of `.env`, `database.yml`  `domains.yml` and `geo_layers.yml`
* Create, migrate, and seed the database

### Run it!

1. Install NPM packages using `yarn install`
2. Install [foreman](https://github.com/ddollar/foreman) with `gem install foreman`
3. Run `foreman start -f Procfile.dev` to start the Rails app.

[rbenv]:https://github.com/sstephenson/rbenv
[redis]:http://redis.io

## Tests & API specs

* To run the full suite, run `rails test`
* To run a single test, specify the line with `rails test path/to/file:line_number`
* To view the integration tests running in the browser prepend `HEADLESS=0` to the commands above
* To run API requests specs and generate API doc `rails swag:run`. The API doc should be regenerated & committed everytime a change is made.
