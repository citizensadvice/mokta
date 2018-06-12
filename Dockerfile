FROM ruby:2.5.1

ENV APP_ROOT /app
ENV APP_ENV production

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/
RUN gem install bundler && bundle install && bundle clean

COPY . $APP_ROOT

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["ruby", "app.rb", "-o", "0.0.0.0", "-p", "4001"]
