FROM ruby:3.0.1-alpine3.13

ARG BUILD_NUMBER
ARG GIT_REF

RUN mkdir /app

RUN apk update && \
  apk upgrade && \
  apk add --no-cache nodejs tzdata build-base

RUN addgroup appuser && \
  adduser -D -G appuser -h /app appuser

USER appuser
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle config set --local without 'dev' && \
  bundle config set --local deployment 'true' && \
  bundle config set --local frozen 'true' && \
  bundle install

COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "smashing", "start", "-p", "3000", "-e", "production"]
