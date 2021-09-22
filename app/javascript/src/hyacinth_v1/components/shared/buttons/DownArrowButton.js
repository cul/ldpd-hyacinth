import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const DownArrowButton = (props) => (
  <Button
    variant="secondary"
    size="sm"
    {... props}
  >
    <FontAwesomeIcon icon="caret-down" size="lg" />
  </Button>
);

DownArrowButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

DownArrowButton.defaultProps = {
  className: '',
};

export default DownArrowButton;
