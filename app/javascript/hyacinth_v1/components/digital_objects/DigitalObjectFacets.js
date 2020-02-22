import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Navbar, NavDropdown } from 'react-bootstrap';

const DigitalObjectFacets = (props) => {
  const { facets, isFacetCurrent, onFacetSelect } = props;

  return (
    <Navbar key="digital-object-facets" className="flex-column">
      <Navbar.Brand>Facets</Navbar.Brand>
      <Nav className="flex-column">
        {
          facets.map(facet => (
            <NavDropdown title={facet.displayLabel} key={`dropdown-${facet.fieldName}`}>
              <DigitalObjectFacetValues values={facet.values} fieldName={facet.fieldName} isFacetCurrent={isFacetCurrent} onFacetSelect={onFacetSelect} />
            </NavDropdown>
          ))
        }
      </Nav>
    </Navbar>
  );
};

const DigitalObjectFacetValues = (props) => {
  const { values, fieldName, isFacetCurrent, onFacetSelect } = props;
  return (
    <>
      {
        values.map((value) => {
          const onSelect = () => { onFacetSelect(fieldName, value.value); }
          const displayText = isFacetCurrent(fieldName, value.value) ? `${value.value} (remove)` : `${value.value} (${value.count})`;
          return <NavDropdown.Item key={`${fieldName}-${value.value}`} eventKey={`${fieldName}-${value.value}`} onSelect={onSelect}>{displayText}</NavDropdown.Item>;
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
