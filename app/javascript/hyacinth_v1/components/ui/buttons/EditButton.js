import React from 'react';
import { Button } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from 'react-router-bootstrap';

class EditButton extends React.PureComponent {
  render() {
    const { link, children, ...rest } = this.props;

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
  }
}

EditButton.propTypes = {
  link: PropTypes.string.isRequired,
};

export default EditButton;
