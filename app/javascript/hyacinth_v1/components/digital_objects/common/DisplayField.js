import React from 'react';
import PropTypes from 'prop-types';
import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import PlainText from '../../shared/forms/inputs/PlainText';

function DisplayField(props) {
  const {
    data,
    dynamicField: {
      stringKey, displayLabel, fieldType, selectOptions,
    },
  } = props;

  let value = null;

  switch (fieldType) {
    case 'controlled_term':
      value = data.pref_label || data.prefLabel;
      break;
    case 'select':
      value = JSON.parse(selectOptions).find(o => o.value === data).label;
      break;
    default:
      value = data.toString();
  }

  return (
    <InputGroup key={stringKey}>
      <Label sm={4} align="right">{displayLabel}</Label>
      <PlainText sm={8} value={value} />
    </InputGroup>
  );
}

DisplayField.propTypes = {
  dynamicField: PropTypes.shape({
    stringKey: PropTypes.string.isRequired,
    displayLabel: PropTypes.string.isRequired,
    fieldType: PropTypes.string.isRequired,
  }).isRequired,
};

export default DisplayField;
