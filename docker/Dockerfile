FROM ruby:3.4-slim-trixie AS base

ENV DOCKER_RUNNING=true
ENV COREPACK_ENABLE_AUTO_PIN=0

ENV PSQL_CLIENT_VERSION=17
ENV NODE_VERSION=22
ENV YARN_VERSION=1.22

# Update repositories & add needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev \
    libpq-dev \
    libyaml-dev \
    procps \
    curl \
    imagemagick \
    git \
    unzip \
    supervisor \
    cron \
    lsb-release \
    ca-certificates \
    gnupg \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install specific version of Postgresql Client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install specific version of Node & Yarn
RUN mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable && \
    corepack prepare yarn@$YARN_VERSION --activate && \
    yarn --version

# Define user and group to run the application
RUN groupadd -g 1000 catima && \
    useradd -u 1000 -g catima -m -s /bin/bash catima

# Create and set the working directory
RUN mkdir -p /var/www/catima && \
    chown -R catima:catima /var/www/catima
WORKDIR /var/www/catima

FROM base AS dependencies-development

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle install

# Copy package.json and yarn.lock, then install js dependencies
COPY package.json yarn.lock /var/www/catima/
RUN yarn install --frozen-lockfile --production=false

FROM base AS dependencies-production

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle config set --local without 'development test' && \
    bundle install

# Copy package.json and yarn.lock, then install js dependencies
COPY package.json yarn.lock /var/www/catima/
RUN yarn install --frozen-lockfile --production=true

# =============================================================================
# DEVELOPMENT TARGETS
# =============================================================================
FROM dependencies-development AS app-dev

# Replace default crontab
COPY ./docker/config/crontab /etc/crontab

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

FROM dependencies-development AS worker-dev

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

# =============================================================================
# STAGING TARGETS
# =============================================================================
FROM dependencies-production AS app-staging

# Copy system files as root (crontab, supervisor config, entrypoint)
COPY ./docker/config/crontab /etc/crontab
COPY ./docker/config/supervisord-app-staging.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-app-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy unicorn configuration
COPY ./docker/config/unicorn.rb /var/www/catima/config/unicorn.rb

# Switch to catima user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
RUN cp config/database.example.yml.stage config/database.yml

# Precompile assets & generate locale files
RUN SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rails assets:precompile

# Download and extract Swagger documentation
RUN curl -L https://nightly.link/catima/catima/workflows/api/development/swagger-documentation.zip -o tmp/swagger.zip && \
    unzip tmp/swagger.zip -d swagger/v3/ && \
    rm tmp/swagger.zip

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM dependencies-production AS worker-staging

# Copy system files as root (supervisor config, entrypoint)
COPY ./docker/config/supervisord-worker-staging.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-worker-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to catima user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for sidekiq
RUN cp config/database.example.yml.stage config/database.yml

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# =============================================================================
# PRODUCTION TARGETS
# =============================================================================
FROM dependencies-production AS app-production

# Copy system files as root (crontab, supervisor config, entrypoint)
COPY ./docker/config/crontab /etc/crontab
COPY ./docker/config/supervisord-app-production.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-app-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy unicorn configuration
COPY ./docker/config/unicorn.rb /var/www/catima/config/unicorn.rb

# Switch to catima user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
RUN cp config/database.example.yml.prod config/database.yml

# Precompile assets & generate locale files
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Download and extract Swagger documentation
RUN curl -L https://nightly.link/catima/catima/workflows/api/master/swagger-documentation.zip -o tmp/swagger.zip && \
    unzip tmp/swagger.zip -d swagger/v3/ && \
    rm tmp/swagger.zip

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM dependencies-production AS worker-production

# Copy system files as root (supervisor config, entrypoint)
COPY ./docker/config/supervisord-worker-production.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-worker-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to catima user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for sidekiq
RUN cp config/database.example.yml.prod config/database.yml

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
