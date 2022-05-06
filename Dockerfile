FROM ghcr.io/linuxserver-labs/prarr:baseimage-main

# set version label
ARG APP
ARG BUILD_DATE
ARG EXPOSE_PORT
ARG PULL_REQUEST_BRANCH
ARG PULL_REQUEST_RELEASE
LABEL build_version="Linuxserver.io Build-date:- ${BUILD_DATE}"
LABEL maintainer="Roxedus"

ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  if [ ${APP} == "lidarr" ]; then \
    apk add --no-cache chromaprint; \
  fi && \
  echo "**** install ${APP} ****" && \
  mkdir -p "/app/${APP}/bin" && \
  curl -o \
    /tmp/app.tar.gz -L \
    "https://${APP}.servarr.com/v1/update/${PULL_REQUEST_BRANCH}/updatefile?version=${PULL_REQUEST_RELEASE}&os=linuxmusl&runtime=netcore&arch=x64" && \
  tar xzf \
    /tmp/app.tar.gz -C \
    /app/${APP}/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${PULL_REQUEST_BRANCH}\nPackageVersion=${PULL_REQUEST_RELEASE}\nPackageAuthor=[linuxserver.io](https://www.linuxserver.io/)" > "/app/${APP}/package_info" && \
  /bin/bash -c " \
  printf \"\$(cat /etc/services.d/app/run)\" \${APP} \${APP} \${APP^} > /etc/services.d/app/run && \
  mv /etc/services.d/app /etc/services.d/\${APP}  && \
  echo \"**** cleanup ****\" && \
  rm -rf \
    \"/app/\${APP}/bin/\${APP^}.Update\" \
    /tmp/* \
    /var/tmp/*"
# ports and volumes
EXPOSE ${EXPOSE_PORT}
VOLUME /config