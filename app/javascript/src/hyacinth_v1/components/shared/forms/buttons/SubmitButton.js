import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

const SubmitButton = (props) => {
  const { formType, ...rest } = props;
  return (
    <Button variant="primary" type="submit" {...rest}>
      {formType === 'new' ? 'Create' : 'Update'}
    </Button>
  );
};
SubmitButton.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
};

export default SubmitButton;
