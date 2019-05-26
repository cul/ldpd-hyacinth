import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';

class DeleteButton extends React.Component {
  render() {
    const { formType, ...rest } = this.props;

    return (
      formType === 'edit'
        && <Button variant="outline-danger" type="button" {...rest}>Delete</Button>
    );
  }
}

DeleteButton.defaultProps = {
  formType: '',
};


DeleteButton.propTypes = {
  formType: PropTypes.oneOf(['edit', 'new']),
  onClick: PropTypes.func.isRequired,
};

export default DeleteButton;
