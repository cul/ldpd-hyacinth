import React from 'react';
import { Nav } from 'react-bootstrap';

export default class ProjectTabs extends React.Component {
  render() {
    const { children } = this.props;

    return (
      <Nav fill variant="tabs" className="mb-2">
        {children}
      </Nav>
    );
  }
}
