import React from 'react';
import { Button } from 'react-bootstrap';
import { withRouter } from 'react-router-dom';

class SubmitButton extends React.Component {
  state = {
    isSaving: false,
  }

  onClick = (e) => {
    e.preventDefault();

    this.setState({ isSaving: true })
  }

  saveData = () => {
    const { isSaving } = this.state;

    if (isSaving) {
      const { saveData } = this.props;
      saveData().finally(() => {
        setTimeout(() => this.setState({ isSaving: false }), 500)
      });
    }
  }

  componentDidMount = () => this.saveData()

  componentDidUpdate = () => this.saveData()

  render() {
    const { formType, saveData, ...rest } = this.props;
    const { isSaving } = this.state;

    return (
      <Button variant="info" type="submit" onClick={this.onClick} disabled={isSaving} {...rest}>
        {isSaving ? 'Saving...' : formType === 'new' ? 'Create' : 'Update'}
      </Button>
    );
  }
}

export default withRouter(SubmitButton);
