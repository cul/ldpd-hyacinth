import React from 'react';
import { Nav } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

class TaskNavLink extends React.PureComponent {
  render() {
    const { children, href, ...rest } = this.props;

    return (
      <Nav.Item>
        <LinkContainer to={href}>
          <Nav.Link {...rest}>{children}</Nav.Link>
        </LinkContainer>
      </Nav.Item>
    );
  }
}

export default TaskNavLink;
