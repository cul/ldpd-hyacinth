import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class RemoveButton extends React.PureComponent {
  render() {
    const { className, onClick } = this.props;

    return (
      <Button
        variant="danger"
        size="sm"
        className={className}
        onClick={onClick}
      >
        <FontAwesomeIcon icon="times" size="sm" />
      </Button>
    );
  }
}

RemoveButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

RemoveButton.defaultProps = {
  className: '',
};

export default RemoveButton;
