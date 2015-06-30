FROM derjudge/archlinux

ENV OPENRESTY_VERSION 1.7.10.1

RUN pacman -Sq --noconfirm gcc make postgresql-libs unzip wget

RUN wget -qO- \
	https://openresty.org/download/ngx_openresty-${OPENRESTY_VERSION}.tar.gz \
	| tar xzv -C /root/ && \
	cd /root/ngx_openresty-${OPENRESTY_VERSION} && \
	./configure --prefix=/opt/openresty \
		--with-luajit --with-http_postgres_module && \
	make && make install && \
	cd / && rm -rf /root/ngx_openresty-* && \
	ln -sf /opt/openresty/nginx/sbin/nginx /usr/bin/nginx && \
	ln -sf /usr/bin/nginx /usr/bin/openresty && \
	ln -sf /usr/openresty/bin/resty /usr/bin/resty && \
	ln -sf /opt/openresty/luajit/bin/luajit-2.1.0-alpha /usr/bin/luajit && \
	ln -sf /usr/bin/luajit /usr/bin/lua && \
	ln -sf /usr/bin/luajit /opt/openresty/luajit/bin/lua && \
	wget -qO- https://luarocks.org/releases/luarocks-2.2.1.tar.gz \
	| tar xzv -C /root/ && \
	cd /root/luarocks-2.2.1 && \
	./configure \
		--with-lua=/opt/openresty/luajit \
		--with-lua-include=/opt/openresty/luajit/include/luajit-2.1 \
		--with-lua-lib=/opt/openresty/lualib && \
	make && make install && \
	cd / && rm -rf /root/luarocks-* && \
	paccache -rfk0 && \
	luarocks install moonscript && \
	luarocks install lapis

RUN mkdir /app
WORKDIR /app
VOLUME /app

ENV LAPIS_OPENRESTY "/opt/openresty/nginx/sbin/nginx"
ENV LAPIS_ENVIRONMENT "development"

# Note: Setting --prefix in luarocks configure just breaks shit.
CMD ["/usr/local/bin/lapis", "server", "$LAPIS_ENVIRONMENT"]
