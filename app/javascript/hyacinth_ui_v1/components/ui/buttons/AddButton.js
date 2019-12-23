import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class AddButton extends React.PureComponent {
  render() {
    const { className, onClick, children, ...rest } = this.props;

    return (
      <Button
        variant="success"
        size="sm"
        className={className}
        onClick={onClick}
        {...rest}
      >
        <FontAwesomeIcon icon="plus" size="sm" />
        {children}
      </Button>
    );
  }
}

AddButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

AddButton.defaultProps = {
  className: '',
};

export default AddButton;
