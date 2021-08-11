import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import FieldGroupArray from '../fields/FieldGroupArray';

function CopyrightOwnership(props) {
  const { fieldConfig, values, defaultValue, onChange } = props;

  const clear = () => onChange([{ ...defaultValue }]);

  const [enabled, setEnabled] = useEnabled(values, clear);

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>Copyright Ownership</Card.Title>

        <InputGroup>
          <Label sm={4} align="right">Is copyright holder different from creator?</Label>
          <BooleanRadioButtons value={enabled} onChange={v => setEnabled(v)} />
        </InputGroup>

        <Collapse in={enabled}>
          <div>
            <FieldGroupArray
              value={values}
              defaultValue={defaultValue}
              dynamicFieldGroup={fieldConfig}
              onChange={onChange}
            />
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

export default CopyrightOwnership;
