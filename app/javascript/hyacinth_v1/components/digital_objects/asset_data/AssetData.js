import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import { Card } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getAssetDataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';

function AssetData(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getAssetDataDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  const renderResources = () => {
    return digitalObject.resources.map((resource) => {
      const {
        id: resourceId, displayLabel, location, checksum, originalFilename, mediaType, fileSize
      } = resource;
      return (
        <Card key={resourceId}>
          <Card.Header>{displayLabel}</Card.Header>
          <Card.Body>
            { location ?
              (
                <dl className="row">
                  <dt className="col-lg-3">Download</dt>
                  <dd className="col-lg-9">
                    <FontAwesomeIcon icon="download" />
                    {' '}
                    <a href={`/api/v1/digital_objects/${id}/resources/${resourceId}/download`}>
                      {` ${originalFilename}`}
                    </a>
                  </dd>

                  <dt className="col-lg-3">Original Filename</dt>
                  <dd className="col-lg-9">{originalFilename}</dd>

                  <dt className="col-lg-3">Location</dt>
                  <dd className="col-lg-9">{location}</dd>

                  <dt className="col-lg-3">Checksum</dt>
                  <dd className="col-lg-9">{checksum || 'unavailable'}</dd>

                  <dt className="col-lg-3">Media Type</dt>
                  <dd className="col-lg-9">{mediaType}</dd>

                  <dt className="col-lg-3">File Size</dt>
                  <dd className="col-lg-9">{fileSize || 'unavailable'}</dd>
                </dl>
              )
              : 'None'
            }
          </Card.Body>
        </Card>
      );
    });
  };

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Asset Data
      </TabHeading>
      <h5>Asset Type</h5>
      {digitalObject.assetType}
      <h5 className="mt-3">Resources</h5>
      { renderResources() }
    </DigitalObjectInterface>
  );
}

export default AssetData;

AssetData.propTypes = {
  id: PropTypes.string.isRequired,
};
