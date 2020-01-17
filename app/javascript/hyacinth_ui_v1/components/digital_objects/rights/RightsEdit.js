import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../ui/GraphQLErrors';
import RightsTab from './RightsTab';
import ItemRightsForm from './rights_form/ItemRightsForm';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';

function RightsEdit(props) {
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
  const { digitalObjectType } = digitalObject;

  const renderTabContent = () => {
    switch (digitalObjectType) {
      case 'item':
        return <ItemRightsForm digitalObject={digitalObject} />;
      default:
        return `Rights form view is not supported for digital object type: ${digitalObjectType}`;
    }
  };

  return (
    <RightsTab digitalObject={digitalObject}>
      { renderTabContent() }
    </RightsTab>
  );
}

export default RightsEdit;

RightsEdit.propTypes = {
  id: PropTypes.string.isRequired,
};
