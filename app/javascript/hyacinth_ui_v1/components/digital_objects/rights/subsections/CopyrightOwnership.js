import React from 'react';
import {
  Row, Col, Card, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import CopyrightOwner from './CopyrightOwner';
import BooleanInputGroup from '../form_inputs/BooleanInputGroup';

export default class CopyrightOwnership extends React.Component {
  onChangeHandler = (event) => {
    const {
      target: {
        type, name, value, checked,
      },
    } = event;

    const { onChange } = this.props;

    onChange(name, type === 'radio' ? checked : value);
  }

  render() {
    const {
      value, onChange, onCopyrightOwnerChange, addCopyrightOwner, removeCopyrightOwner
    } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Copyright Ownership
          </Card.Title>

          <BooleanInputGroup
            label="Is copyright holder different from creator?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />

          <Collapse in={value.enabled}>
            <div>
              {
                value.copyrightOwners.map((copyrightOwner, index) => (
                  <CopyrightOwner
                    index={index}
                    key={index}
                    value={copyrightOwner}
                    onChange={(fieldName, v) => onCopyrightOwnerChange(index, fieldName, v)}
                    onRemove={() => removeCopyrightOwner(index)}
                  />
                ))
              }
              <Row>
                <Col className="text-center">
                  <Button variant="success" size="sm" onClick={addCopyrightOwner}>
                    <FontAwesomeIcon icon="plus" />
                    Add Copyright Owner
                  </Button>
                </Col>
              </Row>
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
