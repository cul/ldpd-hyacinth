import React from 'react';
import PropTypes from 'prop-types';
import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, Card } from 'react-bootstrap';

import prettyBytes from 'pretty-bytes';
import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getAssetDataDigitalObjectQuery, deleteResourceMutation } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

function AssetData(props) {
  const { id } = props;
  const [deleteResource] = useMutation(deleteResourceMutation);

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
    refetch: digitalObjectRefetch,
  } = useQuery(getAssetDataDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  const onDeleteResource = (digitalObjectId, resourceName) => {
    // eslint-disable-next-line no-alert
    if (window.confirm(`Are you sure you want to delete the ${resourceName} resource? This cannot be undone.`)) {
      deleteResource(
        {
          variables: {
            input: {
              id: digitalObjectId,
              resourceName,
            },
          },
          update: digitalObjectRefetch,
        },
      );
    }
  };

  const renderResources = (resources) => resources.map((resourceWrapper) => {
    const {
      id: resourceId, displayLabel, resource, uiDeletable,
    } = resourceWrapper;
    // location, checksum, originalFilename, mediaType, fileSize,
    return (
      <Card key={resourceId}>
        <Card.Header>{displayLabel}</Card.Header>
        <Card.Body>
          {resource
            ? (
              <dl className="row">
                <dt className="col-lg-3">Download</dt>
                <dd className="col-lg-9">
                  <FontAwesomeIcon icon="download" />
                  {' '}
                  <a href={`/api/v1/downloads/digital_object/${id}/${resourceId}`}>
                    {` ${resource.originalFilename}`}
                  </a>
                </dd>

                <dt className="col-lg-3">Original Filename</dt>
                <dd className="col-lg-9">{resource.originalFilename}</dd>

                <dt className="col-lg-3">Original File Path</dt>
                <dd className="col-lg-9">{resource.originalFilePath}</dd>

                <dt className="col-lg-3">Location</dt>
                <dd className="col-lg-9">{resource.location}</dd>

                <dt className="col-lg-3">Checksum</dt>
                <dd className="col-lg-9">{resource.checksum || 'unavailable'}</dd>

                <dt className="col-lg-3">Media Type</dt>
                <dd className="col-lg-9">{resource.mediaType}</dd>

                <dt className="col-lg-3">File Size</dt>
                <dd className="col-lg-9">
                  {
                    (resource.fileSize || resource.fileSize === 0)
                      ? `${prettyBytes(resource.fileSize)} (${resource.fileSize} bytes)` : 'unavailable'
                  }
                </dd>

                {uiDeletable && (
                  <>
                    <dt className="col-lg-3">Delete Resource</dt>
                    <dd className="col-lg-9">
                      <Button variant="danger" size="sm" onClick={() => { onDeleteResource(digitalObject.id, resourceId); }}>Delete</Button>
                    </dd>
                  </>
                )}
              </dl>
            )
            : 'None'}
        </Card.Body>
      </Card>
    );
  });

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Asset Data
      </TabHeading>
      <h5>Asset Type</h5>
      <p>{digitalObject.assetType}</p>
      <h5>Featured Thumbnail Region</h5>
      <p>{digitalObject.featuredThumbnailRegion || 'None'}</p>
      <h5 className="mt-3">Resources</h5>
      {renderResources(digitalObject.resources)}
    </DigitalObjectInterface>
  );
}

export default AssetData;

AssetData.propTypes = {
  id: PropTypes.string.isRequired,
};
