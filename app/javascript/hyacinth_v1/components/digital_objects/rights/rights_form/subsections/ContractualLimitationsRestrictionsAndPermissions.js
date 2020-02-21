import React from 'react';
import {
  Form, Row, Col, Card, Collapse,
} from 'react-bootstrap';
import produce from 'immer';
import PropTypes from 'prop-types';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import MultiSelectInput from '../../../../shared/forms/inputs/MultiSelectInput';
import Checkbox from '../../../../shared/forms/inputs/Checkbox';
import { useEnabled } from '../rightsHooks';
import { defaultItemRights } from '../defaultRights';

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
  { value: 'optionAvA', label: 'Screening of excerpt permitted for closed event exhibition for non-broadcast purposes only' },
  { value: 'optionAvB', label: 'Right to make excerpt is limited to collections purposes only' },
  { value: 'optionAvC', label: 'Film or video may be screened in-house for non-paying audiences only' },
  { value: 'optionAvD', label: 'Excerpts may be licensed to third parties only for non-exclusive non-commercial purposes' },
  { value: 'optionAvE', label: 'Excerpts may be reproduced and distributed to Columbia University students and faculty for educational purposes only' },
  { value: 'optionAvF', label: 'No online reproduction and distribution' },
  { value: 'optionAvG', label: 'No editing or modification' },
];

const limitationsOnAccess = [
  { value: 'optionA', label: 'Access limited to on-site only for reseach and study' },
  { value: 'optionB', label: 'No reproduction and distribution unless with prior permission of copyright owner' },
  { value: 'optionC', label: 'No Reproduction and distribution unless with prior permission of donor' },
  { value: 'optionD', label: 'Reproduction and distribution online limited to non-profit educational use only' },
  { value: 'optionE', label: 'Online use limited to specific website' },
];

function ContractualLimitationsRestrictionsAndPermissions(props) {
  const {
    audioVisualContent, values: [value], onChange,
  } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [permissionsGrantedEnabled, setPermissionsGrantedEnabled] = useEnabled(
    value.permissionsGrantedAsPartOfTheUseLicense,
    () => onChangeHandler('permissionsGrantedAsPartOfTheUseLicense', []),
  );

  const [enabled, setEnabled] = useEnabled(
    value, () => {
      onChange(defaultItemRights.contractualLimitationsRestrictionsAndPermissions);
      setPermissionsGrantedEnabled(false);
    },
  );

  let checkboxLimitations = limitationsOnAccess;

  if (audioVisualContent) checkboxLimitations = checkboxLimitations.concat(avLimitationsOnAccess);

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
            value={enabled}
            onChange={setEnabled}
          />
        </InputGroup>

        <Collapse in={enabled}>
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
                        onChange={newVal => onChangeHandler(entry.value, newVal)}
                      />
                    </InputGroup>
                  ))
                }

                <InputGroup>
                  <Label sm={4} align="right">Reproduction and Distribution Prohibited Until Date</Label>
                  <DateInput
                    value={value.reproductionAndDistributionProhibitedUntil}
                    onChange={v => onChangeHandler('reproductionAndDistributionProhibitedUntil', v)}
                  />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Photographic or film credit required [photo credit entered here]</Label>
                  <TextInput
                    sm={8}
                    value={value.photographicOrFilmCredit}
                    onChange={v => onChangeHandler('photographicOrFilmCredit', v)}
                  />
                </InputGroup>

                <Collapse in={audioVisualContent}>
                  <div>
                    <InputGroup>
                      <Label sm={4} align="right">Excerpts limited to [X] minutes</Label>
                      <TextInput
                        sm={8}
                        value={value.excerptLimitedTo}
                        onChange={v => onChangeHandler('excerptLimitedTo', v)}
                      />
                    </InputGroup>
                  </div>
                </Collapse>

                <InputGroup>
                  <Label sm={4} align="right">Other</Label>
                  <TextInput
                    sm={8}
                    value={value.other}
                    onChange={v => onChangeHandler('other', v)}
                  />
                </InputGroup>
              </Col>
            </Row>

            <InputGroup>
              <Label sm={4} align="right">Are permissions granted as part of the Use License?</Label>
              <BooleanRadioButtons
                value={permissionsGrantedEnabled}
                onChange={setPermissionsGrantedEnabled}
              />
            </InputGroup>

            <Collapse in={permissionsGrantedEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} />
                  <MultiSelectInput
                    values={value.permissionsGrantedAsPartOfTheUseLicense.map(i => i.value)}
                    onChange={v => onChangeHandler('permissionsGrantedAsPartOfTheUseLicense', v.map(i => ({ value: i })))}
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

ContractualLimitationsRestrictionsAndPermissions.propTypes = {
  audioVisualContent: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
  values: PropTypes.arrayOf(PropTypes.any).isRequired,
};

export default ContractualLimitationsRestrictionsAndPermissions;
