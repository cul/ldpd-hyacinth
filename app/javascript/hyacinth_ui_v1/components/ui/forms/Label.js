import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';

class Label extends React.PureComponent {
  render() {
    const { align, children, ...rest } = this.props;

    return (
      <Form.Label
        column
        sm={2}
        className={align === 'right' ? 'float-right-form-label' : ''}
        {...rest}
      >
        {children}
      </Form.Label>
    );
  }
}

Label.defaultProps = {
  align: 'left',
};

Label.propTypes = {
  align: PropTypes.oneOf(['right', 'left']),
};

export default Label;
