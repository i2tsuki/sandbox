# syntax=docker/dockerfile:1.0-experimental

FROM fluent/fluentd:v1.3.3-debian-1.0

USER root

##
# For BuildKit
##

# RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt \
#     --mount=type=cache,id=apt-state,target=/var/lib/apt \
#     echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression && \
#     apt-get update -yq && \
#     apt-get install -yq --no-install-recommends sudo make gcc g++ libc-dev ruby-dev

# RUN gem install fluent-plugin-kubernetes_metadata_filter -v 2.1.6 && \
#     gem install fluent-plugin-google-cloud -v 0.7.5 && \
#     gem sources --clear-all

##
# For No BuildKit
##

RUN apt-get update -yq && \
    apt-get install -yq --no-install-recommends sudo make gcc g++ libc-dev ruby-dev

RUN gem install fluent-plugin-kubernetes_metadata_filter -v 2.1.6 --no-document && \
    gem install fluent-plugin-google-cloud -v 0.7.5 --no-document && \
    gem install fluent-plugin-record-reformer -v 0.9.1 --no-document && \
    gem install fluent-plugin-rewrite-tag-filter -v 2.2.0 --no-document && \
    gem install fluent-plugin-detect-exceptions -v 0.0.12 --no-document && \
    gem install fluent-plugin-prometheus -v 1.3.0 --no-document && \
    gem install fluent-plugin-multi-format-parser -v 1.0.0 --no-document && \
    gem sources --clear-all

USER fluent
CMD ["fluentd", "-c", "/fluentd/etc/fluent.conf"]
