FROM ruby:2.7-alpine3.13

ARG BUILD_NUMBER
ARG GIT_REF

RUN mkdir /app

RUN apk update && \
  apk upgrade && \
  apk add --no-cache nodejs tzdata build-base aws-cli p7zip

ARG MSSODBCSQL_VERSION=17.7.2.1-1
ARG MSSQLTOOLS_VERSION=17.7.1.1-1

RUN set -x \
  && tempDir="$(mktemp -d)" \
  && chown nobody:nobody $tempDir \
  && cd $tempDir \
  && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSODBCSQL_VERSION}_amd64.apk" \
  && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQLTOOLS_VERSION}_amd64.apk" \
  && apk add --allow-untrusted msodbcsql17_${MSSODBCSQL_VERSION}_amd64.apk \
  && apk add --allow-untrusted mssql-tools_${MSSQLTOOLS_VERSION}_amd64.apk \
  && rm -rf $tempDir \
  && rm -rf /var/cache/apk/*

RUN addgroup --gid 2000 appuser && \
  adduser --uid 2000 --disabled-password --ingroup appuser --home /app appuser

USER 2000
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
