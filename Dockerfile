FROM ruby:2.3.3-alpine
LABEL maintainer="t-okuaki"

RUN apk update \
 && apk add --no-cache \
        ca-certificates \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base \
        ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.3.10 \
 && gem install json -v 2.1.0 \
 && gem install fluentd -v 1.3.3 \
 && gem install bigdecimal -v 1.3.5 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN mkdir -p /fluentd/log
RUN mkdir -p /fluentd/etc /fluentd/plugins

RUN addgroup -S fluent && adduser -S -g fluent fluent
RUN chown -R fluent /fluentd && chgrp -R fluent /fluentd

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/


ENV LD_PRELOAD=""
EXPOSE 24224 5140

USER fluent
ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
