import React from 'react';

import Label from '../../../../shared/forms/Label';
import InputGroup from '../../../../shared/forms/InputGroup';
import TextInput from '../../../../shared/forms/inputs/TextInput';
import TextAreaInput from '../../../../shared/forms/inputs/TextAreaInput';
import SelectInput from '../../../../shared/forms/inputs/SelectInput';
import TermSelect from '../../../../shared/forms/inputs/TermSelect';
import DateInput from '../../../../shared/forms/inputs/DateInput';
import NumberInput from '../../../../shared/forms/inputs/NumberInput';
import Checkbox from '../../../../shared/forms/inputs/Checkbox';

/* This is a copy of the class for the metadata form, these can be merged later when the use the same strategy to update state */

class Field extends React.PureComponent {
  render() {
    const {
      onChange, value, dynamicField, dynamicField: { displayLabel, fieldType },
    } = this.props;

    let field = '';

    const sharedProps = { sm: 8, onChange, value };

    switch (fieldType) {
      case 'string':
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
        <Label sm={4} align="right">{displayLabel}</Label>
        {field}
      </InputGroup>
    );
  }
}

export default Field;
