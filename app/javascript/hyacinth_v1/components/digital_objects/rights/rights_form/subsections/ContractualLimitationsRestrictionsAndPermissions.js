import React from 'react';
import {
  Form, Row, Col, Card, Collapse,
} from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../../ui/forms/Label';
import InputGroup from '../../../../ui/forms/InputGroup';
import BooleanRadioButtons from '../../../../ui/forms/inputs/BooleanRadioButtons';
import TextInput from '../../../../ui/forms/inputs/TextInput';
import DateInput from '../../../../ui/forms/inputs/DateInput';
import MultiSelectInput from '../../../../ui/forms/inputs/MultiSelectInput';
import Checkbox from '../../../../ui/forms/inputs/Checkbox';

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
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

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

          <InputGroup>
            <Label sm={4} align="right">
              Are Contractual restrictions included as part of the Copyright Transfer or Use License?
            </Label>
            <BooleanRadioButtons
              value={value.enabled}
              onChange={v => this.onChange('enabled', v)}
            />
          </InputGroup>

          <Collapse in={value.enabled}>
            <div>
              <Row>
                <Form.Label column>
                  Indicate as many of the following types of limitations on access as are applicable:
                </Form.Label>
              </Row>
              <Row>
                <Col sm={{ offset: 1 }}>
                  {
                    checkboxLimitations.map(entry => (
                      <InputGroup key={entry.value}>
                        <Checkbox
                          value={value[entry.value]}
                          label={entry.label}
                          inputName={entry.value}
                          onChange={newVal => this.onChange(entry.value, newVal)}
                        />
                      </InputGroup>
                    ))
                  }

                  <InputGroup>
                    <Label sm={4} align="right">Reproduction and Distribution Prohibited Until Date</Label>
                    <DateInput
                      value={value.reproductionAndDistributionProhibitedUntil}
                      onChange={v => this.onChange('reproductionAndDistributionProhibitedUntil', v)}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Photographic or film credit required [photo credit entered here]</Label>
                    <TextInput
                      sm={8}
                      value={value.photoGraphicOrFilmCredit}
                      onChange={v => this.onChange('photoGraphicOrFilmCredit', v)}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Excerpts limited to [X] minutes</Label>
                    <TextInput
                      sm={8}
                      value={value.excerptLimitedTo}
                      onChange={v => this.onChange('excerptLimitedTo', v)}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Other</Label>
                    <TextInput
                      sm={8}
                      value={value.other}
                      onChange={v => this.onChange('other', v)}
                    />
                  </InputGroup>
                </Col>
              </Row>

              <InputGroup>
                <Label sm={4} align="right">Are permissions granted as part of the Use License?</Label>
                <BooleanRadioButtons
                  value={value.permissionsGrantedAsPartOfTheUseLicenseEnabled}
                  onChange={v => this.onChange('permissionsGrantedAsPartOfTheUseLicenseEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.permissionsGrantedAsPartOfTheUseLicenseEnabled}>
                <div>
                  <InputGroup>
                    <Label sm={4}/>
                    <MultiSelectInput
                      values={value.permissionsGrantedAsPartOfTheUseLicense}
                      onChange={v => this.onChange('permissionsGrantedAsPartOfTheUseLicense', v)}
                      options={
                        permissionsGrantedAsPartOfTheUseLicense.map(i => ({ value: i, label: i }))
                      }
                    />
                  </InputGroup>
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
