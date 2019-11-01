import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../ui/forms/Label';
import InputGroup from '../../../ui/forms/InputGroup';
import BooleanRadioButton from '../../../ui/forms/inputs/BooleanRadioButtons';
import SelectInput from '../../../ui/forms/inputs/SelectInput';
import TextAreaInput from '../../../ui/forms/inputs/TextAreaInput';
import TextInput from '../../../ui/forms/inputs/TextInput';
import MultiSelectInput from '../../../ui/forms/inputs/MultiSelectInput';

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
            <Label sm={4} align="right">
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
                <Label sm={4} align="right">Do we know specific underlying rights?</Label>
                <BooleanRadioButton
                  value={value.doWeKnowSpecificUnderlyingRightsEnabled}
                  onChange={v => this.onChange('doWeKnowSpecificUnderlyingRightsEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <InputGroup>
                    <Label sm={4} align="right">Are there music rights?</Label>
                    <BooleanRadioButton
                      value={value.musicRightsEnabled}
                      onChange={v => this.onChange('musicRightsEnabled', v)}
                    />
                  </InputGroup>

                  <Collapse in={value.musicRightsEnabled}>
                    <div>
                      <InputGroup>
                        <Label sm={4} align="right">Music licensed to Columbia?</Label>
                        <BooleanRadioButton
                          value={value.musicLicensedToColumbiaEnabled}
                          onChange={v => this.onChange('musicLicensedToColumbiaEnabled', v)}
                        />
                      </InputGroup>

                      <Collapse in={value.musicLicensedToColumbiaEnabled}>
                        <div>
                          <InputGroup>
                            <Label sm={4}/>
                            <SelectInput
                              sm={8}
                              value={value.columbiaMusicLicense}
                              onChange={v => this.onChange('columbiaMusicLicense', v)}
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
                          onChange={v => this.onChange('composition', v)}
                        />
                      </InputGroup>

                      <InputGroup>
                        <Label sm={4} align="right">Recording [record label]</Label>
                        <TextInput
                          sm={8}
                          value={value.recording}
                          onChange={v => this.onChange('recording', v)}
                        />
                      </InputGroup>
                    </div>
                  </Collapse>

                  <InputGroup>
                    <Label sm={4} align="right">If film/video produced commercially, talent rights</Label>
                    <SelectInput
                      sm={8}
                      value={value.talentRights}
                      onChange={v => this.onChange('talentRights', v)}
                      options={talentRights.map(i => ({ value: i, label: i }))}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Other Underlying Rights</Label>
                    <MultiSelectInput
                      values={value.otherUnderlyingRights}
                      onChange={v => this.onChange('otherUnderlyingRights', v)}
                      options={otherUnderlyingRights.map(i => ({ value: i, label: i }))}
                    />
                  </InputGroup>

                  <InputGroup>
                    <Label sm={4} align="right">Other</Label>
                    <TextInput sm={8} value={value.other} onChange={v => this.onChange('other', v)} />
                  </InputGroup>
                </div>
              </Collapse>

              <Collapse in={!value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <InputGroup>
                    <Label sm={4} align="right">Describe in a Note</Label>
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
