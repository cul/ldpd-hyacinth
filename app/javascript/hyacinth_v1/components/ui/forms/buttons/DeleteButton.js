import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';

class DeleteButton extends React.Component {
  onClick = (e) => {
    const { onClick } = this.props;

    if (window.confirm('Are you sure you want to delete?')) {
      onClick(e);
    }
  }

  render() {
    const { formType, onClick, ...rest } = this.props;

    return (
      formType === 'edit'
        && <Button variant="outline-danger" type="button" onClick={this.onClick} {...rest}>Delete</Button>
    );
  }
}

DeleteButton.propTypes = {
  formType: PropTypes.oneOf(['edit', 'new']).isRequired,
  onClick: PropTypes.func.isRequired,
};

export default DeleteButton;
