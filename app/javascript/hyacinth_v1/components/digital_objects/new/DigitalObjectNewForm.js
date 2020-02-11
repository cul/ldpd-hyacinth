import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';
import { capitalize } from 'lodash';

import ContextualNavbar from '../../shared/ContextualNavbar';
import { Can } from '../../../utils/ability_context';
import { getProjectQuery } from '../../../graphql/projects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import MetadataForm from '../metadata/MetadataForm';
import DigitalObjectSummary from '../DigitalObjectSummary';

function DigitalObjectNewForm() {
  const { projectStringKey, digitalObjectType } = useParams();

  // Retrieve data and set data
  const { loading: projectLoading, error: projectError, data: projectData } = useQuery(
    getProjectQuery, { variables: { stringKey: projectStringKey } },
  );

  if (projectLoading) return (<></>);
  if (projectError) return (<GraphQLErrors errors={projectError} />);
  const { project: { stringKey, displayLabel } } = projectData;

  const initialDigitalObject = {
    serializationVersion: '1',
    digitalObjectType,
    primaryProject: { stringKey, displayLabel },
    otherProjects: [],
    dynamicFieldData: {},
    identifiers: [],
  };

  return (
    <>
      <ContextualNavbar
        title={`New ${capitalize(initialDigitalObject.digitalObjectType)}`}
        rightHandLinks={[{ link: '/digital_objects', label: 'Back to Digital Objects' }]}
      />
      <DigitalObjectSummary digitalObject={initialDigitalObject} />
      <MetadataForm formType="new" digitalObject={initialDigitalObject} />
    </>
  );
}

export default DigitalObjectNewForm;
