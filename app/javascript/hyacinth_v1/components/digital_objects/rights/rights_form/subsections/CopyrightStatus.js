import React from 'react';
import PropTypes from 'prop-types';
import { Card } from 'react-bootstrap';
import produce from 'immer';


import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import TermSelect from '../../../../shared/forms/inputs/TermSelect';
import YesNoSelect from '../../../../shared/forms/inputs/YesNoSelect';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';

function CopyrightStatus(props) {
  const { title, values: [value], onChange } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>{title || 'Copyright Status'}</Card.Title>

        <InputGroup>
          <Label sm={4} align="right">Copyright Statement</Label>
          <TermSelect
            vocabulary="rights_statement"
            value={value.copyrightStatement}
            onChange={v => onChangeHandler('copyrightStatement', v)}
          />
        </InputGroup>


        <InputGroup>
          <Label sm={4} align="right">Copyright Note</Label>
          <TextAreaInput
            value={value.note}
            onChange={v => onChangeHandler('note', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label sm={4} align="right">Copyright Registered?</Label>
          <YesNoSelect
            value={value.copyrightRegistered}
            onChange={v => onChangeHandler('copyrightRegistered', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label sm={4} align="right">Copyright Renewed?</Label>
          <YesNoSelect
            value={value.copyrightRenewed}
            onChange={v => onChangeHandler('copyrightRenewed', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label sm={4} align="right">If Renewed, Date of Renewal</Label>
          <DateInput
            value={value.copyrightDateOfRenewal}
            onChange={v => onChangeHandler('copyrightDateOfRenewal', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label sm={4} align="right">Copyright Expiration Date</Label>
          <DateInput
            value={value.copyrightExpirationDate}
            onChange={v => onChangeHandler('copyrightExpirationDate', v)}
          />
        </InputGroup>

        <InputGroup>
          <Label sm={4} align="right">CUL Copyright Assessment Date</Label>
          <DateInput
            value={value.culCopyrightAssessmentDate}
            onChange={v => onChangeHandler('culCopyrightAssessmentDate', v)}
          />
        </InputGroup>
      </Card.Body>
    </Card>
  );
}

CopyrightStatus.defaultProps = {
  title: null,
};

CopyrightStatus.propTypes = {
  onChange: PropTypes.func.isRequired,
  title: PropTypes.string,
};

export default CopyrightStatus;
