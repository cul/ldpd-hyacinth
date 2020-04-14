import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import Field from '../fields/Field';

function RightsForWorksOfArtSculptureAndPhotographs(props) {
  const { values: [value], onChange, defaultValue, fieldConfig } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [publicityRightsPresentEnabled, setPublicityRightsPresentEnabled] = useEnabled(
    value.publicity_rights_present, () => onChangeHandler('publicity_rights_present', ''),
  );

  const [enabled, setEnabled] = useEnabled(
    value, () => {
      setPublicityRightsPresentEnabled(false);
      onChange([{ ...defaultValue }]);
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
          <BooleanRadioButtons value={enabled} onChange={setEnabled} />
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
                <Field
                  value={value.publicity_rights_present}
                  onChange={v => onChangeHandler('publicity_rights_present', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'publicity_rights_present')}
                />
              </div>
            </Collapse>

            <Field
              value={value.trademarks_prominently_visible}
              onChange={v => onChangeHandler('trademarks_prominently_visible', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'trademarks_prominently_visible')}
            />

            <Field
              value={value.sensitive_in_nature}
              onChange={v => onChangeHandler('sensitive_in_nature', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'sensitive_in_nature')}
            />

            <Field
              value={value.privacy_concerns}
              onChange={v => onChangeHandler('privacy_concerns', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'privacy_concerns')}
            />

            <Field
              value={value.children_materially_identifiable_in_work}
              onChange={v => onChangeHandler('children_materially_identifiable_in_work', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'children_materially_identifiable_in_work')}
            />

            <Field
              value={value.vara_rights_concerns}
              onChange={v => onChangeHandler('vara_rights_concerns', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'vara_rights_concerns')}
            />

            <Field
              value={value.note}
              onChange={v => onChangeHandler('note', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'note')}
            />
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
