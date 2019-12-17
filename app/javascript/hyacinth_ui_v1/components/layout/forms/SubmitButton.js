import React from 'react';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class SubmitButton extends React.PureComponent {
  render() {
    // Note: Extracting staticContext here won't be necessary when we
    // switch to functional components + hooks
    const { formType, staticContext, ...rest } = this.props;
    return (
      <Button variant="info" type="submit" {...rest}>
        {formType === 'new' ? 'Create' : 'Update'}
      </Button>
    );
  }
}

export default withRouter(SubmitButton);
