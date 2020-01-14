import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../ui/GraphQLErrors';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import RightsTab from './RightsTab';

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

  return (
    <RightsTab digitalObject={digitalObject} editButton>
      <div className="card">
        <div className="card-body">
          <code>{ JSON.stringify(rights) }</code>
        </div>
      </div>
    </RightsTab>
  );
}

export default RightsShow;

RightsShow.propTypes = {
  id: PropTypes.string.isRequired,
};
