#!/bin/bash

# Set up symlinks if they don't exist.  The conditional checks ensure that this only runs if
# the volume is re-created.
[ ! -L /var/solr/hyacinth ] && ln -s /data/hyacinth /var/solr/hyacinth
[ ! -L /var/solr/terms ] && ln -s /data/terms /var/solr/terms

precreate-core hyacinth /template-cores/hyacinth
precreate-core hyacinth_hydra /template-cores/hyacinth_hydra
precreate-core terms /template-cores/terms

# Start solr
solr-foreground
