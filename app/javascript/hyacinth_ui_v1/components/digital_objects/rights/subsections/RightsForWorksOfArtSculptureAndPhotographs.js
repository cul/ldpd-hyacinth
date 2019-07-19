import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import produce from 'immer';

import Label from '../../../ui/forms/Label';
import InputGroup from '../../../ui/forms/InputGroup';
import BooleanRadioButtons from '../../../ui/forms/inputs/BooleanRadioButtons';
import SelectInput from '../../../ui/forms/inputs/SelectInput';
import TextAreaInput from '../../../ui/forms/inputs/TextAreaInput';
import YesNoSelect from '../../../ui/forms/inputs/YesNoSelect';

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
            <Label sm={4} align="right">
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
                <Label sm={4} align="right">Are publicity rights present?</Label>
                <BooleanRadioButtons
                  value={value.publicityRightsPresentEnabled}
                  onChange={v => this.onChange('publicityRightsPresentEnabled', v)}
                />
              </InputGroup>

              <Collapse in={value.publicityRightsPresentEnabled}>
                <div>
                  <InputGroup>
                    <Label sm={4}/>
                    <SelectInput
                      sm={8}
                      value={value.publicityRightsPresent}
                      options={publicityRights.map(r => ({ label: r, value: r }))}
                      onChange={v => this.onChange('publicityRightsPresent', v)}
                    />
                  </InputGroup>
                </div>
              </Collapse>

              <InputGroup>
                <Label sm={4} align="right">Are trademarks prominently visible?</Label>
                <YesNoSelect
                  value={value.trademarksProminentlyVisible}
                  onChange={v => this.onChange('trademarksProminentlyVisible', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">Is material sensitive in nature?</Label>
                <YesNoSelect
                  value={value.sensitiveInNature}
                  onChange={v => this.onChange('sensitiveInNature', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">Are there privacy concerns?</Label>
                <YesNoSelect
                  value={value.privacyConcerns}
                  onChange={v => this.onChange('privacyConcerns', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">Are children materially identifiable in work?</Label>
                <YesNoSelect
                  value={value.childrenMateriallyIdentifiableInWork}
                  onChange={v => this.onChange('childrenMateriallyIdentifiableInWork', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">Are there VARA (Visual Artists Rights Act of 1990) rights concerns?</Label>
                <YesNoSelect
                  value={value.varaRightsConcerns}
                  onChange={v => this.onChange('varaRightsConcerns', v)}
                />
              </InputGroup>

              <InputGroup>
                <Label sm={4} align="right">
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
