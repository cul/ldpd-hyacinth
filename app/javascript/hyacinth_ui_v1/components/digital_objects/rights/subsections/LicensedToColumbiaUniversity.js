import React from 'react';
import { Card, Collapse } from 'react-bootstrap';

import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import TextInputGroup from '../form_inputs/TextInputGroup';
import TextAreaInputGroup from '../form_inputs/TextAreaInputGroup';
import DateInputGroup from '../form_inputs/DateInputGroup';

export default class LicenseToColumbiaUniversity extends React.PureComponent {
  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Licensed To Columbia University (Copyright Not Transferred)
          </Card.Title>

          <BooleanInputGroup
            label="Has Columbia University obtained a license for use of this work?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />

          <Collapse in={value.enabled}>
            <div>
              <DateInputGroup
                label="Date of License"
                inputName="dateOfLicense"
                value={value.dateOfLicense}
                onChange={onChange}
              />

              <DateInputGroup
                label="Termination Date of License"
                inputName="terminationDateOfLicense"
                value={value.terminationDateOfLicense}
                onChange={onChange}
              />

              <TextAreaInputGroup
                label="Credits / Other Display Requirements"
                inputName="credits"
                value={value.credits}
                onChange={onChange}
              />

              <TextAreaInputGroup
                label="Acknowledgements"
                inputName="acknowledgements"
                value={value.acknowledgements}
                onChange={onChange}
              />

              <TextInputGroup
                label="License Documentation Location"
                inputName="licenseDocumentationLocation"
                value={value.licenseDocumentationLocation}
                onChange={onChange}
              />
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
