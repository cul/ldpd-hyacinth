import React from 'react';
import PropTypes from 'prop-types';
import { Button, Alert } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import { getPreservePublishDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';
import { digitalObjectAbility } from '../../../util/ability';

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

  const canUpdateObject = digitalObjectAbility.can('update_objects', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects });
  const canPublishObject = digitalObjectAbility.can('publish_objects', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects });

  const renderPreservePublishContent = () => (
    <>
      <Alert variant="info">
        <strong>Preserve: </strong>
        Write the latest data for this digital object to the preservation repository.
      </Alert>

      <div className="text-right mb-3">
        {
          canUpdateObject
            ? <Button>Preserve</Button>
            : <span>You do not have permission to preserve this Digital Object.</span>
        }
      </div>

      <Alert variant="info">
        <strong>Preserve &amp; Publish: </strong>
        Performs a preserve operation
        <strong> AND </strong>
        publishes the latest data for this digital object to all enabled publish targets.
      </Alert>

      <div className="text-right mb-3">
        {
          canUpdateObject && canPublishObject
            ? <Button>Preserve &amp; Publish</Button>
            : <span>You do not have permission to preserve and publish this Digital Object.</span>
        }
      </div>
    </>
  );

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>
        Preserve / Publish
      </TabHeading>
      { renderPreservePublishContent() }
    </DigitalObjectInterface>
  );
}

export default PreservePublish;

PreservePublish.propTypes = {
  id: PropTypes.string.isRequired,
};
