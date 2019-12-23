import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class UpArrowButton extends React.PureComponent {
  render() {
    const { className, onClick, ...rest } = this.props;

    return (
      <Button
        variant="secondary"
        size="sm"
        className={className}
        onClick={onClick}
        {...rest}
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
