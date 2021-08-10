import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class UpArrowButton extends React.PureComponent {
  render() {
    return (
      <Button
        variant="secondary"
        size="sm"
        {...this.props}
      >
        <FontAwesomeIcon icon="caret-up" size="lg" />
      </Button>
    );
  }
}

UpArrowButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

UpArrowButton.defaultProps = {
  className: '',
};

export default UpArrowButton;
