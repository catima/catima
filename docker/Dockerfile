FROM ruby:3.4-slim-trixie AS base

ENV DOCKER_RUNNING=true
ENV COREPACK_ENABLE_AUTO_PIN=0

ENV PSQL_CLIENT_VERSION=17
ENV NODE_VERSION=22
ENV YARN_VERSION=1.22
ENV RUBYGEMS_VERSION=3.4.5
ENV BUNDLER_VERSION=2.4.5

# Update repositories & add needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev \
    libpq-dev \
    libyaml-dev \
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
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION

# Install specific version of Node & Yarn
RUN mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs && \
    corepack enable && \
    corepack prepare yarn@$YARN_VERSION --activate && \
    yarn --version

# Create and set the working directory
WORKDIR /var/www/catima

# Install specific version of RubyGems
RUN gem update --system $RUBYGEMS_VERSION

# Install specific version of Bundler
RUN gem install bundler:$BUNDLER_VERSION --no-document --conservative

FROM base AS dependencies

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle install

# Copy package.json and yarn.lock for npm dependencies
COPY package.json yarn.lock /var/www/catima/
RUN yarn install --frozen-lockfile

FROM base AS dependencies-production

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock /var/www/catima/

# Install only production gems
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy package.json and yarn.lock
COPY package.json yarn.lock /var/www/catima/

# Install npm packages with production flag
RUN yarn install --frozen-lockfile --production=false

# =============================================================================
# DEVELOPMENT TARGETS
# =============================================================================
FROM dependencies AS app-dev

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

FROM dependencies AS worker-dev

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

# Copy application code
COPY . /var/www/catima/

# Precompile assets
RUN SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rails assets:precompile

# Replace default crontab
ADD ./docker/config/crontab /etc/crontab

# Copy supervisor configuration file
COPY ./docker/config/supervisord-app-staging.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script
COPY ./docker/config/entrypoint-app-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM dependencies AS worker-staging

# Copy application code
COPY . /var/www/catima/

# Copy supervisor configuration file
COPY ./docker/config/supervisord-worker-staging.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script
COPY ./docker/config/entrypoint-worker-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# =============================================================================
# PRODUCTION TARGETS
# =============================================================================
FROM dependencies-production AS app-production

# Copy application code
COPY . /var/www/catima/

# Precompile assets
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Remove unnecessary files to reduce image size
RUN rm -rf node_modules/*/test \
    node_modules/*/tests \
    node_modules/*/.github \
    tmp/cache \
    spec \
    test \
    coverage

# Replace default crontab
ADD ./docker/config/crontab /etc/crontab

# Copy supervisor configuration file
COPY ./docker/config/supervisord-app-production.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script
COPY ./docker/config/entrypoint-app-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM dependencies-production AS worker-production

# Copy application code
COPY . /var/www/catima/

# Remove unnecessary files to reduce image size
RUN rm -rf node_modules/*/test \
    node_modules/*/tests \
    node_modules/*/.github \
    tmp/cache \
    spec \
    test \
    coverage

# Copy supervisor configuration file
COPY ./docker/config/supervisord-worker-production.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script
COPY ./docker/config/entrypoint-worker-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
