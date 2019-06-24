import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import InputGroup from '../../form/InputGroup';
import Label from '../../form/Label';
import DateInput from '../../form/inputs/DateInput';
import TextInput from '../../form/inputs/TextInput';
import BooleanRadioButtons from '../../form/inputs/BooleanRadioButtons';

class ColumbiaUniversityIsCopyrightHolder extends React.PureComponent {
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
          <Card.Title>
             Columbia University Is Copyright Holder
          </Card.Title>

          <InputGroup>
            <Label>Was copyright transferred to Columbia University from a Third Party?</Label>
            <BooleanRadioButtons value={value.enabled} onChange={v => this.onChange('enabled', v)} />
          </InputGroup>

          <Collapse in={value.enabled}>
            <div>
              <InputGroup>
                <Label>Date of Transfer</Label>
                <DateInput value={value.dateOfTransfer} onChange={v => this.onChange('dateOfTransfer', v)} />
              </InputGroup>

              <InputGroup>
                <Label>Date of Expiration of Columbia Copyright (if known)</Label>
                <DateInput value={value.dateOfExpiration} onChange={v => this.onChange('dateOfExpiration', v)} />
              </InputGroup>

              <InputGroup>
                <Label>Transfer Document to Columbia University Exists</Label>
                <BooleanRadioButtons
                  value={value.transferDocumentionEnabled}
                  onChange={v => this.onChange('transferDocumentionEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.transferDocumentionEnabled}>
                <div>
                  <InputGroup>
                    <Label>Transfer Documentation</Label>
                    <TextInput
                      value={value.transferDocumentation}
                      onChange={v => this.onChange('transferDocumentation', v)}
                    />
                  </InputGroup>
                </div>
              </Collapse>

              <Collapse in={!value.transferDocumentionEnabled}>
                <div>
                  <InputGroup>
                    <Label>Does Other Evidence of Transfer Exist?</Label>
                    <BooleanRadioButtons
                      value={value.otherTransferEvidenceEnabled}
                      onChange={v => this.onChange('otherTransferEvidenceEnabled', v)}
                    />
                  </InputGroup>

                  <Collapse in={value.otherTransferEvidenceEnabled}>
                    <div>
                      <InputGroup>
                        <Label>Evidence of Transfer Documentation</Label>
                        <TextInput
                          value={value.otherTransferEvidence}
                          onChange={v => this.onChange('otherTransferEvidence', v)}
                        />
                      </InputGroup>
                    </div>
                  </Collapse>
                </div>
              </Collapse>

              <InputGroup>
                <Label>Transfer Documentation Note</Label>
                <TextInput
                  value={value.transferDocumentationNote}
                  onChange={v => this.onChange('transferDocumentationNote', v)}
                />
              </InputGroup>
            </div>
          </Collapse>
        </Card.Body>
      </Card>

    );
  }
}

export default ColumbiaUniversityIsCopyrightHolder;
