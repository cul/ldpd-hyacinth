import React from 'react';
import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class CancelButton extends React.Component {
  onCancelHandler = () => {
    const { to, history: { push } } = this.props;

    push(to);
  }

  render() {
    return (
      <Button variant="danger" type="button" onClick={this.onCancelHandler}>Cancel</Button>
    );
  }
}

CancelButton.propTypes = {
  to: PropTypes.string.isRequired,
};

export default withRouter(CancelButton);
