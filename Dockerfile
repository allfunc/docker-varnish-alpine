ARG VERSION=${VERSION:-[VERSION]}

FROM alpine:3.16

ARG VERSION

# apk
COPY ./install-packages.sh /usr/local/bin/install-packages
RUN apk update && apk add bash bc \
  && INSTALL_VERSION=$VERSION install-packages \
  && rm /usr/local/bin/install-packages;

ENV VARNISH_BACKEND_ADDRESS=0.0.0.0 \
    VARNISH_MEMORY=100M \
    VARNISH_BACKEND_PORT=80

EXPOSE 80
WORKDIR /app

COPY ./docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
