# Ruby on Rails Environment
FROM ruby:2.7.1

# Set up Linux
RUN apt-get update -qq && apt-get install -y

# RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./


# Dependency stuff
RUN gem install bundler --no-document
RUN bundle install --no-binstubs --jobs $(nproc) --retry 3

COPY . .

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.2.1/wait /wait
RUN chmod +x /wait
