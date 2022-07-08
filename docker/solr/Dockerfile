FROM solr:6.3.0

WORKDIR /data

# Set up template cores in image

COPY --chown=solr:solr './solr_cores/hyacinth-solr-6-3' /template-cores/hyacinth-development
RUN echo 'name=hyacinth-development' > /template-cores/hyacinth-development/core.properties

COPY --chown=solr:solr './solr_cores/terms-solr-6'  /template-cores/terms-development
RUN echo 'name=terms-development' > /template-cores/terms-development/core.properties

# When image runs, the command below will copy template cores to final location (on mounted docker
#  volume) if they don't already exist, and then will start solr.

CMD [ ! -d /opt/solr/server/solr/hyacinth-development ] && cp -pr /template-cores/hyacinth-development /data/hyacinth-development && \
    ln -s /data/hyacinth-development /opt/solr/server/solr/hyacinth-development && \
    [ ! -d /opt/solr/server/solr/terms-development ] && cp -pr /template-cores/terms-development /data/terms-development && \
    ln -s /data/terms-development /opt/solr/server/solr/terms-development && \
    solr-foreground
