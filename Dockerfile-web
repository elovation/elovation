FROM ruby:2.4.0

RUN apt-get update \
    && apt-get -y install curl \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN apt-get install -y --no-install-recommends \
        postgresql-client \
    && apt-get install -y build-essential patch libpq-dev ruby-dev nodejs zlib1g-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem update --system

RUN gem install bundler foreman

RUN mkdir /var/elovation
RUN mkdir /var/elovation/public
RUN mkdir /var/elovation/public/assets

COPY Gemfile /var/elovation/
COPY Gemfile.lock /var/elovation/

RUN mkdir -p /var/bundle

# Add application source
WORKDIR /var/elovation

ADD . /var/elovation

ADD config/database.yml.docker /var/elovation/config/database.yml
COPY ./web-entrypoint.sh /
RUN ["chmod", "+x", "/web-entrypoint.sh"]
RUN npm install yarn -g

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT yes
ENV RAILS_SERVE_STATIC_FILES yes

EXPOSE 5000

ENTRYPOINT ["/web-entrypoint.sh"]

CMD ["foreman", "start"]

