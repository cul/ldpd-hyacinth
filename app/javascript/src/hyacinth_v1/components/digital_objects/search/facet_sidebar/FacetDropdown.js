import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Collapse, Button } from 'react-bootstrap';

import FacetOptions from './FacetOptions';
import FacetSlideOut from './FacetSlideOut';
import FontAwesomeIcon from '../../../../utils/lazyFontAwesome';

const FacetDropdown = ({ facet, onFacetSelect, selectedValues }) => {
  const [open, setOpen] = useState(selectedValues.length > 0);
  // Facet shouldn't be displayed if there aren't any values to select.
  if (facet.values.length === 0) return <></>;
  return (
    <div className="border-bottom border-secondary">
      <Button className="px-0 w-100" variant="link" onClick={() => setOpen(o => !o)}>
        <span className="float-start">{facet.displayLabel}</span>
        <span className="float-end"><FontAwesomeIcon size="lg" icon={open ? 'caret-up' : 'caret-down'} /></span>
      </Button>
      <Collapse in={open}>
        <div>
          <FacetOptions
            values={facet.values}
            fieldName={facet.fieldName}
            onFacetSelect={onFacetSelect}
            selectedValues={selectedValues}
          />
          <FacetSlideOut
            values={facet.values}
            hasMore={facet.hasMore}
            fieldName={facet.fieldName}
            onFacetSelect={onFacetSelect}
            selectedValues={selectedValues}
            displayLabel={facet.displayLabel}
          />
        </div>
      </Collapse>
    </div>
  );
};

FacetDropdown.propTypes = {
  facet: PropTypes.shape({
    values: PropTypes.arrayOf(PropTypes.object).isRequired,
    fieldName: PropTypes.string.isRequired,
    displayLabel: PropTypes.string.isRequired,
    hasMore: PropTypes.bool.isRequired,
  }).isRequired,
  selectedValues: PropTypes.arrayOf(PropTypes.string).isRequired,
  onFacetSelect: PropTypes.func.isRequired,
};

export default FacetDropdown;
