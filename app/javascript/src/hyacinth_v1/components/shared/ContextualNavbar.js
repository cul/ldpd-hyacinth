import React from 'react';
import PropTypes from 'prop-types';
import { Nav, Navbar } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

class ContextualNavbar extends React.PureComponent {
  render() {
    const { title, rightHandLinks, children } = this.props;

    return (
      <Navbar variant="dark" bg="dark" expand="lg" className="px-3 py-0 mt-2 mb-2 rounded contextual-navbar">
        { title && <Navbar.Brand>{title}</Navbar.Brand> }
        <Nav className="ms-auto">
          {children}
          {
            rightHandLinks.map((obj, i) => (
              <Nav.Item as="li" key={i}>
                <LinkContainer exact to={obj.link}>
                  <Nav.Link>{obj.label}</Nav.Link>
                </LinkContainer>
              </Nav.Item>
            ))
          }
        </Nav>
      </Navbar>
    );
  }
}

ContextualNavbar.defaultProps = {
  rightHandLinks: [],
  children: null,
};

ContextualNavbar.propTypes = {
  title: PropTypes.string.isRequired,
  rightHandLinks: PropTypes.arrayOf(
    PropTypes.shape({
      link: PropTypes.string,
      label: PropTypes.string,
    }),
  ),
  children: PropTypes.node,
};

export default ContextualNavbar;
