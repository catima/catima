FROM ruby:3.2.2-slim-bookworm AS base

ENV DOCKER_RUNNING=true

ENV PSQL_CLIENT_VERSION=15
ENV NODE_VERSION=20
ENV YARN_VERSION=1.22
ENV RUBYGEMS_VERSION=3.4.5
ENV BUNDLER_VERSION=2.4.5

# Update repositories & add needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev \
    libpq-dev \
    curl \
    imagemagick \
    git \
    zip \
    supervisor \
    cron \
    lsb-release \
    ca-certificates \
    gnupg \
    wget

# Install specific version of Postgresql Client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg &&\
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION

# Install specific version of Node
RUN mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs

# Install specific version of Yarn
RUN mkdir -p /etc/apt/keyrings && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn && \
    yarn policies set-version $YARN_VERSION

# Create and set the working directory
WORKDIR /var/www/catima

# Install specific version of RubyGems
RUN gem update --system $RUBYGEMS_VERSION

# Install specific version of Bundler
RUN gem install bundler:$BUNDLER_VERSION --no-document --conservative

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle install

FROM base AS app-dev

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

FROM base AS worker-dev

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
