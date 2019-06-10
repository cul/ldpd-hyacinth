import React from 'react';
import { Form, Row, Col, Card, Collapse } from 'react-bootstrap';

import MultiSelectInputGroup from '../form_inputs/MultiSelectInputGroup';
import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import TextAreaInputGroup from '../form_inputs/TextAreaInputGroup';
import TextInputGroup from '../form_inputs/TextInputGroup';
import DateInputGroup from '../form_inputs/DateInputGroup';
import CheckboxInputGroup from '../form_inputs/CheckboxInputGroup';

const permissionsGrantedAsPartOfTheUseLicense = [
  'Reproduction',
  'Distribution',
  'Derivative Works',
  'Public Display',
  'Public Performance',
  'Digital Streaming',
  'Right of First Publication',
];

const avLimitationsOnAccess = [
  { value: 'avA', label: 'Screening of excerpt permitted for closed event exhibition for non-broadcast purposes only' },
  { value: 'avB', label: 'Right to make excerpt is limited to collections purposes only' },
  { value: 'avC', label: 'Film or video may be screened in-house for non-paying audiences only' },
  { value: 'avD', label: 'Excerpts may be licensed to third parties only for non-exclusive non-commercial purposes' },
  { value: 'avE', label: 'Excerpts may be reproduced and distributed to Columbia University students and faculty for educational purposes only' },
  { value: 'avF', label: 'No online reproduction and distribution' },
  { value: 'avG', label: 'No editing or modification' },
];

const limitationsOnAccess = [
  { value: 'a', label: 'Access limited to on-site only for reseach and study' },
  { value: 'b', label: 'No reproduction and distribution unless with prior permission of copyright owner' },
  { value: 'c', label: 'No Reproduction and distribution unless with prior permission of donor' },
  { value: 'd', label: 'Reproduction and distribution online limited to non-profit educational use only' },
  { value: 'e', label: 'Online use limited to specific website' },
];

class ContractualLimitationsRestrictionsAndPermissions extends React.PureComponent {
  render() {
    const { audioVisualContent, value, onChange } = this.props;

    let checkboxLimitations = limitationsOnAccess;

    if (audioVisualContent) checkboxLimitations = checkboxLimitations.concat(avLimitationsOnAccess)

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Contractual Limitations, Restrictions, and Permissions
          </Card.Title>

          <BooleanInputGroup
            label="Are Contractual restrictions included as part of the Copyright Transfer or Use License?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />

          <Collapse in={value.enabled}>
            <div>
              <Row>
                <Form.Label column>Indicate as many of the following types of limitations on access as are applicable:</Form.Label>

              </Row>
              <Row>
                <Col sm={{offset: 1}}>
                  {
                    checkboxLimitations.map(({ value, label }) => (
                      <CheckboxInputGroup
                        value={value}
                        label={label}
                        inputName={value}
                        onChange={onChange}
                      />
                    ))
                  }

                  <DateInputGroup
                    label="Reproduction and Distribution Prohibited Until Date"
                    inputName="reproductionAndDistributionProhibitedUntil"
                    value={value.reproductionAndDistributionProhibitedUntil}
                    onChange={onChange}
                  />

                  <TextInputGroup
                    label="Photographic or film credit required [photo credit entered here]"
                    inputName="photoGraphicOrFilmCredit"
                    value={value.photoGraphicOrFilmCredit}
                    onChange={onChange}
                  />

                  <TextInputGroup
                    label="Excerpts limited to [X] minutes"
                    inputName="excerptLimitedTo"
                    value={value.excerptLimitedTo}
                    onChange={onChange}
                  />

                  <TextInputGroup
                    label="Other"
                    inputName="other"
                    value={value.other}
                    onChange={onChange}
                  />
                </Col>
              </Row>

              <BooleanInputGroup
                label="Are permissions granted as part of the Use License?"
                inputName="permissionsGrantedAsPartOfTheUseLicenseEnabled"
                value={value.permissionsGrantedAsPartOfTheUseLicenseEnabled}
                onChange={onChange}
              />

              <Collapse in={value.permissionsGrantedAsPartOfTheUseLicenseEnabled}>
                <div>
                  <MultiSelectInputGroup
                    label=""
                    inputName="permissionsGrantedAsPartOfTheUseLicense"
                    values={value.permissionsGrantedAsPartOfTheUseLicense}
                    onChange={onChange}
                    options={
                      permissionsGrantedAsPartOfTheUseLicense.map(i => ({ value: i, label: i }))
                    }
                  />
                </div>
              </Collapse>
            </div>
          </Collapse>


        </Card.Body>
      </Card>
    );
  }
}

export default ContractualLimitationsRestrictionsAndPermissions;
