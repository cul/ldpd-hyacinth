import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class DownArrowButton extends React.PureComponent {
  render() {
    const { onClick, ...rest } = this.props;

    return (
      <Button
        variant="secondary"
        size="sm"
        style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}
        onClick={onClick}
        {...rest}
      >
        <FontAwesomeIcon icon="caret-down" size="lg" />
      </Button>
    );
  }
}

DownArrowButton.propTypes = {
  onClick: PropTypes.func.isRequired,
};

export default DownArrowButton;
