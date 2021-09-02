import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

const SubmitButton = (props) => {
  const { formType, ...rest } = props;
  const buttonLabel = formType === 'new' ? 'Create' : 'Update';
  return (
    <Button variant="primary" type="submit" aria-label={buttonLabel} {...rest}>
      {buttonLabel}
    </Button>
  );
};
SubmitButton.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
};

export default SubmitButton;
