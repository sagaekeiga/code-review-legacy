FROM ruby:2.6.0-alpine

ENV LANG ja_JP.UTF-8
ENV PAGER busybox less

# 依存ライブラリのインストール
RUN apk update && \
  apk upgrade && \
  apk add --update\
  bash \
  build-base \
  curl-dev \
  git \
  libxml2-dev \
  libxslt-dev \
  linux-headers \
  postgresql \
  postgresql-dev \
  nodejs \
  openssh \
  ruby-dev \
  ruby-json \
  tzdata \
  yaml \
  yaml-dev \
  zlib-dev \
  imagemagick6 \
  imagemagick6-dev \
  jq \
  yarn

# Timezoneを日本に設定
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  apk del tzdata && \
  mkdir -p /usr/share/zoneinfo/Asia && \
  cp /etc/localtime /usr/share/zoneinfo/Asia/Tokyo

RUN gem install bundler

RUN echo $'--- \n\
  #gem: --no-ri --no-rdoc -a -x -I \n\
  :sources: \n\
  - https://rubygems.org/ \n\
  - http://gems.github.com \n\
  - http://gems.rubyforge.org/ \n\
  :update_sources: true \n\
  :verbose: true \n\
  :backtrace: false \n\
  :benchmark: false \n\
  :bulk_threshold: 1000 \n\
  install: --no-document \n\
  update: --no-document' > /etc/gemrc && chmod uog+r /etc/gemrc


##Cache bundle install#################
WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle config build.nokogiri --use-system-libraries && \
  bundle install --jobs 20 --retry 5 --without production
#######################################

RUN mkdir /app
WORKDIR /app

# ADD Gemfile /app/Gemfile
# ADD Gemfile.lock /app/Gemfile.lock
ADD . /app

# yarn
RUN yarn install