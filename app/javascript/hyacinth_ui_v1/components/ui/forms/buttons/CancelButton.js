import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { useHistory } from 'react-router-dom';

function CancelButton({ to }) {
  const history = useHistory();

  return (
    <Button variant="danger" type="button" onClick={() => history.push(to)}>Cancel</Button>
  );
}

CancelButton.propTypes = {
  to: PropTypes.string.isRequired,
};

export default CancelButton;
