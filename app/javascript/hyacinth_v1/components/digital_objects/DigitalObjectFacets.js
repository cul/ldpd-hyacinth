import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Navbar } from 'react-bootstrap';

const DigitalObjectFacets = (props) => {
  const { facets } = props;

  return (
    <>
      {
        facets.map(facet => (
          <Navbar key={facet.fieldName} className="flex-column">
            <Navbar.Brand>{facet.displayLabel}</Navbar.Brand>
            <DigitalObjectFacetValues values={facet.values} />
          </Navbar>
        ))
      }
    </>
  );
};

const DigitalObjectFacetValues = (props) => {
  const { values } = props;
  return (
    <>
      {
        values.map((value) => {
          const displayText = `${value.value} (${value.count})`;
          return <Nav>{displayText}</Nav>;
        })
      }
    </>
  );
};

DigitalObjectFacets.propTypes = {
  facets: PropTypes.arrayOf(PropTypes.object).isRequired,
};

DigitalObjectFacetValues.propTypes = {
  values: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      count: PropTypes.number.isRequired,
    }),
  ).isRequired,
};

export default DigitalObjectFacets;
