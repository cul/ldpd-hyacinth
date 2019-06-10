import React from 'react';
import { Card, Collapse } from 'react-bootstrap';

import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import TextAreaInputGroup from '../form_inputs/TextAreaInputGroup';
import TextInputGroup from '../form_inputs/TextInputGroup';
import SelectInputGroup from '../form_inputs/SelectInputGroup';
import MultiSelectInputGroup from '../form_inputs/MultiSelectInputGroup';

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
  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Underlying Rights
          </Card.Title>

          <BooleanInputGroup
            label="Does the work have underlying rights that are known and for which information is available?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />

          <Collapse in={value.enabled}>
            <div>
              <BooleanInputGroup
                label="Do we know specific underlying rights?"
                inputName="doWeKnowSpecificUnderlyingRightsEnabled"
                value={value.doWeKnowSpecificUnderlyingRightsEnabled}
                onChange={onChange}
              />

              <Collapse in={value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <BooleanInputGroup
                    label="Are there music rights?"
                    inputName="musicRightsEnabled"
                    value={value.musicRightsEnabled}
                    onChange={onChange}
                  />

                  <Collapse in={value.musicRightsEnabled}>
                    <div>
                      <BooleanInputGroup
                        label="Music licensed to Columbia?"
                        inputName="musicLicensedToColumbiaEnabled"
                        value={value.musicLicensedToColumbiaEnabled}
                        onChange={onChange}
                      />

                      <Collapse in={value.musicLicensedToColumbiaEnabled}>
                        <div>
                          <SelectInputGroup
                            label=""
                            inputName="columbiaMusicLicense"
                            value={value.columbiaMusicLicense}
                            onChange={onChange}
                            options={columbiaMusicLicense.map(i => ({ value: i, label: i }))}
                          />
                        </div>
                      </Collapse>

                      <TextInputGroup
                        label="Composition [music publisher]"
                        inputName="composition"
                        value={value.composition}
                        onChange={onChange}
                      />

                      <TextInputGroup
                        label="Recording [record label]"
                        inputName="recording"
                        value={value.recording}
                        onChange={onChange}
                      />
                    </div>
                  </Collapse>

                  <SelectInputGroup
                    label="If film/video produced commercially, talent rights"
                    inputName="talentRights"
                    value={value.talentRights}
                    onChange={onChange}
                    options={talentRights.map(i => ({ value: i, label: i }))}
                  />

                  <MultiSelectInputGroup
                    label="Other Underlying Rights"
                    inputName="otherUnderlyingRights"
                    values={value.otherUnderlyingRights}
                    onChange={onChange}
                    options={otherUnderlyingRights.map(i => ({ value: i, label: i }))}
                  />

                  <TextInputGroup
                    label="Other"
                    inputName="other"
                    value={value.other}
                    onChange={onChange}
                  />
                </div>
              </Collapse>

              <Collapse in={!value.doWeKnowSpecificUnderlyingRightsEnabled}>
                <div>
                  <TextAreaInputGroup
                    label="Describe in a Note"
                    inputName="note"
                    value={value.note}
                    onChange={onChange}
                  />
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
