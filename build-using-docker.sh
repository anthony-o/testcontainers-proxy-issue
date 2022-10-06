#!/usr/bin/env bash

set -ex

cd "$(dirname "$0")"

mkdir -p "$HOME/.m2"

# Detect a proxy if defined
if [ -z "$HTTPS_PROXY" ]; then
  export HTTPS_PROXY="$https_proxy"
fi
if [ -n "$HTTPS_PROXY" ]; then
  # Proxy detected, setting m2 configurations
  PROXY_HOST=$(echo "$HTTPS_PROXY" | sed -rn 's|http://.*:.*@(.*):.*|\1|p')
  PROXY_PORT=$(echo "$HTTPS_PROXY" | sed -rn 's|http://.*:.*@.*:(.*)|\1|p')
  PROXY_USER=$(echo "$HTTPS_PROXY" | sed -rn 's|http://(.*):.*@.*:.*|\1|p')
  PROXY_PASSWORD=$(echo "$HTTPS_PROXY" | sed -rn 's|http://.*:(.*)@.*:.*|\1|p')

  cat >"$HOME/.m2/settings.proxy.xml" <<EOF
<settings>
  <proxies>
   <proxy>
      <id>https-proxy</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>$PROXY_HOST</host>
      <port>$PROXY_PORT</port>
      <username>$PROXY_USER</username>
      <password>$PROXY_PASSWORD</password>
    </proxy>
   <proxy>
      <id>http-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>$PROXY_HOST</host>
      <port>$PROXY_PORT</port>
      <username>$PROXY_USER</username>
      <password>$PROXY_PASSWORD</password>
    </proxy>
  </proxies>
</settings>
EOF
  ADDITIONAL_MAVEN_OPTS="-Dhttps.proxyHost=$PROXY_HOST -Dhttps.proxyPort=$PROXY_PORT -Dhttps.proxyUser=$PROXY_USER -Dhttps.proxyPassword=$PROXY_PASSWORD -Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttp.proxyUser=$PROXY_USER -Dhttp.proxyPassword=$PROXY_PASSWORD"
  ADDITIONAL_MAVEN_CMD_PARAMETERS="--settings $HOME/.m2/settings.proxy.xml"
  # Retrieve SSL certificate of the proxy
  CRT_URL=$1
  if [ -n "$CRT_URL" ]; then
    CRT_FILENAME=${CRT_URL##*/}
    mkdir -p proxy-data
    (
      cd proxy-data
      [ -s "$CRT_FILENAME" ] || wget --no-proxy --no-check-certificate "$CRT_URL"
    )
    ADDITIONAL_CMD="cp /opt/java/openjdk/lib/security/cacerts ./proxy-data/ && keytool -importcert -alias $CRT_FILENAME -file ./proxy-data/$CRT_FILENAME -trustcacerts -keystore ./proxy-data/cacerts -storepass changeit -noprompt"
    ADDITIONAL_MAVEN_OPTS="$ADDITIONAL_MAVEN_OPTS -Djavax.net.ssl.trustStore=./proxy-data/cacerts"
  fi
fi
if [ -s "$HOME/.docker/config.json" ]; then
  ADDITIONAL_DOCKER_PARAMETERS="$ADDITIONAL_DOCKER_PARAMETERS -v $HOME/.docker/config.json:$HOME/.docker/config.json -e DOCKER_CONFIG=$HOME/.docker"
fi
[ -n "$ADDITIONAL_CMD" ] && ADDITIONAL_CMD="$ADDITIONAL_CMD;"
docker run -it --rm -u "$(id -u):$(getent group docker | cut -d: -f3)" -v "$(pwd):$(pwd)" -w "$(pwd)" -v "$HOME/.m2:$HOME/.m2" -v /var/run/docker.sock:/var/run/docker.sock -e "MAVEN_OPTS=$ADDITIONAL_MAVEN_OPTS -Duser.home=$HOME" $ADDITIONAL_DOCKER_PARAMETERS eclipse-temurin:17-jdk-alpine sh -cex "$ADDITIONAL_CMD ./mvnw $ADDITIONAL_MAVEN_CMD_PARAMETERS clean package"
