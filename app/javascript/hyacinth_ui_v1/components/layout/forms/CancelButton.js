import React from 'react';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class CancelButton extends React.Component {
  onCancelHandler = (event) => {
    this.props.history.push(this.props.to);
  }

  render() {
    return (
      <Button variant="danger" type="button" onClick={this.onCancelHandler}>Cancel</Button>
    );
  }
}

export default withRouter(CancelButton);
