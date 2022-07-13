FROM solr:6.3.0

WORKDIR /data

# Set up template cores in image

COPY --chown=solr:solr './solr_cores/hyacinth-solr-6-3' /template-cores/hyacinth
RUN echo 'name=hyacinth' > /template-cores/hyacinth/core.properties

COPY --chown=solr:solr './solr_cores/terms-solr-6'  /template-cores/terms
RUN echo 'name=terms' > /template-cores/terms/core.properties

# When image runs, the command below will copy template cores to final location (on mounted docker
#  volume) if they don't already exist, and then will start solr.

CMD [ ! -d /opt/solr/server/solr/hyacinth ] && cp -pr /template-cores/hyacinth /data/hyacinth && \
    ln -s /data/hyacinth /opt/solr/server/solr/hyacinth && \
    [ ! -d /opt/solr/server/solr/terms ] && cp -pr /template-cores/terms /data/terms && \
    ln -s /data/terms /opt/solr/server/solr/terms && \
    solr-foreground
