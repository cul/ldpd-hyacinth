import React from 'react';
import { Form, Row } from 'react-bootstrap';

// Form group for horizonal forms inputs. Use with Label and Input elements.

export default class Label extends React.PureComponent {
  render() {
    const { children } = this.props;

    return (
      <Form.Group as={Row}>{children}</Form.Group>
    );
  }
}
