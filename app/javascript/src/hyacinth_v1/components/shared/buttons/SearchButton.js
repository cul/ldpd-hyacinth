import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const SearchButton = (props) => {
  const { onClick, id } = props;

  return (
    <Button
      id={id}
      variant="primary"
      size="sm"
      onClick={onClick}
    >
      <FontAwesomeIcon icon="search" />
    </Button>
  );
};

SearchButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  id: PropTypes.string,
};

SearchButton.defaultProps = {
  id: undefined,
};

export default SearchButton;
