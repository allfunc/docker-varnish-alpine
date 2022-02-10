#!/bin/bash

INSTALL_VERSION=${INSTALL_VERSION}
VARNISH_INSTALL_DIR=/tmp/varnish
VARNISH_URL=https://varnish-cache.org/downloads/varnish-${INSTALL_VERSION}.tgz

INSTALL="gcc libc-dev libgcc pcre-dev pcre2-dev"

PYTHON="python3 py3-docutils py3-sphinx"
MAKE="build-base autoconf automake patch dpkg dpkg-dev"
BUILD_DEPS="$PYTHON $MAKE curl libtool libedit-dev libexecinfo-dev linux-headers"

echo "###"
echo "# Will install"
echo "###"
echo ""
echo $INSTALL
echo ""
echo "###"
echo "# Will build package"
echo "###"
echo ""
echo $BUILD_DEPS
echo ""

apk add --virtual .build-deps $BUILD_DEPS && apk add $INSTALL

# Install VARNISH #
mkdir -p ${VARNISH_INSTALL_DIR}
echo ${VARNISH_URL}
curl -Lk ${VARNISH_URL} | tar -zx -C ${VARNISH_INSTALL_DIR} --strip-components=1 || exit 1
cd ${VARNISH_INSTALL_DIR}

for p in /varnish-alpine-patches/*.patch; do
  [ -f "$p" ] || continue
  patch -p1 -i "$p"
done

sh autogen.sh && sh configure && make && make install

rm -rf ${VARNISH_INSTALL_DIR}

runDeps="$(
  scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ] || [ -e /usr/local/lib/varnish/" $1 " ]") == 0 { next } { print "so:" $1 }'
)"
apk add --no-cache --virtual .varnish-rundeps $runDeps
# Install VARNISH #

echo ""
echo "Varnish Version:"
varnishd -V;
echo ""

apk del -f .build-deps && rm -rf /var/cache/apk/* || exit 2

exit 0
