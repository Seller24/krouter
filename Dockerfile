ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-alpine

RUN apk update \
    && apk add --virtual build-dependencies less \
    build-base \
    gcc

ENV GEM_HOME=/usr/local/bundle \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_PATH="$GEM_HOME" \
    LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

ARG BUNDLER_VERSION
RUN gem install bundler:$BUNDLER_VERSION

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
