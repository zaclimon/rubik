FROM ruby:2.4.1

RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list && \
    apt-key update && \
    apt-get update && \
    apt-get install -y apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs yarn && \
    git clone https://github.com/Krystosterone/rubik

WORKDIR /rubik
RUN bundle install && yarn --ignore-engines install

# Change the database host to the container 
RUN sed -i '/host/ s/localhost/db/g' config/database.yml && sed -i '/config.active_job.queue_adapter/ a\  config.allow_concurrency = false' config/environments/test.rb

CMD [ "bundle exec rails db:create db:migrate db:test:prepare db:seed" ]