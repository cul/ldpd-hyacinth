import React from 'react';
import { Form, Col } from 'react-bootstrap';

import SubmitButton from './buttons/SubmitButton';
import CancelButton from './buttons/CancelButton';
import DeleteButton from './buttons/DeleteButton';

class FormButtons extends React.PureComponent {
  render() {
    const {
      formType, cancelTo, onDelete, onSave,
    } = this.props;

    return (
      <Form.Row>
        <Col sm="auto" className="mr-auto">
          { onDelete && <DeleteButton onClick={onDelete} formType={formType} /> }
        </Col>

        <Col sm="auto">
          { cancelTo && <CancelButton to={cancelTo} />}
        </Col>

        <Col sm="auto">
          <SubmitButton saveData={onSave} formType={formType} />
        </Col>
      </Form.Row>
    );
  }
}

export default FormButtons;
