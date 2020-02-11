import React from 'react';
import { Card } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import ReadOnlyInput from '../../../../shared/forms/inputs/ReadOnlyInput';
import YesNoSelect from '../../../../shared/forms/inputs/YesNoSelect';

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
            <Label sm={4} align="right">Copyright Statement</Label>
            <ReadOnlyInput sm={8} value={value.copyrightStatement} />
          </InputGroup>

          {
            value.copyrightNote
              .map((t, i) => (
                <InputGroup key={i}>
                  <Label sm={4} align="right">Copyright Note</Label>
                  <ReadOnlyInput sm={8} value={t} />
                </InputGroup>
              ))
          }

          <InputGroup>
            <Label sm={4} align="right">Copyright Registered?</Label>
            <YesNoSelect
              value={value.copyrightRegistered}
              onChange={v => this.onChange('copyrightRegistered', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Copyright Renewed?</Label>
            <YesNoSelect
              value={value.copyrightRenewed}
              onChange={v => this.onChange('copyrightRenewed', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">If Renewed, Date of Renewal</Label>
            <DateInput
              value={value.copyrightDateOfRenewal}
              onChange={v => this.onChange('copyrightDateOfRenewal', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">Copyright Expiration Date</Label>
            <DateInput
              value={value.copyrightExpirationDate}
              onChange={v => this.onChange('copyrightExpirationDate', v)}
            />
          </InputGroup>

          <InputGroup>
            <Label sm={4} align="right">CUL Copyright Assessment Date</Label>
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
