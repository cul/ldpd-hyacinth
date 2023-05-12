FROM solr:6.3.0

WORKDIR /data

# Set up template cores in image

COPY ./start.sh .

COPY --chown=solr:solr './solr_cores/hyacinth-solr-6-3' /template-cores/hyacinth
RUN echo 'name=hyacinth' > /template-cores/hyacinth/core.properties

COPY --chown=solr:solr './solr_cores/hyacinth-hydra-solr-6-3' /template-cores/hyacinth_hydra
RUN echo 'name=hyacinth_hydra' > /template-cores/hyacinth_hydra/core.properties

COPY --chown=solr:solr './solr_cores/uri-service-solr-6-3' /template-cores/uri_service
RUN echo 'name=uri_service' > /template-cores/uri_service/core.properties

# When image runs, the command below will copy template cores to final location (on mounted docker
#  volume) if they don't already exist, and then will start solr.

CMD /bin/bash ./start.sh
