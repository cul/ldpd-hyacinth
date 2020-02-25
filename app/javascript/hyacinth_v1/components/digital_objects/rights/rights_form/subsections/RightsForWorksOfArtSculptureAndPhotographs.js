import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import SelectInput from '../../../../shared/forms/inputs/SelectInput';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';
import YesNoSelect from '../../../../shared/forms/inputs/YesNoSelect';
import { defaultItemRights } from '../defaultRights';
import { useEnabled } from '../rightsHooks';

const publicityRights = [
  'Written Release',
  'Proof of Release in Written Form',
  'Conditional Release',
  'Partial Release',
  'No release',
];

function RightsForWorksOfArtSculptureAndPhotographs(props) {
  const { values: [value], onChange } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [publicityRightsPresentEnabled, setPublicityRightsPresentEnabled] = useEnabled(
    value.publicityRightsPresent, () => onChangeHandler('publicityRightsPresent', ''),
  );

  const [enabled, setEnabled] = useEnabled(
    value, () => {
      setPublicityRightsPresentEnabled(false);
      onChange([{ ...defaultItemRights.rightsForWorksOfArtSculptureAndPhotographs[0] }]);
    },
  );

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>
          Other Rights Considerations for Works of Art, Sculpture, or Photographs
        </Card.Title>

        <InputGroup>
          <Label sm={4} align="right">
            Are there other rights considerations for works of art, sculptures or photographs?
          </Label>
          <BooleanRadioButtons
            value={enabled}
            onChange={setEnabled}
          />
        </InputGroup>

        <Collapse in={enabled}>
          <div>
            <InputGroup>
              <Label sm={4} align="right">Are publicity rights present?</Label>
              <BooleanRadioButtons
                value={publicityRightsPresentEnabled}
                onChange={setPublicityRightsPresentEnabled}
              />
            </InputGroup>

            <Collapse in={publicityRightsPresentEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} />
                  <SelectInput
                    sm={8}
                    value={value.publicityRightsPresent}
                    options={publicityRights.map(r => ({ label: r, value: r }))}
                    onChange={v => onChangeHandler('publicityRightsPresent', v)}
                  />
                </InputGroup>
              </div>
            </Collapse>

            <InputGroup>
              <Label sm={4} align="right">Are trademarks prominently visible?</Label>
              <YesNoSelect
                value={value.trademarksProminentlyVisible}
                onChange={v => onChangeHandler('trademarksProminentlyVisible', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Is material sensitive in nature?</Label>
              <YesNoSelect
                value={value.sensitiveInNature}
                onChange={v => onChangeHandler('sensitiveInNature', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Are there privacy concerns?</Label>
              <YesNoSelect
                value={value.privacyConcerns}
                onChange={v => onChangeHandler('privacyConcerns', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Are children materially identifiable in work?</Label>
              <YesNoSelect
                value={value.childrenMateriallyIdentifiableInWork}
                onChange={v => onChangeHandler('childrenMateriallyIdentifiableInWork', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Are there VARA (Visual Artists Rights Act of 1990) rights concerns?</Label>
              <YesNoSelect
                value={value.varaRightsConcerns}
                onChange={v => onChangeHandler('varaRightsConcerns', v)}
              />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">
                If legal restrictions apply or require additional explanation, describe in a note
              </Label>
              <TextAreaInput value={value.note} onChange={v => onChangeHandler('note', v)} />
            </InputGroup>
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

RightsForWorksOfArtSculptureAndPhotographs.propTypes = {
  onChange: PropTypes.func.isRequired,
};

export default RightsForWorksOfArtSculptureAndPhotographs;
