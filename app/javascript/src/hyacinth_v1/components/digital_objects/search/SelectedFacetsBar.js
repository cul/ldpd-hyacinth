import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const SelectedFacetsBar = (props) => {
  const { facets, selectedFacets, onRemoveFacet } = props;

  const displayLabelFor = facet => facets.find(f => f.fieldName === facet).displayLabel;

  return (
    <div className="py-3">
      {
        selectedFacets.flatMap(
          ({ field, values }) => (
            values.map(
              (value) => (
                <Button key={`${field}_${value}`} className="rounded mx-1" size="sm" variant="secondary" onClick={() => onRemoveFacet(field, value)}>
                  {`${displayLabelFor(field)} > ${value} `}
                  <FontAwesomeIcon icon="times" />
                </Button>
              )
            )
          )
        )
      }
    </div>
  );
};

SelectedFacetsBar.propTypes = {
  facets: PropTypes.arrayOf(PropTypes.object).isRequired,
  selectedFacets: PropTypes.arrayOf(
    PropTypes.shape({
      field: PropTypes.string.isRequired,
      values: PropTypes.arrayOf(PropTypes.string).isRequired,
    }),
  ).isRequired,
  onRemoveFacet: PropTypes.func.isRequired,
};

export default SelectedFacetsBar;
