import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';

function CancelButton({ to, action }) {
  const history = useHistory();

  const redirect = () => history.push(to);

  return (
    <Button
      variant="danger"
      type="button"
      onClick={action || redirect}
    >
      Cancel
    </Button>
  );
}

CancelButton.propTypes = {
  to: PropTypes.string,
  action: PropTypes.func,
};

export default CancelButton;
