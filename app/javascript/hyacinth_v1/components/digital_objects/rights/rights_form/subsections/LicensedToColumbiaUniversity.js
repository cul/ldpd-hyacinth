import React from 'react';
import PropTypes from 'prop-types';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButton from '../../../../shared/forms/inputs/BooleanRadioButtons';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import { useEnabled } from '../rightsHooks';
import { defaultItemRights } from '../defaultRights';

function LicenseToColumbiaUniversity(props) {
  const { values: [value], onChange } = props;

  const [enabled, setEnabled] = useEnabled(
    value,
    () => onChange(defaultItemRights.licensedToColumbiaUniversity),
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
            <InputGroup>
              <Label sm={4} align="right">Date of License</Label>
              <DateInput
                value={value.dateOfLicense}
                onChange={v => onChangeHandler('dateOfLicense', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Termination Date of License</Label>
              <DateInput
                value={value.terminationDateOfLicense}
                onChange={v => onChangeHandler('terminationDateOfLicense', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Credits / Other Display Requirements</Label>
              <TextAreaInput
                value={value.credits}
                onChange={v => onChangeHandler('credits', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Acknowledgements</Label>
              <TextAreaInput
                value={value.acknowledgements}
                onChange={v => onChangeHandler('acknowledgements', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">License Documentation Location</Label>
              <TextInput
                sm={8}
                value={value.licenseDocumentationLocation}
                onChange={v => onChangeHandler('licenseDocumentationLocation', v)}
              />
            </InputGroup>
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
