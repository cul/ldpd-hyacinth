import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';
import TermSelect from '../../../../shared/forms/inputs/TermSelect';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import RemoveButton from '../../../../shared/buttons/RemoveButton';
import AddButton from '../../../../shared/buttons/AddButton';

export default class CopyrightOwner extends React.PureComponent {
  onFieldChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const {
      value, index, onRemove, onAdd
    } = this.props;

    return (
      <Card className="mb-3">
        <Card.Header>
          {`Copyright Owner ${index + 1}`}

          <span className="float-right">
            <RemoveButton onClick={onRemove} />
            <AddButton onClick={onAdd} />
          </span>
        </Card.Header>

        <Card.Body>
          <InputGroup>
            <Label sm={4} align="right">Name</Label>
            <TermSelect
              vocabulary="name"
              value={value.name}
              onChange={v => this.onFieldChange('name', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Heirs</Label>
            <TextInput sm={8} value={value.heirs} onChange={v => this.onFieldChange('heirs', v)} />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Contact information for Copyright Owner or Heirs</Label>
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
