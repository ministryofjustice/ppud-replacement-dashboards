FROM ruby:3.0.1-alpine3.13

ARG BUILD_NUMBER
ARG GIT_REF

RUN mkdir /app

RUN apk update && \
  apk upgrade && \
  apk add --no-cache nodejs tzdata build-base

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle config set --local without 'dev' && \
  bundle install

COPY . /app/

EXPOSE 3000

CMD ["smashing", "start", "-p", "3000", "-e", "production"]
