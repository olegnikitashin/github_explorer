ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

ENV RAILS_ENV="development" \
    PATH="/app/bin:$PATH" \
    LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLER_VERSION=2.5.5

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config curl

RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs=$BUNDLE_JOBS --retry=$BUNDLE_RETRY

RUN mkdir -p /app
WORKDIR /app

EXPOSE 3000

CMD ["/bin/bash"]