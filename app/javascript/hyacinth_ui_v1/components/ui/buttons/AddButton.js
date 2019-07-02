import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class AddButton extends React.PureComponent {
  render() {
    const { onClick, children, ...rest } = this.props;

    return (
      <Button
        variant="success"
        size="sm"
        style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}
        onClick={onClick}
        {...rest}
      >
        <FontAwesomeIcon icon="plus" />
        {children}
      </Button>
    );
  }
}

AddButton.propTypes = {
  onClick: PropTypes.func.isRequired,
};

export default AddButton;
