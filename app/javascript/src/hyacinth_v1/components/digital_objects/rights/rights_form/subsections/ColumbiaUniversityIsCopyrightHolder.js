import React from 'react';
import { Card, Collapse } from 'react-bootstrap';
import PropTypes from 'prop-types';
import produce from 'immer';

import InputGroup from '../../../../shared/forms/InputGroup';
import Label from '../../../../shared/forms/Label';
import BooleanRadioButtons from '../../../../shared/forms/inputs/BooleanRadioButtons';
import { useEnabled } from '../rightsHooks';
import Field from '../fields/Field';

function ColumbiaUniversityIsCopyrightHolder(props) {
  const { defaultValue, fieldConfig, values: [value], onChange } = props;

  const onChangeHandler = (fieldName, fieldVal) => {
    onChange(produce((draft) => {
      draft[0][fieldName] = fieldVal;
    }));
  };

  const [otherTransferEvidenceEnabled, setOtherTransferEvidenceEnabled] = useEnabled(
    value.other_transfer_evidence, () => onChangeHandler('other_transfer_evidence', ''),
  );

  const [transferDocumentionEnabled, setTransferDocumentionEnabled] = useEnabled(
    value.transfer_documentation, () => onChangeHandler('transfer_documentation', ''),
  );

  const clear = () => {
    onChange([{ ...defaultValue }]);
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
            <Field
              value={value.date_of_transfer}
              onChange={v => onChangeHandler('date_of_transfer', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'date_of_transfer')}
            />

            <Field
              value={value.date_of_expiration}
              onChange={v => onChangeHandler('date_of_expiration', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'date_of_expiration')}
            />

            <InputGroup>
              <Label sm={4} align="right">Transfer Document to Columbia University Exists</Label>
              <BooleanRadioButtons
                value={transferDocumentionEnabled}
                onChange={setTransferDocumentionEnabled}
              />
            </InputGroup>

            <Collapse in={transferDocumentionEnabled}>
              <div>
                <Field
                  value={value.transfer_documentation}
                  onChange={v => onChangeHandler('transfer_documentation', v)}
                  dynamicField={fieldConfig.children.find(c => c.stringKey === 'transfer_documentation')}
                />
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
                    <Field
                      value={value.other_transfer_evidence}
                      onChange={v => onChangeHandler('other_transfer_evidence', v)}
                      dynamicField={fieldConfig.children.find(c => c.stringKey === 'other_transfer_evidence')}
                    />
                  </div>
                </Collapse>
              </div>
            </Collapse>

            <Field
              value={value.transfer_documentation_note}
              onChange={v => onChangeHandler('transfer_documentation_note', v)}
              dynamicField={fieldConfig.children.find(c => c.stringKey === 'transfer_documentation_note')}
            />
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
