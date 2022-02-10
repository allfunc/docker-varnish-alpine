#!/bin/bash

INSTALL="openssl curl sed bash jq"

UPGRADE="grep"

BUILD_DEPS=""

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

apk add --virtual .build-deps $BUILD_DEPS && apk add $INSTALL --upgrade $UPGRADE

apk del -f .build-deps && rm -rf /var/cache/apk/* || exit 1

exit 0
