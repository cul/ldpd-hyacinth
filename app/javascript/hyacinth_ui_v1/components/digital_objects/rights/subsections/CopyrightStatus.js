import React from 'react';
import { Card } from 'react-bootstrap';

import BooleanInputGroup from '../form_inputs/BooleanInputGroup';
import DateInputGroup from '../form_inputs/DateInputGroup';
import ReadOnlyInputGroup from '../form_inputs/ReadOnlyInputGroup';

class CopyrightStatus extends React.PureComponent {
  render() {
    const { value, onChange } = this.props;

    return (
      <Card className="mb-3">
        <Card.Body>
          <Card.Title>Copyright Status</Card.Title>

          <ReadOnlyInputGroup label="Copyright Statement" value={value.copyrightStatement} />

          {
            value.copyrightNote
              .map(t => <ReadOnlyInputGroup label="Copyright Note" value={t} />)
          }

          <BooleanInputGroup
            label="Copyright Registered?"
            inputName="copyrightRegistered"
            value={value.copyrightRegistered}
            onChange={onChange}
          />

          <BooleanInputGroup
            label="Copyright Renewed?"
            inputName="copyrightRenewed"
            value={value.copyrightRenewed}
            onChange={onChange}
          />

          <DateInputGroup
            label="If Renewed, Date of Renewal"
            inputName="copyrightDateOfRenewal"
            value={value.copyrightDateOfRenewal}
            onChange={onChange}
          />

          <DateInputGroup
            label="Copyright Expiration Date"
            inputName="copyrightExpirationDate"
            value={value.copyrightExpirationDate}
            onChange={onChange}
          />

          <DateInputGroup
            label="CUL Copyright Assessment Date"
            inputName="culCopyrightAssessmentDate"
            value={value.culCopyrightAssessmentDate}
            onChange={onChange}
          />
        </Card.Body>
      </Card>
    );
  }
}

export default CopyrightStatus;
