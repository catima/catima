FROM ruby:2.7.5 AS base

ENV DOCKER_RUNNING=true

# Update repositories
RUN apt-get update

# Add needed packages
RUN apt-get install -y --no-install-recommends \
    curl \
    imagemagick \
    git \
    zip \
    supervisor \
    cron \
    lsb-release

# Install Postgresql-client 12
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-client-12

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends yarn

# Install Node 16
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends nodejs

# Create and set the working directory as /var/www/catima
WORKDIR /var/www/catima

# Update rubygems, install bundler 2.1.4
RUN gem update --system &&\
    gem install bundler:2.1.4 --no-document --conservative

# Copy the Gemfile and Gemfile.lock, and run bundle install
COPY Gemfile /var/www/catima
COPY Gemfile.lock /var/www/catima
RUN bundle install

FROM base as dev

# Copy supervisor configuration file
COPY ./docker/config/supervisord-worker-dev.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
