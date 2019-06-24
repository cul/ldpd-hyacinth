import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';
import ReadOnlyInput from '../../form/inputs/ReadOnlyInput';
import TextAreaInput from '../../form/inputs/TextAreaInput';

class AccessCondition extends React.PureComponent {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>CUL Access Condition</Card.Title>

          <InputGroup>
            <Label>Access Condition</Label>
            <ReadOnlyInput value={value.accessCondition} />
          </InputGroup>

          <InputGroup>
            <Label>Closed/Embargo Release Date:</Label>
            <ReadOnlyInput
              value={value.embargoReleaseDate}
            />
          </InputGroup>

          <InputGroup>
            <Label>Access Note</Label>
            <TextAreaInput
              value={value.note}
              onChange={v => this.onChange('note', v)}
            />
          </InputGroup>
        </Card.Body>
      </Card>
    );
  }
}

export default AccessCondition;
