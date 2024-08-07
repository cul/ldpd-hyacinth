#!/bin/bash

# Install Fedora if it has not already been installed.  The check below ensure that this
# installation only runs once (whenever the /opt/fedora volume is re-created).
if [ ! -f /opt/fedora/tomcat/bin/catalina.sh ]; then
  java -jar /opt/fcrepo-installer.jar /opt/install.properties
  echo 'Done running installer jar...'
fi

/opt/fedora/tomcat/bin/catalina.sh run

rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpcore-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
cp /opt/jars/apache-http/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/cul/s3-url-protocol-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/awssdk/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/cul/fcrepo3-s3-server-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/fedora.delegating-external.fcfg /opt/fedora/server/config/fedora.fcfg
touch /opt/fedora/tomcat/webapps/fedora/WEB-INF/web.xml