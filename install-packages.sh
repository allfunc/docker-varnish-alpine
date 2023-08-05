#!/usr/bin/env sh

###
# Environment ${INSTALL_VERSION} pass from Dockerfile
###

PYTHON="python3 py3-docutils py3-sphinx"
MAKE="build-base autoconf automake patch dpkg dpkg-dev"
BUILD_DEPS="$PYTHON $MAKE curl libtool libedit-dev linux-headers libexecinfo-dev"

INSTALL="libgcc gcc libc-dev pcre-dev pcre2-dev"

UPGRADE=""

echo "###"
echo "# Will install build tool"
echo "###"
echo ""
echo $BUILD_DEPS
echo ""
echo "###"
echo "# Will install"
echo "###"
echo ""
echo $INSTALL
echo ""
echo "###"
echo "# Will upgradee"
echo "###"
echo ""
echo $UPGRADE

apk add --virtual .build-deps $BUILD_DEPS && apk add $INSTALL --upgrade $UPGRADE || exit 2

#/* put your install code here */#
INSTALL_VERSION=${INSTALL_VERSION}
VARNISH_INSTALL_DIR=/tmp/varnish
VARNISH_URL=https://varnish-cache.org/downloads/varnish-${INSTALL_VERSION}.tgz

# Install VARNISH --- Start #
mkdir -p ${VARNISH_INSTALL_DIR}
echo ${VARNISH_URL}
curl -Lk ${VARNISH_URL} | tar -zx -C ${VARNISH_INSTALL_DIR} --strip-components=1 || exit 1
cd ${VARNISH_INSTALL_DIR}

sh autogen.sh && sh configure && make && make install  || exit 4 

rm -rf ${VARNISH_INSTALL_DIR}

runDeps="$(
  scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
    | tr ',' '\n' \
    | sort -u \
    | awk 'system("[ -e /usr/local/lib/" $1 " ] || [ -e /usr/local/lib/varnish/" $1 " ]") == 0 { next } { print "so:" $1 }'
)"
apk add --no-cache $runDeps || exit 3
# Install VARNISH --- End #

echo ""
echo "Varnish Version:"
varnishd -V || exit 2
echo ""

# Clean
apk del -f .build-deps && rm -rf /var/cache/apk/* || exit 1

exit 0
