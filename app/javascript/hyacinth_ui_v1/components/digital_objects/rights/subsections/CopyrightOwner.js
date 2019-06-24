import React from 'react';
import { Card, Button } from 'react-bootstrap';
import produce from 'immer';

import InputGroup from '../../form/InputGroup';
import Label from '../../form/Label';
import TextAreaInput from '../../form/inputs/TextAreaInput';
import ControlledVocabularySelect from '../../form/inputs/ControlledVocabularySelect';
import TextInput from '../../form/inputs/TextInput';

export default class CopyrightOwner extends React.PureComponent {
  onFieldChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value, index, onRemove } = this.props;

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
          <InputGroup>
            <Label>Name</Label>
            <ControlledVocabularySelect
              vocabulary="name"
              value={value.name}
              onChange={v => this.onFieldChange('name', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>Heirs</Label>
            <TextInput value={value.heirs} onChange={v => this.onFieldChange('heirs', v)} />
          </InputGroup>

          <InputGroup>
            <Label>Contact information for Copyright Owner or Heirs</Label>
            <TextAreaInput
              value={value.contactInformation}
              onChange={v => this.onFieldChange('contactInformation', v)}
            />
          </InputGroup>
        </Card.Body>
      </Card>
    );
  }
}
