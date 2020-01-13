import React from 'react';
import PropTypes from 'prop-types';
import { Nav } from 'react-bootstrap';

function Tabs(props) {
  const { children } = props;

  return (
    <Nav fill variant="tabs" className="mb-2">
      {children}
    </Nav>
  );
}

Tabs.propTypes = {
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
};

export default Tabs;
