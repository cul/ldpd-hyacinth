import React from 'react';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class SubmitButton extends React.PureComponent {
  render() {
    const { formType, ...rest } = this.props;
    return (
      <Button variant="primary" type="submit" {...rest}>
        {formType === 'new' ? 'Create' : 'Update'}
      </Button>
    );
  }
}

export default withRouter(SubmitButton);
