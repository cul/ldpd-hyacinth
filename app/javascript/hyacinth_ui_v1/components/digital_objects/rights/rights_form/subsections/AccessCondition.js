import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../ui/forms/Label';
import InputGroup from '../../../ui/forms/InputGroup';
import ReadOnlyInput from '../../../ui/forms/inputs/ReadOnlyInput';
import TextAreaInput from '../../../ui/forms/inputs/TextAreaInput';

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
            <Label sm={4} align="right">Access Condition</Label>
            <ReadOnlyInput sm={8} value={value.accessCondition} />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Closed/Embargo Release Date:</Label>
            <ReadOnlyInput
              sm={8}
              value={value.embargoReleaseDate}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Access Note</Label>
            <TextAreaInput
              sm={8}
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
