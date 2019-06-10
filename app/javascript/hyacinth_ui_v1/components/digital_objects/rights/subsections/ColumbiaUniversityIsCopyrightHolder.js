import React from 'react';
import { Card, Collapse } from 'react-bootstrap';

import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import DateInputGroup from '../form_inputs/DateInputGroup';
import TextInputGroup from '../form_inputs/TextInputGroup';

class ColumbiaUniversityIsCopyrightHolder extends React.PureComponent {
  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
             Columbia University Is Copyright Holder
          </Card.Title>

          <BooleanInputGroup
            label="Was copyright transferred to Columbia University from a Third Party?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />

          <Collapse in={value.enabled}>
            <div>
              <DateInputGroup
                label="Date of Transfer"
                value={value.dateOfTransfer}
                inputName="dateOfTransfer"
                onChange={onChange}
              />

              <DateInputGroup
                label="Date of Expiration of Columbia Copyright (if known)"
                value={value.dateOfExpiration}
                inputName="dateOfExpiration"
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Transfer Document to Columbia University Exists"
                inputName="transferDocumentionEnabled"
                value={value.transferDocumentionEnabled}
                onChange={onChange}
              />

              <Collapse in={value.transferDocumentionEnabled}>
                <div>
                  <TextInputGroup
                    label="Transfer Documentation"
                    value={value.transferDocumentation}
                    inputName="transferDocumentation"
                    onChange={onChange}
                  />
                </div>
              </Collapse>

              <Collapse in={!value.transferDocumentionEnabled}>
                <div>
                  <BooleanInputGroup
                    label="Does Other Evidence of Transfer Exist?"
                    inputName="otherTransferEvidenceEnabled"
                    value={value.otherTransferEvidenceEnabled}
                    onChange={onChange}
                  />
                  <Collapse in={value.otherTransferEvidenceEnabled}>
                    <div>
                      <TextInputGroup
                        label="Evidence of Transfer Documentation"
                        value={value.otherTransferEvidence}
                        inputName="otherTransferEvidence"
                        onChange={onChange}
                      />
                    </div>
                  </Collapse>
                </div>
              </Collapse>

              <TextInputGroup
                label="Transfer Documentation Note"
                value={value.transferDocumentationNote}
                inputName="transferDocumentationNote"
                onChange={onChange}
              />
            </div>
          </Collapse>
        </Card.Body>
      </Card>

    );
  }
}

export default ColumbiaUniversityIsCopyrightHolder;
