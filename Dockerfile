FROM node:11.15.0-alpine as node
FROM ruby:2.6.5-alpine3.9

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /opt/yarn-* /opt/yarn

RUN apk --update --upgrade add \
  git \
  build-base \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev \
  tzdata \
  file-dev \
  && rm -rf /var/cache/apk/*

ENV RAILS_ENV production

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test --jobs 20 --retry 5

COPY . ./
RUN DATABASE_URL=postgresql://fake:5432/fake rails assets:precompile

EXPOSE 3000

CMD rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0
