FROM ruby:3.4-slim-trixie AS runtime

ENV COREPACK_ENABLE_AUTO_PIN=0

ENV PSQL_CLIENT_VERSION=18
ENV NODE_VERSION=22
ENV PNPM_VERSION=12.4.1
ENV SUPERCRONIC_VERSION=0.2.39
ENV NGINX_VERSION=1.30.4
ENV BUNDLER_VERSION=2.4.5

# Install runtime-only packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgmp10 \
    libpq5 \
    libvips42t64 \
    libyaml-0-2 \
    procps \
    curl \
    vim \
    imagemagick \
    supervisor \
    lsb-release \
    ca-certificates \
    gnupg \
    logrotate \
    libjemalloc2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure jemalloc for better memory management
RUN JEMALLOC_PATH=$(find /usr/lib -name libjemalloc.so.2 -print -quit) && \
    echo "Found jemalloc at: ${JEMALLOC_PATH}" && \
    ln -s "${JEMALLOC_PATH}" /usr/local/lib/libjemalloc.so.2 && \
    echo "export LD_PRELOAD=/usr/local/lib/libjemalloc.so.2" >> /etc/profile.d/jemalloc.sh && \
    chmod +x /etc/profile.d/jemalloc.sh
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2
ENV MALLOC_CONF="background_thread:true,dirty_decay_ms:5000,muzzy_decay_ms:5000,narenas:4"

# Install specific version of Supercronic (cron replacement for non-root users)
RUN ARCH=$(dpkg --print-architecture) && \
    SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${ARCH}" && \
    curl -fsSL "${SUPERCRONIC_URL}" -o /usr/local/bin/supercronic && \
    chmod +x /usr/local/bin/supercronic && \
    supercronic -version

# Install specific version of Postgresql Client
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-$PSQL_CLIENT_VERSION && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    psql --version

# Install specific version of Node
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | \
    tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get purge -y --auto-remove gnupg lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define user and group to run the application
RUN groupadd -g 1000 catima && \
    useradd -u 1000 -g catima -m -s /bin/bash catima

# Create and set the working directory
RUN mkdir -p /var/www/catima && \
    chown -R catima:catima /var/www/catima
WORKDIR /var/www/catima

# Configure logrotate for application logs
COPY ./docker/config/logrotate-catima /etc/logrotate.d/catima
RUN chmod 0644 /etc/logrotate.d/catima

FROM runtime AS build

# Install build-only packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libgmp-dev \
    libpq-dev \
    libyaml-dev \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install specific version of Bundler
RUN gem install bundler -v $BUNDLER_VERSION && \
    gem cleanup && \
    bundler --version

# Install specific version of pnpm
RUN corepack enable && \
    corepack prepare pnpm@$PNPM_VERSION --activate && \
    pnpm --version

FROM build AS development-dependencies

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle install

FROM build AS production-dependencies

# Copy the Gemfile and Gemfile.lock, and run Bundler
COPY Gemfile Gemfile.lock /var/www/catima/
RUN bundle config set --local without 'development test' && \
    bundle install && \
    bundle clean --force && \
    rm -rf /usr/local/bundle/cache

# Copy package.json and pnpm lockfile, then install js dependencies
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml /var/www/catima/
RUN pnpm install --frozen-lockfile --prod && \
    pnpm store prune && \
    chown -R catima:catima /var/www/catima/node_modules

# Bundle the runtime-only Mammoth CLI for the application images
RUN MAMMOTH_URL=$(node -pe "require('./package.json').dependencies.mammoth") && \
    mkdir -p /opt/catima-mammoth && \
    npm install --prefix /opt/catima-mammoth --production --no-optional "$MAMMOTH_URL" && \
    npm install --prefix /opt/catima-mammoth --no-save --production=false browserify && \
    printf '#!/usr/bin/env node\n' > /opt/catima-mammoth/mammoth.js && \
    /opt/catima-mammoth/node_modules/.bin/browserify \
      /opt/catima-mammoth/node_modules/mammoth/bin/mammoth \
      --node \
      >> /opt/catima-mammoth/mammoth.js && \
    chmod +x /opt/catima-mammoth/mammoth.js

# Copy Kubernetes poststart script
COPY docker/config/k8s-poststart.sh /var/www/catima/k8s-poststart.sh
RUN chmod +x /var/www/catima/k8s-poststart.sh

# DEVELOPMENT TARGETS
# =============================================================================
FROM development-dependencies AS app-dev

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-app-dev.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in development
COPY ./docker/config/entrypoint-app-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM development-dependencies AS worker-dev

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-worker-dev.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in development
COPY ./docker/config/entrypoint-worker-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# ASSET BUILDERS
# =============================================================================
FROM production-dependencies AS staging-assets

# Switch to unprivileged user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
# Precompile assets & generate locale files
RUN cp config/database.example.yml.stage config/database.yml && \
    SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=staging bundle exec rails assets:precompile

