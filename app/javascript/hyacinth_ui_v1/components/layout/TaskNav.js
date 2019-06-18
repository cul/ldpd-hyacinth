import React from 'react';
import { Nav } from 'react-bootstrap';

import TaskNavLink from './TaskNavLink';

class TaskNav extends React.PureComponent {
  render() {
    const { children } = this.props;

    return (
      <Nav className="justify-content-center task-nav rounded mb-3">
        {children}
      </Nav>
    );
  }
}

TaskNav.Link = TaskNavLink;

export default TaskNav;
