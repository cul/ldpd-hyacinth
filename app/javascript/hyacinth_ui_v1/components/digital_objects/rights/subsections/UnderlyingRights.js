import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';
import BooleanRadioButton from '../../form/inputs/BooleanRadioButtons';
import SelectInput from '../../form/inputs/SelectInput';
import TextAreaInput from '../../form/inputs/TextAreaInput';
import TextInput from '../../form/inputs/TextInput';
import MultiSelectInput from '../../form/inputs/MultiSelectInput';

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

class UnderlyingRights extends React.PureComponent {
  onChange(fieldName, fieldVal) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[fieldName] = fieldVal;
    });

    onChange(nextValue);
  }

  render() {
    const { value } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Underlying Rights
          </Card.Title>

          <InputGroup>
            <Label>
              Does the work have underlying rights that are known
              and for which information is available?
            </Label>
            <BooleanRadioButton
              inputName="enabled"
              value={value.enabled}
              onChange={v => this.onChange('enabled', v)}
            />
          </InputGroup>


          <Collapse in={value.enabled}>
            <div>
              <InputGroup>
                <Label>Do we know specific underlying rights?</Label>
                <BooleanRadioButton
                  value={value.doWeKnowSpecificUnderlyingRightsEnabled}
                  onChange={v => this.onChange('doWeKnowSpecificUnderlyingRightsEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <InputGroup>
                    <Label>Are there music rights?</Label>
                    <BooleanRadioButton
                      value={value.musicRightsEnabled}
                      onChange={v => this.onChange('musicRightsEnabled', v)}
                    />
                  </InputGroup>

                  <Collapse in={value.musicRightsEnabled}>
                    <div>
                      <InputGroup>
                        <Label>Music licensed to Columbia?</Label>
                        <BooleanRadioButton
                          value={value.musicLicensedToColumbiaEnabled}
                          onChange={v => this.onChange('musicLicensedToColumbiaEnabled', v)}
                        />
                      </InputGroup>

                      <Collapse in={value.musicLicensedToColumbiaEnabled}>
                        <div>
                          <InputGroup>
                            <Label />
                            <SelectInput
                              value={value.columbiaMusicLicense}
                              onChange={v => this.onChange('columbiaMusicLicense', v)}
                              options={columbiaMusicLicense.map(i => ({ value: i, label: i }))}
                            />
                          </InputGroup>
                        </div>
                      </Collapse>

                      <InputGroup>
                        <Label>Composition [music publisher]</Label>
                        <TextInput
                          value={value.composition}
                          onChange={v => this.onChange('composition', v)}
                        />
                      </InputGroup>

                      <InputGroup>
                        <Label>Recording [record label]</Label>
                        <TextInput
                          value={value.recording}
                          onChange={v => this.onChange('recording', v)}
                        />
                      </InputGroup>
                    </div>
                  </Collapse>

                  <InputGroup>
                    <Label>If film/video produced commercially, talent rights</Label>
                    <SelectInput
                      value={value.talentRights}
                      onChange={v => this.onChange('talentRights', v)}
                      options={talentRights.map(i => ({ value: i, label: i }))}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label>Other Underlying Rights</Label>
                    <MultiSelectInput
                      values={value.otherUnderlyingRights}
                      onChange={v => this.onChange('otherUnderlyingRights', v)}
                      options={otherUnderlyingRights.map(i => ({ value: i, label: i }))}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label>Other</Label>
                    <TextInput value={value.other} onChange={v => this.onChange('other', v)} />
                  </InputGroup>
                </div>
              </Collapse>

              <Collapse in={!value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <InputGroup>
                    <Label>Describe in a Note</Label>
                    <TextAreaInput value={value.note} onChange={v => this.onChange('note', v)} />
                  </InputGroup>
                </div>
              </Collapse>
            </div>
          </Collapse>

        </Card.Body>
      </Card>
    );
  }
}

export default UnderlyingRights;
