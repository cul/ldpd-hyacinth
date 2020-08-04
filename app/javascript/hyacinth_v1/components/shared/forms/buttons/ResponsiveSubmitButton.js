import React, { useState } from 'react';
import { Button } from 'react-bootstrap';

const ResponsiveSubmitButton = (props) => {
  const { formType, saveData, staticContext, ...rest } = props;
  const [isSaving, setIsSaving] = useState(false);
  const [success, setSuccess] = useState(null);

  const onClick = (e) => {
    e.preventDefault();

    const exec = () => {
      setIsSaving(true);
      saveData();
      setIsSaving(false);
      setSuccess(true);
    };

    new Promise(exec)
      .catch(() => setIsSaving(false) && setSuccess(false))
      .then(() => setTimeout(() => setIsSaving(false) && setSuccess(null)), 1000);
  };

  let savingText = 'Saving...';
  let variant = 'primary';

  if (success) {
    savingText = 'Saved!';
    variant = 'success';
  } else if (success === false) {
    savingText = 'Could Not Save!';
    variant = 'warning';
  } else {
    savingText = formType === 'new' ? 'Create' : 'Update';
  }

  return (
    <Button variant={variant} type="submit" onClick={onClick} disabled={isSaving} {...rest}>
      {savingText}
    </Button>
  );
};

export default ResponsiveSubmitButton;
