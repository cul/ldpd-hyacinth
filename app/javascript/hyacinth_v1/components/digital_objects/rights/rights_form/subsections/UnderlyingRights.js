import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';
import { omit, pick } from 'lodash';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import BooleanRadioButton from '../../../../shared/forms/inputs/BooleanRadioButtons';
import SelectInput from '../../../../shared/forms/inputs/SelectInput';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import MultiSelectInput from '../../../../shared/forms/inputs/MultiSelectInput';
import { useEnabled } from '../rightsHooks';
import { defaultItemRights } from '../defaultRights';

const talentRights = [
  'SAG AFTRA',
  'AFM',
  'DGA',
  'Writers Guild',
  'Actors Equity',
  'USA',
  'Theatre Actors and Stage Managers',
];

const columbiaMusicLicense = [
  'Sync license',
  'Master recording license',
];

const otherUnderlyingRights = [
  'Authors rights [screenplay]',
  'Photographic rights [photos]',
  'Rights in artistic works',
  'VARA rights',
  'Trademarks',
  'Rights in graphics and text',
  'Location rights',
  'Performance rights',
  'Choreography',
  'Costume design',
];

function UnderlyingRights(props) {
  const { values, values: [value], onChange } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [musicLicensedToColumbiaEnabled, setMusicLicensedToColumbiaEnabled] = useEnabled(
    pick(value, 'columbiaMusicLicense'), () => onChangeHandler('columbiaMusicLicense', ''),
  );

  const [musicRightsEnabled, setMusicRightsEnabled] = useEnabled(
    pick(value, ['composition', 'columbiaMusicLicense', 'recording']),
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
        draft[0].talentRights = '';
        draft[0].otherUnderlyingRights = [];
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
                        <InputGroup>
                          <Label sm={4} />
                          <SelectInput
                            sm={8}
                            value={value.columbiaMusicLicense}
                            onChange={v => onChangeHandler('columbiaMusicLicense', v)}
                            options={columbiaMusicLicense.map(i => ({ value: i, label: i }))}
                          />
                        </InputGroup>
                      </div>
                    </Collapse>

                    <InputGroup>
                      <Label sm={4} align="right">Composition [music publisher]</Label>
                      <TextInput
                        sm={8}
                        value={value.composition}
                        onChange={v => onChangeHandler('composition', v)}
                      />
                    </InputGroup>

                    <InputGroup>
                      <Label sm={4} align="right">Recording [record label]</Label>
                      <TextInput
                        sm={8}
                        value={value.recording}
                        onChange={v => onChangeHandler('recording', v)}
                      />
                    </InputGroup>
                  </div>
                </Collapse>

                <InputGroup>
                  <Label sm={4} align="right">If film/video produced commercially, talent rights</Label>
                  <SelectInput
                    sm={8}
                    value={value.talentRights}
                    onChange={v => onChangeHandler('talentRights', v)}
                    options={talentRights.map(i => ({ value: i, label: i }))}
                  />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Other Underlying Rights</Label>
                  <MultiSelectInput
                    values={value.otherUnderlyingRights.map(e => e.value)}
                    onChange={v => onChangeHandler('otherUnderlyingRights', v.map(e => ({ value: e })))}
                    options={otherUnderlyingRights.map(i => ({ value: i, label: i }))}
                  />
                </InputGroup>

                <InputGroup>
                  <Label sm={4} align="right">Other</Label>
                  <TextInput sm={8} value={value.other} onChange={v => onChangeHandler('other', v)} />
                </InputGroup>
              </div>
            </Collapse>

            <Collapse in={!doWeKnowSpecificUnderlyingRightsEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} align="right">Describe in a Note</Label>
                  <TextAreaInput value={value.note} onChange={v => onChangeHandler('note', v)} />
                </InputGroup>
              </div>
            </Collapse>
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

export default UnderlyingRights;
