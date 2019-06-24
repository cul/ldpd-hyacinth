import React from 'react';
import {
  Row, Col, Card, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import produce from 'immer';

import CopyrightOwner from './CopyrightOwner';
import InputGroup from '../../form/InputGroup';
import Label from '../../form/Label';
import BooleanRadioButtons from '../../form/inputs/BooleanRadioButtons';

export default class CopyrightOwnership extends React.Component {
  onFieldChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  onCopyrightOwnerChange(index, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft.copyrightOwners[index] = fieldVal;
    });

    onChange(nextValue);
  }

  addCopyrightOwner = () => {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft.copyrightOwners.push(
        { name: '', heirs: '', contactInformation: '' }
      );
    });

    onChange(nextValue);
  }

  removeCopyrightOwner = (index) => {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft.copyrightOwners.splice(index, 1);
    });

    onChange(nextValue);
  }

  render() {
    const { value } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Copyright Ownership
          </Card.Title>

          <InputGroup>
            <Label>Is copyright holder different from creator?</Label>
            <BooleanRadioButtons value={value.enabled} onChange={v => this.onFieldChange('enabled', v)} />
          </InputGroup>

          <Collapse in={value.enabled}>
            <div>
              {
                value.copyrightOwners.map((copyrightOwner, index) => (
                  <CopyrightOwner
                    index={index}
                    key={index}
                    value={copyrightOwner}
                    onChange={v => this.onCopyrightOwnerChange(index, v)}
                    onRemove={() => this.removeCopyrightOwner(index)}
                  />
                ))
              }
              <Row>
                <Col className="text-center">
                  <Button variant="success" size="sm" onClick={this.addCopyrightOwner}>
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
