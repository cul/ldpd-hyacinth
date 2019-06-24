import React from 'react';
import { Form, Row } from 'react-bootstrap';

export default class Label extends React.PureComponent {
  render() {
    const { children } = this.props;

    return (
      <Form.Group as={Row}>{children}</Form.Group>
    );
  }
}
