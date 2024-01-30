# This Dockerfile is based on "samveralabs/fcrepo3:3.8.1" (https://github.com/samvera-labs/fcrepo3/blob/main/Dockerfile),
# but we're not pulling "samveralabs/fcrepo3:3.8.1" in directly because:
# 1) That image isn't built for ARM
# 2) That image references a much slower sourceforge download link (we use GitHub instead).
# 3) We want to run on a different port (8080)
# 4) We want to enable the resource index (ri.enabled=true in install.properties)
# 5) We want to enable authentication with the default username/password (apia.auth.required=true in install.properties)

FROM amazoncorretto:8

ENV FEDORA_HOME /opt/fedora
ENV CATALINA_HOME /opt/fedora/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

WORKDIR /opt

COPY ./install.properties /opt/install.properties
COPY ./setup-and-start.sh /opt/setup-and-start.sh

RUN curl -L https://github.com/fcrepo3/fcrepo/releases/download/v3.8.1/fcrepo-installer-3.8.1.jar -o /opt/fcrepo-installer.jar

CMD /bin/bash ./setup-and-start.sh
