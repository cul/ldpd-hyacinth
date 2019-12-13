import React from 'react';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class SubmitButton extends React.Component {
  state = {
    isSaving: false,
    success: null,
  }

  onClick = (e) => {
    e.preventDefault();

    this.setState({ isSaving: true });
    const { saveData } = this.props;

    saveData()
      .then(() => this.setState({ success: true }))
      .catch(() => this.setState({ success: false }))
      .then(() => setTimeout(() => this.setState({ isSaving: false, success: null }), 1000));
  }

  render() {
    const { formType, saveData, staticContext, ...rest } = this.props;
    const { isSaving, success } = this.state;

    let savingText = 'Saving...';
    let variant = 'info';

    if (success) {
      savingText = 'Saved!';
      variant = 'success';
    } else if (success === false) {
      savingText = 'Could Not Save!';
      variant = 'warning';
    }

    return (
      <Button variant={variant} type="submit" onClick={this.onClick} disabled={isSaving} {...rest}>
        {isSaving ? savingText : formType === 'new' ? 'Create' : 'Update'}
      </Button>
    );
  }
}

export default withRouter(SubmitButton);
