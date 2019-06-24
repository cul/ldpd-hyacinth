import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../form/Label';
import InputGroup from '../../form/InputGroup';
import BooleanRadioButtons from '../../form/inputs/BooleanRadioButtons';
import SelectInput from '../../form/inputs/SelectInput';
import TextAreaInput from '../../form/inputs/TextAreaInput';

const publicityRights = [
  'Written Release',
  'Proof of Release in Written Form',
  'Conditional Release',
  'Partial Release',
  'No release',
];

export default class RightsForWorksOfArtSculptureAndPhotographs extends React.PureComponent {
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
            Other Rights Considerations for Works of Art, Sculpture, or Photographs
          </Card.Title>

          <InputGroup>
            <Label>
              Are there other rights considerations for works of art, sculptures or photographs?
            </Label>
            <BooleanRadioButtons
              value={value.enabled}
              onChange={v => this.onChange('enabled', v)}
            />
          </InputGroup>

          <Collapse in={value.enabled}>
            <div>
              <InputGroup>
                <Label>Are publicity rights present?</Label>
                <BooleanRadioButtons
                  value={value.publicityRightsPresentEnabled}
                  onChange={v => this.onChange('publicityRightsPresentEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.publicityRightsPresentEnabled}>
                <div>
                  <InputGroup>
                    <Label />
                    <SelectInput
                      value={value.publicityRightsPresent}
                      options={publicityRights.map(r => ({ label: r, value: r }))}
                      onChange={v => this.onChange('publicityRightsPresent', v)}
                    />
                  </InputGroup>
                </div>
              </Collapse>

              <InputGroup>
                <Label>Are trademarks prominently visible?</Label>
                <BooleanRadioButtons
                  value={value.trademarksProminentlyVisible}
                  onChange={v => this.onChange('trademarksProminentlyVisible', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Is material sensitive in nature?</Label>
                <BooleanRadioButtons
                  value={value.sensitiveInNature}
                  onChange={v => this.onChange('sensitiveInNature', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Are there privacy concerns?</Label>
                <BooleanRadioButtons
                  value={value.privacyConcerns}
                  onChange={v => this.onChange('privacyConcerns', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Are children materially identifiable in work?</Label>
                <BooleanRadioButtons
                  value={value.childrenMateriallyIdentifiableInWork}
                  onChange={v => this.onChange('childrenMateriallyIdentifiableInWork', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>Are there VARA (Visual Artists Rights Act of 1990) rights concerns?</Label>
                <BooleanRadioButtons
                  value={value.varaRightsConcerns}
                  onChange={v => this.onChange('varaRightsConcerns', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label>
                  If legal restrictions apply or require additional explanation, describe in a note
                </Label>
                <TextAreaInput value={value.note} onChange={v => this.onChange('note', v)} />
              </InputGroup>
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
