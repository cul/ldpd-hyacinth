import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import CopyrightOwner from './CopyrightOwner';
import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';

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

  addCopyrightOwner = (index) => {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft.copyrightOwners.splice(index + 1, 0, { name: {}, heirs: '', contactInformation: '' })
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
            <Label sm={4} align="right">Is copyright holder different from creator?</Label>
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
                    onAdd={() => this.addCopyrightOwner(index)}
                  />
                ))
              }
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
