FROM mhart/alpine-node

WORKDIR /usr/src/app
RUN apk --update add ruby ruby-dev ruby-bundler build-base git

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install -j 4 && \
    bundle-audit update && \
    apk del build-base && rm -fr /usr/share/ri

COPY . /usr/src/app

CMD ["/usr/src/app/bin/bundler-audit"]

