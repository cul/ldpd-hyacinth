import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const AddButton = (props) => {
  const { children, ...rest } = props;

  return (
    <Button
      variant="success"
      size="sm"
      {...rest}
    >
      <FontAwesomeIcon icon="plus" size="sm" />
      {children}
    </Button>
  );
};

AddButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

AddButton.defaultProps = {
  className: '',
};

export default AddButton;
