import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';

class PurgeButton extends React.Component {
  onClick = (e) => {
    const { onClick } = this.props;

    // eslint-disable-next-line no-alert
    if (window.confirm('Are you sure you want to purge? This action cannot be undone.')) {
      onClick(e);
    }
  }

  render() {
    const { formType, onClick, ...rest } = this.props;

    return (
      formType === 'edit'
        && <Button variant="outline-danger" type="button" onClick={this.onClick} {...rest}>Purge</Button>
    );
  }
}

PurgeButton.propTypes = {
  formType: PropTypes.oneOf(['edit', 'new']).isRequired,
  onClick: PropTypes.func.isRequired,
};

export default PurgeButton;
