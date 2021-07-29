import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

class SearchButton extends React.PureComponent {
  render() {
    const { onClick } = this.props;

    return (
      <Button
        variant="primary"
        size="sm"
        onClick={onClick}
      >
        <FontAwesomeIcon icon="search" />
      </Button>
    );
  }
}

SearchButton.propTypes = {
  onClick: PropTypes.func.isRequired,
};

export default SearchButton;
