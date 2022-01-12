import React from 'react';
import PropTypes from 'prop-types';
import FacetOption from './FacetOption';

const FacetOptions = (props) => {
  const {
    values, fieldName, onFacetSelect, selectedValues,
  } = props;

  const options = values.map((value) => (
    <FacetOption
      key={`option_${fieldName}_${value.value}`}
      value={value.value}
      count={value.count}
      selected={selectedValues.includes(value.value)}
      onSelect={() => onFacetSelect(fieldName, value.value)}
    />
  ));
  return options;
};

FacetOptions.propTypes = {
  values: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      count: PropTypes.number.isRequired,
    }),
  ).isRequired,
  fieldName: PropTypes.string.isRequired,
  onFacetSelect: PropTypes.func.isRequired,
};

export default FacetOptions;
