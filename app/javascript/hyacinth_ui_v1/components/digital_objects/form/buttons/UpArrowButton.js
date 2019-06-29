import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class UpArrowButton extends React.PureComponent {
  render() {
    const { onClick } = this.props;

    return (
      <Button
        variant="secondary"
        size="sm"
        style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}
        onClick={onClick}
      >
        <FontAwesomeIcon icon="caret-up" size="lg" />
      </Button>
    );
  }
}

UpArrowButton.propTypes = {
  onClick: PropTypes.func.isRequired,
};

export default UpArrowButton;
