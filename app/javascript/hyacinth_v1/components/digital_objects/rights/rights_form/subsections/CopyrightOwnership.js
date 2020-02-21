import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import { produce } from 'immer';
import CopyrightOwner from './CopyrightOwner';
import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import { defaultItemRights } from '../defaultRights';

// Default value for one owner
const defaultValue = defaultItemRights.copyrightOwnership[0];

function CopyrightOwnership(props) {
  const { values, onChange } = props;

  const clear = () => onChange([defaultValue]);

  const [enabled, setEnabled] = useEnabled(values, clear);

  const onCopyrightOwnerChange = (index, updates) => {
    onChange((obj) => {
      const updatedValue = updates(obj[index]);
      return produce(obj, (draft) => {
        draft[index] = updatedValue;
      });
    });
  };

  const addCopyrightOwner = (index) => {
    onChange(produce((draft) => {
      draft.splice(index + 1, 0, defaultValue);
    }));
  };

  const removeCopyrightOwner = (index) => {
    onChange(produce((draft) => {
      draft.splice(index, 1);
    }));
  };

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
            {
              values.map((copyrightOwner, index) => (
                <CopyrightOwner
                  index={index}
                  key={index}
                  value={copyrightOwner}
                  onChange={updates => onCopyrightOwnerChange(index, updates)}
                  onRemove={() => removeCopyrightOwner(index)}
                  onAdd={() => addCopyrightOwner(index)}
                />
              ))
            }
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

export default CopyrightOwnership;
