#!/bin/bash

# Install Fedora if it has not already been installed.  The check below ensure that this
# installation only runs once (whenever the /opt/fedora volume is re-created).
if [ ! -f /opt/fedora/tomcat/bin/catalina.sh ]; then
  java -jar /opt/fcrepo-installer.jar /opt/install.properties
  echo 'Done running installer jar...'
fi

rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpcore-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
cp /opt/apache-http/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/s3-url-protocol-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/awssdk/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/fcrepo3-s3-server-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/s3-2.26.27.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/aws-core-2.26.27.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/fedora.delegating-external.fcfg /opt/fedora/server/config/fedora.fcfg

/opt/fedora/tomcat/bin/catalina.sh run

