import React from 'react';
import PropTypes from 'prop-types';
import { Nav } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { Route } from 'react-router-dom';

class ProjectTab extends React.PureComponent {
  render() {
    const { name, ...rest } = this.props;

    return (
      <Route
        {...rest}
        children={() => (
          <Nav.Item key={name}>
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
}

ProjectTab.propTypes = {
  name: PropTypes.string.isRequired,
};

export default ProjectTab;
