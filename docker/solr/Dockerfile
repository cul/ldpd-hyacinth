FROM solr:8.11.2

WORKDIR /data

COPY ./setup-and-start.sh .

COPY --chown=solr:solr './solr_cores/hyacinth-solr-8' /template-cores/hyacinth
RUN echo 'name=hyacinth' > /template-cores/hyacinth/core.properties

COPY --chown=solr:solr './solr_cores/terms-solr-8' /template-cores/terms
RUN echo 'name=terms' > /template-cores/terms/core.properties

CMD /bin/bash ./setup-and-start.sh
