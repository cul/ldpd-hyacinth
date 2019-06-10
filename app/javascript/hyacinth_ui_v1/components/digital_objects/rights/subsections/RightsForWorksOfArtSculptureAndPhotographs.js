import React from 'react';
import { Card, Collapse } from 'react-bootstrap';

import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import TextAreaInputGroup from '../form_inputs/TextAreaInputGroup';
import SelectInputGroup from '../form_inputs/SelectInputGroup';

const publicityRights = [
  'Written Release',
  'Proof of Release in Written Form',
  'Conditional Release',
  'Partial Release',
  'No release',
];

export default class RightsForWorksOfArtSculptureAndPhotographs extends React.PureComponent {
  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>
            Other Rights Considerations for Works of Art, Sculpture, or Photographs
          </Card.Title>

          <BooleanInputGroup
            label="Are there other rights considerations for works of art, sculptures or photographs?"
            inputName="enabled"
            value={value.enabled}
            onChange={onChange}
          />
          <Collapse in={value.enabled}>
            <div>
              <BooleanInputGroup
                label="Are publicity rights present?"
                inputName="publicityRightsPresentEnabled"
                value={value.publicityRightsPresentEnabled}
                onChange={onChange}
              />
              <Collapse in={value.publicityRightsPresentEnabled}>
                <div>
                  <SelectInputGroup
                    label=""
                    value={value.publicityRightsPresent}
                    options={publicityRights.map(r => ({ label: r, value: r }))}
                    inputName="publicityRightsPresent"
                    onChange={onChange}
                  />
                </div>
              </Collapse>

              <BooleanInputGroup
                label="Are trademarks prominently visible?"
                inputName="trademarksProminentlyVisible"
                value={value.trademarksProminentlyVisible}
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Is material sensitive in nature?"
                inputName="sensitiveInNature"
                value={value.sensitiveInNature}
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Are there privacy concerns?"
                inputName="privacyConcerns"
                value={value.privacyConcerns}
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Are children materially identifiable in work?"
                inputName="childrenMateriallyIdentifiableInWork"
                value={value.childrenMateriallyIdentifiableInWork}
                onChange={onChange}
              />

              <BooleanInputGroup
                label="Are there VARA (Visual Artists Rights Act of 1990) rights concerns?"
                inputName="varaRightsConcerns"
                value={value.varaRightsConcerns}
                onChange={onChange}
              />

              <TextAreaInputGroup
                label="If legal restrictions apply or require additional explanation, describe in a note"
                inputName="note"
                value={value.note}
                onChange={onChange}
              />
            </div>
          </Collapse>
        </Card.Body>
      </Card>
    );
  }
}
