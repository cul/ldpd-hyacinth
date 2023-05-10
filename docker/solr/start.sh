#!/bin/bash

# Set up symlinks if they don't exist. Runs whenever the container image is rebuilt.
[ ! -L /opt/solr/server/solr/hyacinth ] && ln -s /data/hyacinth /opt/solr/server/solr/hyacinth
[ ! -L /opt/solr/server/solr/hyacinth_hydra ] && ln -s /data/hyacinth_hydra /opt/solr/server/solr/hyacinth_hydra
[ ! -L /opt/solr/server/solr/uri_service ] && ln -s /data/uri_service /opt/solr/server/solr/uri_service

# Copy cores if they don't exist. Runs whenever the volume is re-created.
[ ! -d /data/hyacinth ] && cp -pr /template-cores/hyacinth /data/hyacinth
[ ! -d /data/hyacinth_hydra ] && cp -pr /template-cores/hyacinth_hydra /data/hyacinth_hydra
[ ! -d /data/uri_service ] && cp -pr /template-cores/uri_service /data/uri_service

# Start solr

solr-foreground
