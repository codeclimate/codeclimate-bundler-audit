FROM codeclimate/alpine-ruby:b38

WORKDIR /usr/src/app
RUN apk --update add ruby ruby-bundler git

COPY Gemfile* /usr/src/app/
RUN bundle install --jobs 4 && \
    rm -rf /usr/share/ri

RUN adduser -u 9000 -D app
USER app

RUN bundle-audit update

COPY . /usr/src/app

CMD ["/usr/src/app/bin/bundler-audit"]
