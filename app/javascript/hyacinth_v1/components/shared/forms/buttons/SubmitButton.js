import React from 'react';
import { Button } from 'react-bootstrap';

const SubmitButton = (props) => {
  // Note: Extracting staticContext here won't be necessary when we
  // switch to functional components + hooks
  const { formType, staticContext, ...rest } = props;
  return (
    <Button variant="primary" type="submit" {...rest}>
      {formType === 'new' ? 'Create' : 'Update'}
    </Button>
  );
};

export default SubmitButton;
