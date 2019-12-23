import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class DownArrowButton extends React.PureComponent {
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
        <FontAwesomeIcon icon="caret-down" size="lg" />
      </Button>
    );
  }
}

DownArrowButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

DownArrowButton.defaultProps = {
  className: '',
};

export default DownArrowButton;
