import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import { defaultItemRights } from '../defaultRights';

const defaults = defaultItemRights.columbiaUniversityIsCopyrightHolder;

function ColumbiaUniversityIsCopyrightHolder(props) {
  const { values, values: [value], onChange } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [otherTransferEvidenceEnabled, setOtherTransferEvidenceEnabled] = useEnabled(
    value.otherTransferEvidence, () => onChangeHandler('otherTransferEvidence', ''),
  );

  const [transferDocumentionEnabled, setTransferDocumentionEnabled] = useEnabled(
    value.transferDocumentation, () => onChangeHandler('transferDocumentation', ''),
  );

  const clear = () => {
    onChange([{ ...defaults[0] }]);
    setOtherTransferEvidenceEnabled(false);
    setTransferDocumentionEnabled(false);
  };

  const [enabled, setEnabled] = useEnabled(
    value, clear,
  );

  return (
    <Card className="mb-3">
      <Card.Body>
        <Card.Title>
           Columbia University Is Copyright Holder
        </Card.Title>

        <InputGroup>
          <Label sm={4} align="right">Was copyright transferred to Columbia University from a Third Party?</Label>
          <BooleanRadioButtons value={enabled} onChange={setEnabled} />
        </InputGroup>

        <Collapse in={enabled}>
          <div>
            <InputGroup>
              <Label sm={4} align="right">Date of Transfer</Label>
              <DateInput value={value.dateOfTransfer} onChange={v => onChangeHandler('dateOfTransfer', v)} />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Date of Expiration of Columbia Copyright (if known)</Label>
              <DateInput value={value.dateOfExpiration} onChange={v => onChangeHandler('dateOfExpiration', v)} />
            </InputGroup>

            <InputGroup>
              <Label sm={4} align="right">Transfer Document to Columbia University Exists</Label>
              <BooleanRadioButtons
                value={transferDocumentionEnabled}
                onChange={setTransferDocumentionEnabled}
              />
            </InputGroup>

            <Collapse in={transferDocumentionEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} align="right">Transfer Documentation</Label>
                  <TextInput
                    sm={8}
                    value={value.transferDocumentation}
                    onChange={v => onChangeHandler('transferDocumentation', v)}
                  />
                </InputGroup>
              </div>
            </Collapse>

            <Collapse in={!transferDocumentionEnabled}>
              <div>
                <InputGroup>
                  <Label sm={4} align="right">Does Other Evidence of Transfer Exist?</Label>
                  <BooleanRadioButtons
                    value={otherTransferEvidenceEnabled}
                    onChange={v => setOtherTransferEvidenceEnabled(v)}
                  />
                </InputGroup>

                <Collapse in={otherTransferEvidenceEnabled}>
                  <div>
                    <InputGroup>
                      <Label sm={4} align="right">Evidence of Transfer Documentation</Label>
                      <TextInput
                        sm={8}
                        value={value.otherTransferEvidence}
                        onChange={v => onChangeHandler('otherTransferEvidence', v)}
                      />
                    </InputGroup>
                  </div>
                </Collapse>
              </div>
            </Collapse>

            <InputGroup>
              <Label sm={4} align="right">Transfer Documentation Note</Label>
              <TextInput
                sm={8}
                value={value.transferDocumentationNote}
                onChange={v => onChangeHandler('transferDocumentationNote', v)}
              />
            </InputGroup>
          </div>
        </Collapse>
      </Card.Body>
    </Card>
  );
}

ColumbiaUniversityIsCopyrightHolder.propTypes = {
  values: PropTypes.arrayOf(PropTypes.any).isRequired,
  onChange: PropTypes.func.isRequired,
};

export default ColumbiaUniversityIsCopyrightHolder;
