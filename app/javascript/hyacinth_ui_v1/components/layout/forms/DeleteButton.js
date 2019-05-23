import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

const propTypes = {
  formType: PropTypes.oneOf(['edit', 'new']).isRequired,
  onClick: PropTypes.func.isRequired,
};

class DeleteButton extends React.Component {
  render() {
    const { formType, ...rest } = this.props;

    return (
      formType === 'edit'
        && <Button variant="outline-danger" type="button" {...rest}>Delete</Button>
    );
  }
}

DeleteButton.propTypes = propTypes;

export default DeleteButton;
