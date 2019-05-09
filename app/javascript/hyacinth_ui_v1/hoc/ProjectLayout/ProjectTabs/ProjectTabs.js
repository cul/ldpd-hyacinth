import React from 'react';
import { Nav } from 'react-bootstrap';

export default class ProjectTabs extends React.Component {
  render() {
    return (
      <Nav fill variant="tabs" className="mb-2">
        {this.props.children}
      </Nav>
    );
  }
}
