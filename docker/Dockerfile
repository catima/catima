FROM ruby:3.2.2-bullseye AS base

ENV DOCKER_RUNNING=true

ENV PSQL_CLIENT_VERSION=15
ENV NODE_VERSION=18
ENV RUBYGEMS_VERSION=3.4.5
ENV BUNDLER_VERSION=2.4.5

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
    lsb-release \
    ca-certificates \
    gnupg

# Install specific version of Postgresql Client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends yarn

# Install specific version of Node
RUN mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs

# Install specific version of RubyGems
RUN gem update --system $RUBYGEMS_VERSION

# Create and set the working directory as /var/www/catima
WORKDIR /var/www/catima

# Install specific version of bundler
RUN gem install bundler:$BUNDLER_VERSION --no-document --conservative

# Copy the Gemfile and Gemfile.lock, and run bundle install
COPY Gemfile /var/www/catima
COPY Gemfile.lock /var/www/catima
RUN bundle install

FROM base as app-dev

# Replace default crontab
ADD ./docker/config/crontab /etc/crontab

# Copy supervisor configuration file
#
# docker exec <container-id> supervisorctl status
# docker exec <container-id> supervisorctl tail -f <service>
# docker exec <container-id> supervisorctl restart <service>
COPY ./docker/config/supervisord-app-dev.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in development
COPY ./docker/config/entrypoint-app-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM base as worker-dev

# Copy supervisor configuration file
#
# docker exec <container-id> supervisorctl status
# docker exec <container-id> supervisorctl tail -f <service>
# docker exec <container-id> supervisorctl restart <service>
COPY ./docker/config/supervisord-worker-dev.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in development
COPY ./docker/config/entrypoint-worker-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
