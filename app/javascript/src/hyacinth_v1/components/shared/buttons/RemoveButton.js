import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const RemoveButton = (props) => {
  return (
    <Button
      variant="danger"
      size="sm"
      { ...props }
    >
      <FontAwesomeIcon icon="times" size="sm" />
    </Button>
  );
};

RemoveButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

RemoveButton.defaultProps = {
  className: '',
};

export default RemoveButton;
