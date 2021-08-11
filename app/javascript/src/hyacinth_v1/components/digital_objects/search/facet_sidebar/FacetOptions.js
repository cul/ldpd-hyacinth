import React from 'react';
import PropTypes from 'prop-types';
import { Badge, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const FacetOptions = (props) => {
  const {
    values, fieldName, onFacetSelect, selectedValues,
  } = props;

  return values.map(value => (
    <FacetOption
      key={`option_${fieldName}_${value.value}`}
      value={value.value}
      count={value.count}
      selected={selectedValues.includes(value.value)}
      onSelect={() => onFacetSelect(fieldName, value.value)}
    />
  ));
};

const FacetOption = (props) => {
  const {
    value, count, selected, onSelect,
  } = props;

  return (
    selected ? (
      <div>
        <span className="pl-3">{value}</span>
        &nbsp;
        <Button className="px-1" variant="link" size="sm" onClick={onSelect}>
          <FontAwesomeIcon size="sm" icon="times" />
        </Button>
      </div>
    ) : (
      <div>
        <Button className="pt-0 pb-1 pl-3 pr-1 text-start" variant="link" onClick={onSelect}>
          {value}
        </Button>
        <Badge pill variant="secondary">{count}</Badge>
      </div>
    )
  );
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

FacetOption.propTypes = {
  value: PropTypes.string.isRequired,
  count: PropTypes.number.isRequired,
  selected: PropTypes.bool.isRequired,
  onSelect: PropTypes.func.isRequired,
};

export default FacetOptions;
