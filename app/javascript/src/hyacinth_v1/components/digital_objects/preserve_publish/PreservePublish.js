import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useMutation, useQuery } from '@apollo/react-hooks';

import { Form } from 'react-bootstrap';
import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import {
  getPreservePublishDigitalObjectQuery, preserveDigitalObjectMutation, publishDigitalObjectMutation,
} from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { digitalObjectAbility } from '../../../utils/ability';
import PublishTargetSelector from './PublishTargetSelector';
import ProgressButton from '../../shared/forms/buttons/ProgressButton';
import UserErrorsList from '../../shared/UserErrorsList';
import ReadableDate from '../../shared/ReadableDate';

function PreservePublish(props) {
  const { id } = props;

  const [publishDigitalObject, { error: publishDigitalObjectError }] = useMutation(publishDigitalObjectMutation);
  const [preserveDigitalObject, { error: preserveDigitalObjectError }] = useMutation(preserveDigitalObjectMutation);
  const [publishOperationSelections, setPublishOperationSelections] = useState({});
  const [userErrors, setUserErrors] = useState([]);

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
    refetch: refetchDigitalObject,
  } = useQuery(getPreservePublishDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  const canPublishObject = digitalObjectAbility.can(
    'publish_objects', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects },
  );

  const performPreserveAndPublish = () => {
    setUserErrors([]);
    const publishTo = publishOperationSelections.publish || [];
    const unpublishFrom = publishOperationSelections.unpublish || [];

    if (publishTo.length + unpublishFrom.length === 0) {
      return Promise.resolve();
    }
    return new Promise((resolve, reject) => {
      preserveDigitalObject({ variables: { input: { id: digitalObject.id } } }).then((preserveResult) => {
        if (preserveResult.data.preserveDigitalObject.userErrors?.length) {
          setUserErrors(preserveResult.data.preserveDigitalObject.userErrors);
          reject(new Error('An error occurred during preservation.'));
          return;
        }
        publishDigitalObject({ variables: { input: { id: digitalObject.id, publishTo, unpublishFrom } } }).then((publishResult) => {
          if (publishResult.data.publishDigitalObject.userErrors?.length) {
            setUserErrors(publishResult.data.publishDigitalObject.userErrors);
            reject(new Error('An error occurred during publication.'));
            return;
          }
          setPublishOperationSelections({});
          refetchDigitalObject();
          resolve();
        });
      });
    });
  };

  const performPreserve = () => new Promise((resolve, reject) => {
    setUserErrors([]);
    preserveDigitalObject({ variables: { input: { id: digitalObject.id } } }).then((preserveResult) => {
      if (preserveResult.data.preserveDigitalObject.userErrors?.length) {
        setUserErrors(preserveResult.data.preserveDigitalObject.userErrors);
        reject(new Error('An error occurred during preservation.'));
        return;
      }
      refetchDigitalObject();
      resolve();
    });
  });

  const lastPublishedAt = digitalObject.publishEntries.length
    ? digitalObject.publishEntries.map((publishEntry) => publishEntry.publishedAt).sort().at(-1)
    : null;

  const renderPreservePublishContent = () => (
    <>
      <div className="text-right mb-3">
        {
          canPublishObject
            ? (
              <Form>
                <PublishTargetSelector
                  className="mb-1"
                  digitalObjectId={digitalObject.id}
                  availablePublishTargets={digitalObject.availablePublishTargets}
                  currentPublishEntries={digitalObject.publishEntries}
                  publishOperationSelections={publishOperationSelections}
                  onChange={(selections) => { setPublishOperationSelections(selections); }}
                />
                <div className="d-flex align-items-center">
                  <span className="last-published ms-auto text-muted">
                    {
                      lastPublishedAt
                        ? (
                          <>
                            Last published -
                            {' '}
                            <ReadableDate isoDate={lastPublishedAt} />
                          </>
                        )
                        : 'Not published'
                    }
                  </span>
                  <ProgressButton
                    label="Run Publish / Unpublish Operations"
                    type="submit"
                    loadingLabel="Running publish / unpublish operations..."
                    className="ms-3"
                    onClick={performPreserveAndPublish}
                  />
                </div>
                <div className="d-flex align-items-center pt-1">
                  <span className="last-preserved ms-auto text-muted">
                    {
                      digitalObject.preservedAt
                        ? (
                          <>
                            Last preserved -
                            {' '}
                            <ReadableDate isoDate={digitalObject.preservedAt} />
                          </>
                        )
                        : 'Not preserved'
                    }
                  </span>
                  <ProgressButton
                    label="Preserve Only"
                    type="submit"
                    loadingLabel="Preserving..."
                    className="ms-3"
                    onClick={performPreserve}
                  />
                </div>
              </Form>
            )
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
      <GraphQLErrors errors={publishDigitalObjectError || preserveDigitalObjectError} />
      <UserErrorsList userErrors={userErrors} />
      {renderPreservePublishContent()}
    </DigitalObjectInterface>
  );
}

export default PreservePublish;

PreservePublish.propTypes = {
  id: PropTypes.string.isRequired,
};
