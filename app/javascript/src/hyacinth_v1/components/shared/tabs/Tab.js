import React from 'react';
import PropTypes from 'prop-types';
import { Nav } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { Route } from 'react-router-dom';

function Tab(props) {
  const { name, ...rest } = props;

  return (
    <Route
      {...rest}
      children={() => (
        <Nav.Item key={name} style={{ fontWeight: '500', fontSize: '1.05rem' }}>
          <LinkContainer activeClassName="active" {...rest}>
            <Nav.Link eventKey={name}>
              {name}
            </Nav.Link>
          </LinkContainer>
        </Nav.Item>
      )}
    />
  );
}

Tab.propTypes = {
  name: PropTypes.string.isRequired,
};

export default Tab;
