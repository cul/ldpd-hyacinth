import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';
import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';
import BooleanRadioButton from '../../form/inputs/BooleanRadioButtons';
import DateInput from '../../form/inputs/DateInput';
import TextAreaInput from '../../form/inputs/TextAreaInput';
import TextInput from '../../form/inputs/TextInput';


export default class LicenseToColumbiaUniversity extends React.PureComponent {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Licensed To Columbia University (Copyright Not Transferred)
          </Card.Title>

          <InputGroup>
            <Label>Has Columbia University obtained a license for use of this work?</Label>
            <BooleanRadioButton
              value={value.enabled}
              onChange={v => this.onChange('enabled', v)}
            />
          </InputGroup>

          <Collapse in={value.enabled}>
            <div>
              <InputGroup>
                <Label>Date of License</Label>
                <DateInput
                  value={value.dateOfLicense}
                  onChange={v => this.onChange('dateOfLicense', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Termination Date of License</Label>
                <DateInput
                  value={value.terminationDateOfLicense}
                  onChange={v => this.onChange('terminationDateOfLicense', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Credits / Other Display Requirements</Label>
                <TextAreaInput
                  value={value.credits}
                  onChange={v => this.onChange('credits', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Acknowledgements</Label>
                <TextAreaInput
                  value={value.acknowledgements}
                  onChange={v => this.onChange('acknowledgements', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>License Documentation Location</Label>
                <TextInput
                  value={value.licenseDocumentationLocation}
                  onChange={v => this.onChange('licenseDocumentationLocation', v)}
                />
              </InputGroup>
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
