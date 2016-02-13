FROM codeclimate/alpine-ruby:b38

WORKDIR /usr/src/app
RUN apk --update add ruby ruby-dev ruby-bundler build-base git

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install -j 4 && \
    apk del build-base && rm -fr /usr/share/ri

RUN adduser -u 9000 -D app
USER app

RUN bundle-audit update

COPY . /usr/src/app

CMD ["/usr/src/app/bin/bundler-audit"]

