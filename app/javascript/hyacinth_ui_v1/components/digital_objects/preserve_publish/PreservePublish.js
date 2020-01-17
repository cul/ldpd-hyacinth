import React from 'react';
import PropTypes from 'prop-types';
import { Button, Alert } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import { getPreservePublishDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';

function PreservePublish(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getPreservePublishDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Preserve / Publish
      </TabHeading>

      <Alert variant="info">
        <strong>Preserve: </strong>
        Write the latest data for this digital object to the preservation repository.
      </Alert>

      <div className="text-right mb-3">
        <Button>Preserve</Button>
      </div>

      <Alert variant="info">
        <strong>Preserve &amp; Publish: </strong>
        Performs a preserve operation
        <strong> AND </strong>
        publishes the latest data for this digital object to all enabled publish targets.
      </Alert>

      <div className="text-right mb-3">
        <Button>Preserve &amp; Publish</Button>
      </div>
    </DigitalObjectInterface>
  );
};

export default PreservePublish;

PreservePublish.propTypes = {
  id: PropTypes.string.isRequired,
};
