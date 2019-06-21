import React from 'react';
import { Form, Col, Row, Card, Button } from 'react-bootstrap';

import TextInputGroup from '../form_inputs/TextInputGroup';
import TextAreaInputGroup from '../form_inputs/TextAreaInputGroup';
import DateInputGroup from '../form_inputs/DateInputGroup';
import ControlledVocabularySelect from '../../form/ControlledVocabularySelect';

export default class CopyrightOwner extends React.PureComponent {
  render() {
    const { value, index, onChange, onRemove } = this.props;

    return (
      <Card className="mb-3">
        <Card.Header>
          {`Copyright Owner ${index + 1}`}
          <span className="float-right">
            <Button variant="danger" size="sm" onClick={onRemove}>
              Remove
            </Button>
          </span>
        </Card.Header>
        <Card.Body>
          <Form.Group as={Row} className="mb-1">
            <Form.Label column sm={4} className="text-right">Name</Form.Label>
            <Col sm={8} style={{ alignSelf: 'center' }}>
              <ControlledVocabularySelect
                vocabulary="name"
                value={value.name}
                onChange={v => onChange('name', v)}
              />
            </Col>
          </Form.Group>

          {/* <TextInputGroup
            label="Name"
            inputName="name"
            value={value.name}
            onChange={onChange}
          /> */}

          <TextInputGroup
            label="Heirs"
            inputName="heirs"
            value={value.heirs}
            onChange={onChange}
          />

          <TextAreaInputGroup
            label="Contact information for Copyright Owner or Heirs"
            inputName="contactInformation"
            value={value.contactInformation}
            onChange={onChange}
          />
        </Card.Body>
      </Card>
    );
  }
}
