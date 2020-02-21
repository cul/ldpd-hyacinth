import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../shared/GraphQLErrors';
import RightsTab from './RightsTab';
import AssetRightsForm from './rights_form/AssetRightsForm';
import ItemRightsForm from './rights_form/ItemRightsForm';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';

function RightsEdit(props) {
  const { id } = props;

  const { loading, error, data } = useQuery(getRightsDigitalObjectQuery, {
    variables: { id },
  });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObject, digitalObject: { digitalObjectType } } = data;

  const renderTabContent = () => {
    switch (digitalObjectType) {
      case 'item':
        return <ItemRightsForm digitalObject={digitalObject} />;
      case 'asset':
        return <AssetRightsForm digitalObject={digitalObject} />;
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
