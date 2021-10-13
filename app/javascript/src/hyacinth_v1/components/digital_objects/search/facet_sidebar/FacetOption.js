import React from 'react';
import PropTypes from 'prop-types';
import { Badge, Button } from 'react-bootstrap';
import FontAwesomeIcon from '../../../../utils/lazyFontAwesome';

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
        <Badge pill bg="secondary">{count}</Badge>
      </div>
    )
  );
};

FacetOption.propTypes = {
  value: PropTypes.string.isRequired,
  count: PropTypes.number.isRequired,
  selected: PropTypes.bool.isRequired,
  onSelect: PropTypes.func.isRequired,
};

export default FacetOption;
