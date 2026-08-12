# syntax=docker/dockerfile:1

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.120/bin/apache-tomcat-9.0.120.tar.gz"
ARG TOMCAT_SHA512="07eb6d9639c3e69af81171a16ccff1c19b7fd5b2e87e3646851f0a3f42a4ce3c1bf128fbe40fc978a08935ba4f0400ef3b43ded3e470b9aaf23b97a9e1fa0858"

RUN set -eux; \
    tmp="/tmp/tomcat9.tar.gz"; \
    curl -fsSL "${TOMCAT_URL}" -o "${tmp}"; \
    echo "${TOMCAT_SHA512}  ${tmp}" | sha512sum -c -; \
    topdir="$(tar -tzf "${tmp}" | head -n 1 | cut -d/ -f1)"; \
    tar -xzf "${tmp}" -C /usr/local; \
    rm -f "${tmp}"; \
    mv "/usr/local/${topdir}" /usr/local/tomcat

ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$PATH:$CATALINA_HOME/bin

EXPOSE 8080

CMD ["catalina.sh", "run"]
