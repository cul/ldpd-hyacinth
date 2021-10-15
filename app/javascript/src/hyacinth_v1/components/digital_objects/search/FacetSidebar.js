import React from 'react';
import PropTypes from 'prop-types';

import FacetDropdown from './facet_sidebar/FacetDropdown';

// All the Facet components can eventually be moved to the shared folder
// because we expect that they will be used elsewhere.
const FacetSidebar = (props) => {
  const { facets, onFacetSelect, selectedFacets } = props;

  const selectedValuesFor = (fieldName) => (
    selectedFacets.filter((f) => f.field === fieldName).flatMap((f) => f.values)
  );

  return (
    <>
      <h4>Refine Your Search</h4>
      {
        facets.map((facet) => (
          <FacetDropdown
            key={facet.fieldName}
            facet={facet}
            selectedValues={selectedValuesFor(facet.fieldName)}
            onFacetSelect={onFacetSelect}
          />
        ))
      }
    </>
  );
};

FacetSidebar.propTypes = {
  facets: PropTypes.arrayOf(PropTypes.object).isRequired,
  onFacetSelect: PropTypes.func.isRequired,
  selectedFacets: PropTypes.arrayOf(
    PropTypes.shape({
      field: PropTypes.string.isRequired,
      values: PropTypes.arrayOf(PropTypes.string).isRequired,
    }),
  ).isRequired,
};

export default FacetSidebar;