# Remove build-only files from the reusable runtime artifact
USER root
RUN mv /var/www/catima/node_modules /opt/catima-build-node-modules && \
    rm -f /var/www/catima/package.json /var/www/catima/pnpm-lock.yaml /var/www/catima/pnpm-workspace.yaml && \
    rm -rf /var/www/catima/docker
USER catima

FROM production-dependencies AS production-assets

# Switch to unprivileged user
USER catima

# Copy application code with proper ownership
COPY --chown=catima:catima . /var/www/catima/

# Create database.yml from example for asset precompilation
# Precompile assets & generate locale files
RUN cp config/database.example.yml.prod config/database.yml && \
    SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rake locales:generate && \
    SECRET_KEY_BASE=dummy RAILS_ENV=production bundle exec rails assets:precompile

# Remove build-only files from the reusable runtime artifact
USER root
RUN mv /var/www/catima/node_modules /opt/catima-build-node-modules && \
    rm -f /var/www/catima/package.json /var/www/catima/pnpm-lock.yaml /var/www/catima/pnpm-workspace.yaml && \
    rm -rf /var/www/catima/docker
USER catima

FROM runtime AS web-runtime

# Install specific version of Nginx
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/debian $(. /etc/os-release && echo "$VERSION_CODENAME") nginx" | tee /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nginx=${NGINX_VERSION}-1~$(. /etc/os-release && echo "$VERSION_CODENAME") && \
    apt-get purge -y --auto-remove gnupg && \
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

# STAGING TARGETS
# =============================================================================
FROM web-runtime AS app-staging

# Copy application code and dependencies
COPY --from=staging-assets --chown=catima:catima /usr/local/bundle /usr/local/bundle
COPY --from=staging-assets --chown=catima:catima /var/www/catima /var/www/catima
COPY --from=production-dependencies --chown=catima:catima \
    /opt/catima-mammoth/mammoth.js /var/www/catima/bin/mammoth

# Copy crontab for supercronic
COPY --chown=catima:catima ./docker/config/crontab-catima /var/www/catima/config/crontab

# Copy puma configuration and helpers
COPY --chown=catima:catima ./docker/config/puma_helpers.rb /var/www/catima/config/puma_helpers.rb
COPY --chown=catima:catima ./docker/config/puma.rb /var/www/catima/config/puma.rb

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-app-staging.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in staging
COPY ./docker/config/entrypoint-app-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to unprivileged user
USER catima

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM runtime AS worker-staging

# Copy application code and dependencies
COPY --from=staging-assets --chown=catima:catima /usr/local/bundle /usr/local/bundle
COPY --from=staging-assets --chown=catima:catima /var/www/catima /var/www/catima
COPY --from=production-dependencies --chown=catima:catima \
    /opt/catima-mammoth/mammoth.js /var/www/catima/bin/mammoth

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-worker-staging.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in staging
COPY ./docker/config/entrypoint-worker-staging.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to unprivileged user
USER catima

# Set staging environment
ENV RAILS_ENV=staging
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# PRODUCTION TARGETS
# =============================================================================
FROM web-runtime AS app-production

# Copy application code and dependencies
COPY --from=production-assets --chown=catima:catima /usr/local/bundle /usr/local/bundle
COPY --from=production-assets --chown=catima:catima /var/www/catima /var/www/catima
COPY --from=production-dependencies --chown=catima:catima \
    /opt/catima-mammoth/mammoth.js /var/www/catima/bin/mammoth

# Copy crontab for supercronic
COPY --chown=catima:catima ./docker/config/crontab-catima /var/www/catima/config/crontab

# Copy puma configuration and helpers
COPY --chown=catima:catima ./docker/config/puma_helpers.rb /var/www/catima/config/puma_helpers.rb
COPY --chown=catima:catima ./docker/config/puma.rb /var/www/catima/config/puma.rb

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-app-production.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in production
COPY ./docker/config/entrypoint-app-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to unprivileged user
USER catima

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

FROM runtime AS worker-production

# Copy application code and dependencies
COPY --from=production-assets --chown=catima:catima /usr/local/bundle /usr/local/bundle
COPY --from=production-assets --chown=catima:catima /var/www/catima /var/www/catima
COPY --from=production-dependencies --chown=catima:catima \
    /opt/catima-mammoth/mammoth.js /var/www/catima/bin/mammoth

# Copy supervisor configuration file
#
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf tail -f <service>
# supervisorctl -c /etc/supervisor/conf.d/supervisord.conf restart <service>
COPY ./docker/config/supervisord-worker-production.conf /etc/supervisor/conf.d/supervisord.conf

# Add the entrypoint script used in production
COPY ./docker/config/entrypoint-worker-production.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to unprivileged user
USER catima

# Set production environment
ENV RAILS_ENV=production
ENV NODE_ENV=production

ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
