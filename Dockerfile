FROM alpine:3.15

ARG VERSION=${VERSION:-[VERSION]}

ENV VARNISH_BACKEND_ADDRESS 0.0.0.0 
ENV VARNISH_MEMORY 100M
ENV VARNISH_BACKEND_PORT 80
EXPOSE 80

# COPY patches/* /varnish-alpine-patches/

COPY ./install-packages.sh /usr/local/bin/
RUN apk update && apk add bash bc \
  && INSTALL_VERSION=$VERSION install-packages.sh \
  && rm /usr/local/bin/install-packages.sh

WORKDIR /app
COPY ./entrypoint.sh ./
CMD ["/app/entrypoint.sh"]
