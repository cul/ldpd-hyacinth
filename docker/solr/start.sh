#!/bin/bash

# Set up symlinks if they don't exist.  The conditional checks ensure that this only runs if
# the volume is re-created.
[ ! -L /var/solr/hyacinth ] && ln -s /data/hyacinth /var/solr/hyacinth
[ ! -L /var/solr/hyacinth_hydra ] && ln -s /data/hyacinth_hydra /var/solr/hyacinth_hydra
[ ! -L /var/solr/uri_service ] && ln -s /data/uri_service /var/solr/uri_service

# Copy cores if they don't exist. The conditional checks ensure that this only runs if
# the volume is re-created.
#[ ! -d /data/hyacinth ] && cp -pr /template-cores/hyacinth /data/hyacinth
#[ ! -d /data/hyacinth_hydra ] && cp -pr /template-cores/hyacinth_hydra /data/hyacinth_hydra
#[ ! -d /data/uri_service ] && cp -pr /template-cores/uri_service /data/uri_service

precreate-core hyacinth /template-cores/hyacinth
precreate-core hyacinth_hydra /template-cores/hyacinth_hydra
precreate-core uri_service /template-cores/uri_service

# Start solr

solr-foreground
