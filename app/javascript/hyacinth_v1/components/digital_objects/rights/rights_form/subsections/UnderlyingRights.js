import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';
import { omit, pick } from 'lodash';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButton from '../../../../shared/forms/inputs/BooleanRadioButtons';
import MultiSelectInput from '../../../../shared/forms/inputs/MultiSelectInput';
import { useEnabled } from '../rightsHooks';
import Field from '../fields/Field';

function UnderlyingRights(props) {
  const {
    values: [value], onChange, fieldConfig,
  } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [musicLicensedToColumbiaEnabled, setMusicLicensedToColumbiaEnabled] = useEnabled(
    pick(value, 'columbia_music_license'), () => onChangeHandler('columbia_music_license', ''),
  );

  const [musicRightsEnabled, setMusicRightsEnabled] = useEnabled(
    pick(value, ['composition', 'columbia_music_license', 'recording']),
    () => {
      setMusicLicensedToColumbiaEnabled(false);
      onChange(produce((draft) => {
        draft[0].composition = '';
        draft[0].recording = '';
      }));
    },
  );

  const [
    doWeKnowSpecificUnderlyingRightsEnabled,
    setDoWeKnowSpecificUnderlyingRightsEnabled,
  ] = useEnabled(
    omit(value, 'note'),
    () => {
      setMusicRightsEnabled(false);
      setMusicLicensedToColumbiaEnabled(false);
      onChange(produce((draft) => {
        draft[0].talent_rights = '';
        draft[0].other_underlying_rights = [];
        draft[0].other = '';
      }));
    },
  );

  const [enabled, setEnabled] = useEnabled(
    value, () => {
      setDoWeKnowSpecificUnderlyingRightsEnabled(false);
      setMusicRightsEnabled(false);
      setMusicLicensedToColumbiaEnabled(false);
    },
  );

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>Underlying Rights</Card.Title>

        <InputGroup>
          <Label sm={4} align="right">
            Does the work have underlying rights that are known
            and for which information is available?
          </Label>
          <BooleanRadioButton
            inputName="enabled"
            value={enabled}
            onChange={setEnabled}
          />
        </InputGroup>

        <Collapse in={enabled}>
          <div>
            <InputGroup>
              <Label sm={4} align="right">Do we know specific underlying rights?</Label>
              <BooleanRadioButton
                value={doWeKnowSpecificUnderlyingRightsEnabled}
                onChange={setDoWeKnowSpecificUnderlyingRightsEnabled}
              />
            </InputGroup>

            <Collapse in={doWeKnowSpecificUnderlyingRightsEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} align="right">Are there music rights?</Label>
                  <BooleanRadioButton
                    value={musicRightsEnabled}
                    onChange={setMusicRightsEnabled}
                  />
                </InputGroup>

                <Collapse in={musicRightsEnabled}>
                  <div>
                    <InputGroup>
                      <Label sm={4} align="right">Music licensed to Columbia?</Label>
                      <BooleanRadioButton
                        value={musicLicensedToColumbiaEnabled}
                        onChange={setMusicLicensedToColumbiaEnabled}
                      />
                    </InputGroup>

                    <Collapse in={musicLicensedToColumbiaEnabled}>
                      <div>
                        <Field
                          value={value.columbia_music_license}
                          onChange={v => onChangeHandler('columbia_music_license', v)}
                          dynamicField={fieldConfig.children.find(c => c.stringKey === 'columbia_music_license')}
                        />
                      </div>
                    </Collapse>

                    <Field
                      value={value.composition}
                      onChange={v => onChangeHandler('composition', v)}
                      dynamicField={fieldConfig.children.find(c => c.stringKey === 'composition')}
                    />

                    <Field
                      value={value.recording}
                      onChange={v => onChangeHandler('recording', v)}
                      dynamicField={fieldConfig.children.find(c => c.stringKey === 'recording')}
                    />
                  </div>
                </Collapse>

                <Field
                  value={value.talent_rights}
                  onChange={v => onChangeHandler('talent_rights', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'talent_rights')}
                />

                <InputGroup>
                  <Label sm={4} align="right">Other Underlying Rights</Label>
                  <MultiSelectInput
                    values={value.other_underlying_rights.map(e => e.value)}
                    onChange={v => onChangeHandler('other_underlying_rights', v.map(e => ({ value: e })))}
                    options={JSON.parse(fieldConfig.children.find(c => c.stringKey === 'other_underlying_rights').children.find(c => c.stringKey === 'value').selectOptions)}
                  />
                </InputGroup>

                <Field
                  value={value.other}
                  onChange={v => onChangeHandler('other', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'other')}
                />
              </div>
            </Collapse>

            <Collapse in={!doWeKnowSpecificUnderlyingRightsEnabled}>
              <div>
                <Field
                  value={value.note}
                  onChange={v => onChangeHandler('note', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'note')}
                />
              </div>
            </Collapse>
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

export default UnderlyingRights;
