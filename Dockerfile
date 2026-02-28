FROM alpine:3.23.3 AS webproc
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ENV WEBPROCVERSION=0.4.0
ENV WEBPROCURL=https://github.com/jpillora/webproc/releases/download/v$WEBPROCVERSION/webproc_"$WEBPROCVERSION"_linux_amd64.gz
RUN apk add --no-cache curl=8.17.0-r1 && \
    curl -sL $WEBPROCURL | gzip -d - > /usr/local/bin/webproc && \
    chmod +x /usr/local/bin/webproc

FROM alpine:3.23.3
LABEL maintainer="Luke Tainton <luke@tainton.uk>"
LABEL org.opencontainers.image.source="https://git.tainton.uk/repos/docker-radius"
LABEL org.opencontainers.image.description="FreeRADIUS server with web administration interface"
LABEL org.opencontainers.image.title="docker-radius"
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN apk --no-cache add freeradius=3.0.27-r2
COPY --from=webproc /usr/local/bin/webproc /usr/local/bin/webproc
COPY clients.conf /etc/raddb/clients.conf
COPY users /etc/raddb/users
COPY radiusd.conf /etc/raddb/radiusd.conf
RUN chmod -R o-w /etc/raddb/
ENTRYPOINT ["webproc","-o","restart","-c","/etc/raddb/users","-c", "/etc/raddb/clients.conf", "-c", "/etc/raddb/radiusd.conf","--","radiusd","-f","-l","stdout"]
EXPOSE 1812/udp 1813/udp 8080/tcp
