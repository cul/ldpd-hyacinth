import React from 'react';
import { Form, Row } from 'react-bootstrap';

// Form group for horizonal forms inputs. Use with Label and Input elements.

export default class InputGroup extends React.PureComponent {
  render() {
    const { children, ...rest } = this.props;

    return (
      <Form.Group as={Row} {...rest}>{children}</Form.Group>
    );
  }
}
