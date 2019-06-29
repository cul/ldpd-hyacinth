import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class AddButton extends React.PureComponent {
  render() {
    const { onClick } = this.props;

    return (
      <Button
        variant="success"
        size="sm"
        style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}
        onClick={onClick}
      >
        <FontAwesomeIcon icon="plus" />
      </Button>
    );
  }
}

AddButton.propTypes = {
  onClick: PropTypes.func.isRequired,
}

export default AddButton;
