import React from 'react';
import PropTypes from 'prop-types';
import MetadataForm from './MetadataForm';
import DigitalObjectInterface from '../NewDigitalObjectInterface';

function MetadataEdit(props) {
  const { digitalObject } = props;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <MetadataForm formType="edit" digitalObject={digitalObject} />
    </DigitalObjectInterface>
  );
}

export default MetadataEdit;

MetadataEdit.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
};
