import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import GraphQLErrors from '../../shared/GraphQLErrors';
import RightsTab from './RightsTab';
import AssetRightsForm from './rights_form/AssetRightsForm';
import ItemRightsForm from './rights_form/ItemRightsForm';
import { getRightsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import { rightsFieldsQuery } from '../../../graphql/rightsFields';

const flatShim = require('array.prototype.flat');

if (!Array.prototype.flat) flatShim.shim();

function RightsEdit(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getRightsDigitalObjectQuery, { variables: { id } });

  // Retrieve Rights Fields based on Digital Object Type
  const {
    loading: rightsFieldsLoading,
    error: rightsFieldsError,
    data: rightsFieldsData,
  } = useQuery(rightsFieldsQuery, {
    skip: !digitalObjectData,
    variables: { metadataForm: digitalObjectData && `${digitalObjectData.digitalObject.digitalObjectType}_RIGHTS` },
  });

  if (digitalObjectLoading || rightsFieldsLoading) return (<></>);
  if (digitalObjectError || rightsFieldsError) {
    return (<GraphQLErrors errors={digitalObjectError || rightsFieldsError} />);
  }

  const { digitalObject, digitalObject: { digitalObjectType, title } } = digitalObjectData;

  const dynamicFieldGroups = rightsFieldsData.dynamicFieldCategories.map((c) => c.children).flat();

  const renderTabContent = () => {
    switch (digitalObjectType) {
      case 'ITEM':
        return <ItemRightsForm digitalObject={digitalObject} title={title} fieldConfiguration={dynamicFieldGroups} />;
      case 'ASSET':
        return <AssetRightsForm digitalObject={digitalObject} fieldConfiguration={dynamicFieldGroups} />;
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
