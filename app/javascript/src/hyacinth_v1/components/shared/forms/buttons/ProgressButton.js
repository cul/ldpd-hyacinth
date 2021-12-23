import React, { useState } from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';

/**
 * A ProgressButton functional component.
 * @param {Object} props - An object.
 * @param {string} props.label - Classes to add to the rendered button.
 * @param {string} props.label - The component's default label.
 * @param {string} props.type - The type attribute for the underlying button element (e.g. "submit").
 * @param {function} props.onClick - Function to call when the button is clicked. If the function
 *                                   returns a promise, the state of the promise (pending/success/error)
 *                                   will affect the state of this component.
 * @param {function} props.onSuccess - Function to call when going back to the default state after success.
 *                                     Function is given the result of the promise returned by the onClick function;
 * @param {function} props.onError - Function to call when going back to the default state after an error.
 *                                   Function is given the error from the promise returned by the onClick function;
 */
const ProgressButton = ({
  label, type, loadingLabel, onClick, onSuccess, onError, className,
}) => {
  const [state, setState] = useState('default');
  const successStateReturnTime = 500; // milliseconds
  const errorStateReturnTime = 1500; // milliseconds
  const minimumLoadingStateTime = 500; // milliseconds

  let currentLabel = label;
  let currentVariant = 'primary';

  if (state === 'loading') {
    currentLabel = loadingLabel;
  } else if (state === 'success') {
    currentLabel = 'Success!';
    currentVariant = 'success';
  } else if (state === 'error') {
    currentLabel = 'An error occurred.';
    currentVariant = 'danger';
  }

  const returnToDefaultStateAfterTimeout = (callback, returnTime) => {
    setTimeout(() => {
      setState('default');
      callback();
    }, returnTime);
  };

  const onClickHandler = (e) => {
    e.preventDefault();
    const expectedPromise = onClick();

    if (!(expectedPromise instanceof Promise)) {
      throw new Error('Expected onClick return value to be a promise.');
    }

    setState('loading');

    Promise.all([
      expectedPromise,
      // Below, we're forcing a minimum time display of the loading state so that the loading
      // message doesn't fly by in a jarring way if the promise resolves too quickly.
      new Promise((resolve) => { setTimeout(resolve, minimumLoadingStateTime); }),
    ])
      // we only want to pass along the expectedPromise result
      .then((allResult) => allResult[0]).then((result) => {
        setState('success');
        returnToDefaultStateAfterTimeout(() => { onSuccess(result); }, successStateReturnTime);
      }).catch((error) => {
        setState('error');
        returnToDefaultStateAfterTimeout(() => { onError(error); }, errorStateReturnTime);
      });
  };

  return (
    <Button
      type={type}
      variant={currentVariant}
      disabled={state === 'loading'}
      onClick={onClickHandler}
      aria-label={label}
      className={className}
    >
      {currentLabel}
    </Button>
  );
};

ProgressButton.propTypes = {
  className: PropTypes.string,
  label: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  loadingLabel: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  onSuccess: PropTypes.func,
  onError: PropTypes.func,
};

ProgressButton.defaultProps = {
  className: undefined,
  onSuccess: () => { },
  onError: () => { },
};

export default ProgressButton;
