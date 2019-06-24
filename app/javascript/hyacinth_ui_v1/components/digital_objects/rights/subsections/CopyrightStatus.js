import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';
import BooleanRadioButton from '../../form/inputs/BooleanRadioButtons';
import DateInput from '../../form/inputs/DateInput';
import ReadOnlyInput from '../../form/inputs/ReadOnlyInput';
import YesNoSelect from '../../form/inputs/YesNoSelect';

class CopyrightStatus extends React.PureComponent {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { title, value } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>{title || 'Copyright Status'}</Card.Title>

          <InputGroup>
            <Label>Copyright Statement</Label>
            <ReadOnlyInput value={value.copyrightStatement} />
          </InputGroup>

          {
            value.copyrightNote
              .map((t, i) => (
                <InputGroup key={i}>
                  <Label>Copyright Note</Label>
                  <ReadOnlyInput value={t} />
                </InputGroup>
              ))
          }

          <InputGroup>
            <Label>Copyright Registered?</Label>
            <YesNoSelect
              value={value.copyrightRegistered}
              onChange={v => this.onChange('copyrightRegistered', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>Copyright Renewed?</Label>
            <YesNoSelect
              value={value.copyrightRenewed}
              onChange={v => this.onChange('copyrightRenewed', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>If Renewed, Date of Renewal</Label>
            <DateInput
              value={value.copyrightDateOfRenewal}
              onChange={v => this.onChange('copyrightDateOfRenewal', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>Copyright Expiration Date</Label>
            <DateInput
              value={value.copyrightExpirationDate}
              onChange={v => this.onChange('copyrightExpirationDate', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label>CUL Copyright Assessment Date</Label>
            <DateInput
              value={value.culCopyrightAssessmentDate}
              onChange={v => this.onChange('culCopyrightAssessmentDate', v)}
            />
          </InputGroup>
        </Card.Body>
      </Card>
    );
  }
}

export default CopyrightStatus;
