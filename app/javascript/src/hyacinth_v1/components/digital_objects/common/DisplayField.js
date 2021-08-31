import React from 'react';
import PropTypes from 'prop-types';
import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import PlainText from '../../shared/forms/inputs/PlainText';

const randomId = (prefix) => `${prefix}${Math.random()}`.replace('.','');

function DisplayField(props) {
  const {
    data,
    dynamicField: {
      stringKey, displayLabel, fieldType, selectOptions,
    },
  } = props;

  const inputName = randomId(stringKey);
  let value = null;

  switch (fieldType) {
    case 'controlled_term':
      value = data.pref_label || data.prefLabel;
      break;
    case 'select':
      value = JSON.parse(selectOptions).find(o => o.value === data).label;
      break;
    case 'language_tag':
      value = data.tag;
      break;
    default:
      value = data.toString();
  }

  return (
    <InputGroup key={stringKey}>
      <Label sm={4} align="right" htmlFor={inputName}>{displayLabel}</Label>
      <PlainText sm={8} value={value} inputName={inputName} />
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
