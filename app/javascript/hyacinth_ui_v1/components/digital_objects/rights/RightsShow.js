import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../ui/GraphQLErrors';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import RightsTab from './RightsTab';
import { digitalObjectAbility } from '../../../util/ability';

function RightsShow(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getRightsDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;
  const { rights } = digitalObject;

  const canEdit = digitalObjectAbility.can('assess_rights', { primaryProject: digitalObject.primaryProject, otherProjects: digitalObject.otherProjects });

  return (
    <RightsTab digitalObject={digitalObject} editButton={canEdit}>
      <div className="card">
        <div className="card-body">
          <pre><code>{ JSON.stringify(rights, null, 2) }</code></pre>
        </div>
      </div>
    </RightsTab>
  );
}

export default RightsShow;

RightsShow.propTypes = {
  id: PropTypes.string.isRequired,
};
