import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { LinkContainer } from 'react-router-bootstrap';
import FontAwesomeIcon from '../../../utils/lazyFontAwesome';

const EditButton = (props) => {
  const { link, children, ...rest } = props;

  return (
    <LinkContainer to={link} style={{ padding: '0.05rem 0.35rem', marginLeft: '.25rem' }}>
      <Button
        variant="outline-primary"
        size="sm"
        {...rest}
      >
        <FontAwesomeIcon icon="pen" />
        { children }
      </Button>
    </LinkContainer>
  );
};

EditButton.propTypes = {
  link: PropTypes.string.isRequired,
};

export default EditButton;
