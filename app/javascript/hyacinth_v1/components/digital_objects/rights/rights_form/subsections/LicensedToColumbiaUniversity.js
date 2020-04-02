import React from 'react';
import PropTypes from 'prop-types';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButton from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import Field from '../fields/Field';

function LicenseToColumbiaUniversity(props) {
  const { defaultValue, values: [value], onChange, fieldConfig } = props;

  const [enabled, setEnabled] = useEnabled(
    value,
    () => onChange([{ ...defaultValue }]),
  );

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>
          Licensed To Columbia University (Copyright Not Transferred)
        </Card.Title>

        <InputGroup>
          <Label sm={4} align="right">Has Columbia University obtained a license for use of this work?</Label>
          <BooleanRadioButton
            value={enabled}
            onChange={setEnabled}
          />
        </InputGroup>

        <Collapse in={enabled}>
          <div>
            <Field
              value={value.date_of_license}
              onChange={v => onChangeHandler('date_of_license', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'date_of_license')}
            />

            <Field
              value={value.termination_date_of_license}
              onChange={v => onChangeHandler('termination_date_of_license', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'termination_date_of_license')}
            />

            <Field
              value={value.credits}
              onChange={v => onChangeHandler('credits', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'credits')}
            />

            <Field
              value={value.acknowledgements}
              onChange={v => onChangeHandler('acknowledgements', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'acknowledgements')}
            />

            <Field
              value={value.license_documentation_location}
              onChange={v => onChangeHandler('license_documentation_location', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'license_documentation_location')}
            />
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

LicenseToColumbiaUniversity.propTypes = {
  onChange: PropTypes.func.isRequired,
};

export default LicenseToColumbiaUniversity;
