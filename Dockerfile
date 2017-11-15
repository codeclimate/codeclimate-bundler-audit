FROM alpine:3.6

RUN adduser -u 9000 -D app

WORKDIR /usr/src/app

RUN apk add --no-cache ruby ruby-json git && \
  gem install --no-ri --no-rdoc bundler && \
  rm -r ~/.gem

COPY Gemfile* /usr/src/app/
RUN bundle install --without=test --no-cache && \
    rm -rf ~/.bundle /usr/lib/ruby/gems/2.4.0/cache/* /usr/share/ri

COPY DATABASE_VERSION /usr/src/app/DATABASE_VERSION

COPY bin bin/
COPY lib lib/
RUN chown -R app:app .

USER app

# The following step has to be ran by app user aas it depends on $HOME
RUN bundle-audit update && \
  for f in ~/.local/share/ruby-advisory-db/*  ~/.local/share/ruby-advisory-db/.*; do \
    name="$(basename "$f")"; \
    test "$name" = "gems" || \
      test "$name" = "." || \
      test "$name" = ".." || \
      test "$name" = ".git" || \
      rm -r "$f"; \
  done

CMD ["/usr/src/app/bin/bundler-audit"]
