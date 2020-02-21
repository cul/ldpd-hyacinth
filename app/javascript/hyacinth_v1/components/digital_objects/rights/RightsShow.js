import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../shared/GraphQLErrors';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import RightsTab from './RightsTab';
import { digitalObjectAbility } from '../../../utils/ability';
import { removeTypename } from '../../../utils/deepKeyRemove';

function RightsShow(props) {
  const { id } = props;

  const { loading, error, data } = useQuery(getRightsDigitalObjectQuery, {
    variables: { id },
  });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObject, digitalObject: { primaryProject, otherProjects, rights } } = data;

  const canEdit = digitalObjectAbility.can('assess_rights', { primaryProject, otherProjects });

  return (
    <RightsTab digitalObject={digitalObject} editButton={canEdit}>
      <div className="card">
        <div className="card-body">
          <pre><code>{ JSON.stringify(removeTypename(rights), null, 2) }</code></pre>
        </div>
      </div>
    </RightsTab>
  );
}

export default RightsShow;

RightsShow.propTypes = {
  id: PropTypes.string.isRequired,
};
