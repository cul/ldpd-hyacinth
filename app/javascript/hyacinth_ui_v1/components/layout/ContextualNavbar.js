import React from 'react';
import { Nav, Navbar } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

export default class ContextualNavbar extends React.Component {
  render() {
    let title = null;

    if (this.props.title) {
      title = <Navbar.Brand style={{ fontSize: '1.6rem' }}>{this.props.title}</Navbar.Brand>;
    }

    let rightHandLinks = [];

    if (this.props.rightHandLinks) {
      rightHandLinks = this.props.rightHandLinks.map((obj, i) => (
        <Nav.Item as="li" key={i}>
          <LinkContainer to={obj.link}>
            <Nav.Link>{obj.label}</Nav.Link>
          </LinkContainer>
        </Nav.Item>
      ));
    }

    return (
      <Navbar bg="light" expand="lg" className="my-3 rounded contextual-navbar">
        {title}
        <Nav className="ml-auto">
          {this.props.children}
          {rightHandLinks}
        </Nav>
      </Navbar>
    );
  }
}
