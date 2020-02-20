import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Navbar, NavDropdown } from 'react-bootstrap';

const DigitalObjectFacets = (props) => {
  const { facets } = props;

  return (
    <Navbar key="digital-object-facets" className="flex-column">
      <Navbar.Brand>Facets</Navbar.Brand>
      <Nav className="mr-auto">
        {
          facets.map(facet => (
            <NavDropdown title={facet.displayLabel}>
              <DigitalObjectFacetValues values={facet.values} />
            </NavDropdown>
          ))
        }
      </Nav>
    </Navbar>
  );
};

const DigitalObjectFacetValues = (props) => {
  const { values } = props;
  return (
    <>
      {
        values.map((value) => {
          const displayText = `${value.value} (${value.count})`;
          return <NavDropdown.Item href="">{displayText}</NavDropdown.Item>;
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
