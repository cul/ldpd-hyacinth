import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';

const DeleteButton = (props) => {
  const {
    formType, onClick, onSuccess, ...rest
  } = props;
  const onClickHandler = (e) => {
    if (window.confirm('Are you sure you want to delete?')) {
      onClick(e).then((result) => {
        onSuccess(result);
      });
    }
  };

  return (
    formType === 'edit'
      && <Button variant="outline-danger" type="button" onClick={onClickHandler} {...rest}>Delete</Button>
  );
};

DeleteButton.propTypes = {
  formType: PropTypes.oneOf(['edit', 'new']).isRequired,
  onClick: PropTypes.func.isRequired,
  onSuccess: PropTypes.func,
};
DeleteButton.defaultProps = {
  onSuccess: () => {},
};

export default DeleteButton;
