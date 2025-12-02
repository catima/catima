FROM ruby:3.4-slim-trixie AS base

ENV COREPACK_ENABLE_AUTO_PIN=0

ENV PSQL_CLIENT_VERSION=18
ENV NODE_VERSION=22
ENV YARN_VERSION=1.22
ENV SUPERCRONIC_VERSION=0.2.39
ENV NGINX_VERSION=1.28.0
ENV BUNDLER_VERSION=2.4.5

# Update repositories & add needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev \
    libpq-dev \
    libyaml-dev \
    procps \
    curl \
    git \
    imagemagick \
    unzip \
    supervisor \
    lsb-release \
    ca-certificates \
    gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install specific version of Supercronic (cron replacement for non-root users)
RUN ARCH=$(dpkg --print-architecture) && \
    SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${ARCH}" && \
    curl -fsSL "${SUPERCRONIC_URL}" -o /usr/local/bin/supercronic && \
    chmod +x /usr/local/bin/supercronic && \
    supercronic -version

# Install specific version of Postgresql Client
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    psql --version

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

# Install specific version of Bundler
RUN gem install bundler -v $BUNDLER_VERSION && \
    bundler --version

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

FROM base AS dependencies-production

# Install specific version of Nginx
RUN curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}-1~`lsb_release -cs` && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/nginx /var/cache/nginx /var/run/nginx /etc/nginx/sites-available /etc/nginx/sites-enabled && \
    chown -R catima:catima /var/log/nginx /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /var/log/nginx /var/cache/nginx /var/run/nginx && \
    nginx -v

# Copy nginx configurations
COPY ./docker/config/nginx.conf /var/www/catima/config/nginx.conf
COPY ./docker/config/nginx-catima.conf /etc/nginx/sites-available/default
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle config set --local without 'development test' && \
    bundle install

# Copy package.json and yarn.lock, then install js dependencies
COPY package.json yarn.lock /var/www/catima/
RUN yarn install --frozen-lockfile --production=true && \
    yarn cache clean

# Clone custom catalogs from the catima/catalogs repository
RUN mkdir -p /var/www/catima/catalogs && \
    git clone --depth 1 https://github.com/catima/catalogs.git /tmp/catalogs && \
    find /tmp/catalogs -mindepth 1 -maxdepth 1 -type d ! -name '.*' -exec cp -r {} /var/www/catima/catalogs/ \; && \
    rm -rf /tmp/catalogs && \
    chown -R catima:catima /var/www/catima/catalogs

# Copy Kubernetes poststart script
COPY docker/config/k8s-poststart.sh /var/www/catima/k8s-poststart.sh
RUN chmod +x /var/www/catima/k8s-poststart.sh

# =============================================================================
# DEVELOPMENT TARGETS
# =============================================================================
FROM dependencies-development AS app-dev

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

# Copy supervisor configuration and entrypoint
COPY ./docker/config/supervisord-app-staging.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-app-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy unicorn configuration
COPY ./docker/config/unicorn.rb /var/www/catima/config/unicorn.rb

# Switch to catima user
USER catima

# Copy crontab for supercronic
COPY --chown=catima:catima ./docker/config/crontab-catima /var/www/catima/config/crontab

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
RUN cp config/database.example.yml.stage config/database.yml

# Precompile assets & generate locale files
RUN SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rails assets:precompile

# Remove node_modules, then reinstall only Mammoth with its dependencies
# Extract mammoth URL from package.json before cleanup
USER root
RUN MAMMOTH_URL=$(node -pe "require('./package.json').dependencies.mammoth") && \
    rm -rf node_modules package.json yarn.lock && \
    yarn cache clean && \
    npm install --production --no-optional "$MAMMOTH_URL"
USER catima

# Download and extract Swagger documentation
RUN curl -L https://nightly.link/catima/catima/workflows/api/development/swagger-documentation.zip -o tmp/swagger.zip && \
    unzip tmp/swagger.zip -d swagger/v3/ && \
    rm tmp/swagger.zip

# Remove docker directory
RUN rm -rf docker

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM dependencies-production AS worker-staging

# Copy supervisor configuration and entrypoint
COPY ./docker/config/supervisord-worker-staging.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-worker-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to catima user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for sidekiq
RUN cp config/database.example.yml.stage config/database.yml

# Remove node_modules, then reinstall only Mammoth with its dependencies
# Extract mammoth URL from package.json before cleanup
USER root
RUN MAMMOTH_URL=$(node -pe "require('./package.json').dependencies.mammoth") && \
    rm -rf node_modules package.json yarn.lock && \
    yarn cache clean && \
    npm install --production --no-optional "$MAMMOTH_URL"
USER catima

# Remove docker directory
RUN rm -rf docker

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# =============================================================================
# PRODUCTION TARGETS
# =============================================================================
FROM dependencies-production AS app-production

# Copy supervisor configuration and entrypoint
COPY ./docker/config/supervisord-app-production.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker/config/entrypoint-app-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy unicorn configuration
COPY ./docker/config/unicorn.rb /var/www/catima/config/unicorn.rb

# Switch to catima user
USER catima

# Copy crontab for supercronic
COPY --chown=catima:catima ./docker/config/crontab-catima /var/www/catima/config/crontab

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
RUN cp config/database.example.yml.prod config/database.yml

# Precompile assets & generate locale files
RUN SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Remove node_modules, then reinstall only Mammoth with its dependencies
# Extract mammoth URL from package.json before cleanup
USER root
RUN MAMMOTH_URL=$(node -pe "require('./package.json').dependencies.mammoth") && \
    rm -rf node_modules package.json yarn.lock && \
    yarn cache clean && \
    npm install --production --no-optional "$MAMMOTH_URL"
USER catima

# Download and extract Swagger documentation
RUN curl -L https://nightly.link/catima/catima/workflows/api/master/swagger-documentation.zip -o tmp/swagger.zip && \
    unzip tmp/swagger.zip -d swagger/v3/ && \
    rm tmp/swagger.zip

# Remove docker directory
RUN rm -rf docker

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

# Remove node_modules, then reinstall only Mammoth with its dependencies
# Extract mammoth URL from package.json before cleanup
USER root
RUN MAMMOTH_URL=$(node -pe "require('./package.json').dependencies.mammoth") && \
    rm -rf node_modules package.json yarn.lock && \
    yarn cache clean && \
    npm install --production --no-optional "$MAMMOTH_URL"
USER catima

# Remove docker directory
RUN rm -rf docker

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
