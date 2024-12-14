#!/bin/bash

# Install Fedora if it has not already been installed.  The check below ensure that this
# installation only runs once (whenever the /opt/fedora volume is re-created).
if [ ! -f /opt/fedora/tomcat/bin/catalina.sh ]; then
  java -jar /opt/fcrepo-installer.jar /opt/install.properties
  echo 'Done running installer jar...'

  echo "Manually unpacking WAR to override libraries"
  mkdir -p /opt/fedora/webapp-tmp/fedora
  mv /opt/fedora/tomcat/webapps/fedora.war /opt/fedora/webapp-tmp/fedora/
  cd /opt/fedora/webapp-tmp/fedora
  jar -xvf fedora.war
  cd /opt
  mv /opt/fedora/webapp-tmp/fedora /opt/fedora/tomcat/webapps/

  # # Temporarily switch Fedora port 8080 to 8081 so that the CI task process
  # # monitoring Fedora startup doesn't think that Fedora is ready yet.
  sed -i.bak 's/port="8080"/port="8081"/' /opt/fedora/tomcat/conf/server.xml

  # # Start Fedora up for the first time (which sets up various files and directories)
  /opt/fedora/tomcat/bin/catalina.sh start

  # Give Fedora some time to start up and create various first-time startup files
  # We're waiting until we get a 200 status (with maximum timeout wait time)
  timeout 30s bash -c 'until curl --output /dev/null --silent --head --fail http://localhost:8081/fedora/; do sleep 1; done'

  # Stop Fedora so that we can apply some overrides
  /opt/fedora/tomcat/bin/catalina.sh stop

  # Give Fedora some time to stop (with maximum timeout wait time)
  timeout 30s bash -c 'while pgrep "java" > /dev/null; do sleep 1; done'

  # Revert server.xml change so that Fedora will run on port 8080 the next time we start it up.
  rm /opt/fedora/tomcat/conf/server.xml
  mv /opt/fedora/tomcat/conf/server.xml.bak /opt/fedora/tomcat/conf/server.xml

  echo "Overriding Fedora 3 libraries"
  rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
  rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpcore-4*.jar
  rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/httpclient-4*.jar
  cp /opt/jars/apache-http/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
  rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/s3-url-protocol-*.jar
  cp /opt/jars/cul/s3-url-protocol-*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
  cp /opt/jars/awssdk/*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
  rm /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/fcrepo3-s3-server-*.jar
  cp /opt/jars/cul/fcrepo3-s3-server-*.jar /opt/fedora/tomcat/webapps/fedora/WEB-INF/lib/
  echo "Done overriding Fedora 3 libraries; setting new FCFG config"
  cp /opt/fedora.delegating-external.fcfg /opt/fedora/server/config/fedora.fcfg

  # NOTE: The /opt/fedora/data/fedora-xacml-policies/repository-policies/ directory and the default content
  # inside of it doesn't exist immediately after Fedora installation. This content is created only after
  # Fedora starts up for the first time.
  cp /opt/permit-all-s3-resolution.xml /opt/fedora/data/fedora-xacml-policies/repository-policies/default/permit-all-s3-resolution.xml
  cp /opt/deny-unallowed-file-resolution.xml /opt/fedora/data/fedora-xacml-policies/repository-policies/default/deny-unallowed-file-resolution.xml
fi

# Start Fedora in the foreground
/opt/fedora/tomcat/bin/catalina.sh run
