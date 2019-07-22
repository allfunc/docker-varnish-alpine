FROM alpine:3.8

ARG VARNISH_VERSION=6.2.0
ARG VARNISH_URL=https://varnish-cache.org/_downloads/varnish-${VARNISH_VERSION}.tgz
ARG VARNISH_INSTALL_DIR=/tmp/varnish
      
ENV VARNISH_BACKEND_ADDRESS 0.0.0.0 
ENV VARNISH_MEMORY 100M
ENV VARNISH_BACKEND_PORT 80
EXPOSE 80

# persistent / runtime deps
RUN apk add --no-cache --virtual .persistent-deps \
	gcc \
	libc-dev \
	libgcc

RUN apk add --no-cache --virtual .build-deps \
	curl \
	autoconf \
	automake \
	libtool \
	make \
	pkgconf \
	patch \
	dpkg \
	dpkg-dev \
	python3 \
	pcre-dev \
	libedit-dev \
	libexecinfo-dev \
	linux-headers

COPY patches/* /varnish-alpine-patches/

RUN mkdir -p ${VARNISH_INSTALL_DIR} && \
	curl -Lk ${VARNISH_URL} | \
	tar -zx -C ${VARNISH_INSTALL_DIR} --strip-components=1

RUN cd ${VARNISH_INSTALL_DIR}; \
	for p in /varnish-alpine-patches/*.patch; do \
	       [ -f "$p" ] || continue; \
	       patch -p1 -i "$p"; \
	done; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./autogen.sh; \
	./configure \
		--build="$gnuArch" \
		--without-jemalloc \
		--with-rst2man=$(command -v true) \
		--with-sphinx-build=$(command -v true) \
	; \
	make -j "$(nproc)"; \
	make install; \		
	rm -rf ${VARNISH_INSTALL_DIR};

RUN runDeps="$( \
	scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
	| tr ',' '\n' \
	| sort -u \
	| awk 'system("[ -e /usr/local/lib/" $1 " ] || [ -e /usr/local/lib/varnish/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .varnish-rundeps $runDeps; \
	apk del .build-deps; \
	rm -rf /var/cache/apk/*; \
	varnishd -V;

WORKDIR /app
COPY ./entrypoint.sh ./
CMD ["/app/entrypoint.sh"]
