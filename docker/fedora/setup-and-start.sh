#!/bin/bash

# Install Fedora if it has not already been installed.  The check below ensure that this
# installation only runs once (whenever the /opt/fedora volume is re-created).
if [ ! -f /opt/fedora/tomcat/bin/catalina.sh ]; then
  java -jar /opt/fcrepo-installer.jar /opt/install.properties
  echo 'Done running installer jar...'
fi

echo "Manually unpacking WAR to override libraries"
mkdir -p /opt/fedora/webapp-tmp/fedora
mv /opt/fedora/tomcat/webapps/fedora.war /opt/fedora/webapp-tmp/fedora/
cd /opt/fedora/webapp-tmp/fedora
jar -xvf fedora.war
cd /opt
mv /opt/fedora/webapp-tmp/fedora /opt/fedora/tomcat/webapps/

rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpcore-4*.jar
rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
cp /opt/jars/apache-http/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/cul/s3-url-protocol-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/awssdk/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
cp /opt/jars/cul/fcrepo3-s3-server-1.0-SNAPSHOT.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
echo "Done overriding Fedora 3 libraries; setting new FCFG config"
cp /opt/fedora.delegating-external.fcfg /opt/fedora/server/config/fedora.fcfg
cp /opt/permit-all-s3-resolution.xml /opt/fedora/data/fedora-xacml-policies/repository-policies/default/permit-all-s3-resolution.xml

/opt/fedora/tomcat/bin/catalina.sh run
