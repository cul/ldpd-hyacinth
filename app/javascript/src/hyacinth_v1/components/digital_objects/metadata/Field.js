import React from 'react';

import Label from '../../shared/forms/Label';
import InputGroup from '../../shared/forms/InputGroup';
import TextInput from '../../shared/forms/inputs/TextInput';
import TextAreaInput from '../../shared/forms/inputs/TextAreaInput';
import SelectInput from '../../shared/forms/inputs/SelectInput';
import TermSelect from '../../shared/forms/inputs/TermSelect';
import DateInput from '../../shared/forms/inputs/DateInput';
import NumberInput from '../../shared/forms/inputs/NumberInput';
import Checkbox from '../../shared/forms/inputs/Checkbox';

let uniqueFieldIdCounter = 0;

const Field = (props) => {
  const {
    inputName, onChange, value, dynamicField, dynamicField: { displayLabel, fieldType }
  } = props;

  let field = '';

  const sharedProps = { onChange, value, inputName };
  sharedProps.inputName ||= `field-${uniqueFieldIdCounter ++}`;

  switch (fieldType) {
    case 'string':
      sharedProps.value ||= '';
      field = <TextInput {...sharedProps} />;
      break;
    case 'controlled_term':
      field = (
        <TermSelect
          vocabulary={dynamicField.controlledVocabulary}
          {...sharedProps}
        />
      );
      break;
    case 'textarea':
      field = <TextAreaInput {...sharedProps} />;
      break;
    case 'select':
      field = <SelectInput options={JSON.parse(dynamicField.selectOptions)} {...sharedProps} />;
      break;
    case 'date':
      field = <DateInput {...sharedProps} />;
      break;
    case 'integer':
      field = <NumberInput {...sharedProps} />;
      break;
    case 'boolean':
      field = <Checkbox checked {...sharedProps} />;
      break;
    default:
      break;
  }

  return (
    <InputGroup>
      <Label align="right" htmlFor={sharedProps.inputName}>{displayLabel}</Label>
      {field}
    </InputGroup>
  );
};

export default Field;
