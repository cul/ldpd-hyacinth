import React from 'react';
import PropTypes from 'prop-types';
import { Col, Row } from 'react-bootstrap';
import InputGroup from '../../shared/forms/InputGroup';
import Label from '../../shared/forms/Label';
import PlainText from '../../shared/forms/inputs/PlainText';

let uniqueDisplayFieldIdCounter = 0;

function DisplayField({ data, dynamicField }) {
  const {
    stringKey, displayLabel, fieldType, selectOptions,
  } = dynamicField;

  const inputName = `${stringKey}-${uniqueDisplayFieldIdCounter += 1}`;
  let value = null;

  switch (fieldType) {
    case 'controlled_term':
      value = data.pref_label || data.prefLabel;
      break;
    case 'select':
      value = JSON.parse(selectOptions).find((o) => o.value === data).label;
      break;
    case 'language_tag':
      value = data.tag;
      break;
    default:
      value = data.toString();
  }

  return (
    <Row data-dynamic-field-string-key={stringKey} style={{ whiteSpace: 'pre-wrap' }}>
      <Col sm={4} className="field-label">{displayLabel}</Col>
      <Col sm={8} className="field-value">{value}</Col>
    </Row>
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
