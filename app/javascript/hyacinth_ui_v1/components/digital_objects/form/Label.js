import React from 'react';
import { Form } from 'react-bootstrap';

export default class Label extends React.PureComponent {
  render() {
    const { children, ...rest } = this.props;

    return (
      <Form.Label column sm={4} className="digital-object-form-label" {...rest}>
        {children}
      </Form.Label>
    );
  }
}
