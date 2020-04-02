import React from 'react';
import {
  Form, Row, Col, Card, Collapse,
} from 'react-bootstrap';
import produce from 'immer';
import PropTypes from 'prop-types';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import MultiSelectInput from '../../../../shared/forms/inputs/MultiSelectInput';
import Checkbox from '../../../../shared/forms/inputs/Checkbox';
import { useEnabled } from '../rightsHooks';
import Field from '../fields/Field';

const avLimitationsOnAccess = [
  'option_av_a',
  'option_av_b',
  'option_av_c',
  'option_av_d',
  'option_av_e',
  'option_av_f',
  'option_av_g',
];

const limitationsOnAccess = [
  'option_a',
  'option_b',
  'option_c',
  'option_d',
  'option_e',
];

function ContractualLimitationsRestrictionsAndPermissions(props) {
  const {
    audioVisualContent, values: [value], onChange, defaultValue, fieldConfig,
  } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [permissionsGrantedEnabled, setPermissionsGrantedEnabled] = useEnabled(
    value.permissions_granted_as_part_of_the_use_license,
    () => onChangeHandler('permissions_granted_as_part_of_the_use_license', []),
  );

  const [enabled, setEnabled] = useEnabled(
    value, () => {
      onChange([{ ...defaultValue }]);
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
          <BooleanRadioButtons value={enabled} onChange={setEnabled} />
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
                  checkboxLimitations.map((entry) => {
                    const {
                      stringKey,
                      displayLabel,
                    } = fieldConfig.children.find(c => c.stringKey === entry);

                    return (
                      <InputGroup key={stringKey}>
                        <Checkbox
                          value={value[stringKey]}
                          label={displayLabel}
                          inputName={stringKey}
                          onChange={newVal => onChangeHandler(stringKey, newVal)}
                        />
                      </InputGroup>
                    );
                  })
                }

                <Field
                  value={value.reproduction_and_distribution_prohibited_until}
                  onChange={v => onChangeHandler('reproduction_and_distribution_prohibited_until', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'reproduction_and_distribution_prohibited_until')}
                />

                <Field
                  value={value.photographic_or_film_credit}
                  onChange={v => onChangeHandler('photographic_or_film_credit', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'photographic_or_film_credit')}
                />

                <Collapse in={audioVisualContent}>
                  <div>
                    <Field
                      value={value.excerpt_limited_to}
                      onChange={v => onChangeHandler('excerpt_limited_to', v)}
                      dynamicField={fieldConfig.children.find(c => c.stringKey === 'excerpt_limited_to')}
                    />
                  </div>
                </Collapse>

                <Field
                  value={value.other}
                  onChange={v => onChangeHandler('other', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'other')}
                />
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
                    values={value.permissions_granted_as_part_of_the_use_license.filter(i => i.value.length > 0).map(i => i.value)}
                    onChange={v => onChangeHandler('permissions_granted_as_part_of_the_use_license', v.map(i => ({ value: i })))}
                    options={
                      JSON.parse(
                        fieldConfig
                          .children.find(c => c.stringKey === 'permissions_granted_as_part_of_the_use_license')
                          .children.find(c => c.stringKey === 'value').selectOptions
                      )
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
