import React, { useState } from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

/*
  saveData should be a function returning a function or Promise
  Unless saveData resolves to a value with a data property,
  the component will suppress state updates/component redraws to
  prevent memory leaks.
 */
const ResponsiveSubmitButton = (props) => {
  const { formType, saveData, ...rest } = props;
  const [isSaving, setIsSaving] = useState(false);
  const [success, setSuccess] = useState(null);

  const onClick = (e) => {
    e.preventDefault();
    const element = e.target;
    element.text = 'Saving...';
    element.disabled = true;
    const resetButton = () => {
      setIsSaving(false);
      setSuccess(null);
      element.disabled = false;
    };
    const onError = () => {
      setIsSaving(false);
      setSuccess(false);
      return true; // to enable the timed reset of the form
    };
    const onSuccess = (res) => {
      if (res.data) {
        setIsSaving(false);
        setSuccess(true);
        return res;
      }
      return false;
    };

    Promise.resolve(saveData())
      .then(onSuccess).catch(onError)
      .then((reset) => {
        if (reset) setTimeout(resetButton, 1000);
      });
  };

  let savingText = formType === 'new' ? 'Create' : 'Update';
  let variant = 'primary';

  if (success) {
    savingText = 'Saved!';
    variant = 'success';
  } else if (success === false) {
    savingText = 'Could Not Save!';
    variant = 'warning';
  }

  return (
    <Button variant={variant} type="submit" onClick={onClick} disabled={isSaving} {...rest}>
      {savingText}
    </Button>
  );
};

ResponsiveSubmitButton.propTypes = {
  formType: PropTypes.oneOf(['new', 'edit']).isRequired,
  saveData: PropTypes.func.isRequired,
};
export default ResponsiveSubmitButton;
