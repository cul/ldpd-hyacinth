import React from 'react';
import { Form, Col } from 'react-bootstrap';

import ResponsiveSubmitButton from './buttons/ResponsiveSubmitButton';
import CancelButton from './buttons/CancelButton';
import DeleteButton from './buttons/DeleteButton';

function FormButtons(props) {
  const {
    formType, cancelTo, cancelAction, onDelete, onSave,
  } = props;

  return (
    <Form.Row>
      <Col sm="auto" className="mr-auto">
        { onDelete && <DeleteButton onClick={onDelete} formType={formType} /> }
      </Col>

      <Col sm="auto">
        { (cancelTo || cancelAction) && <CancelButton to={cancelTo} action={cancelAction} />}
      </Col>

      <Col sm="auto">
        <ResponsiveSubmitButton saveData={onSave} formType={formType} />
      </Col>
    </Form.Row>
  );
}

export default FormButtons;
