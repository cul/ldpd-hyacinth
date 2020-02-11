import React from 'react';

import Label from '../../ui/forms/Label';
import InputGroup from '../../ui/forms/InputGroup';
import TextInput from '../../ui/forms/inputs/TextInput';
import TextAreaInput from '../../ui/forms/inputs/TextAreaInput';
import SelectInput from '../../ui/forms/inputs/SelectInput';
import TermSelect from '../../ui/forms/inputs/TermSelect';
import DateInput from '../../ui/forms/inputs/DateInput';
import NumberInput from '../../ui/forms/inputs/NumberInput';
import Checkbox from '../../ui/forms/inputs/Checkbox';

class Field extends React.PureComponent {
  render() {
    const { onChange, value, dynamicField, dynamicField: { displayLabel, fieldType } } = this.props;

    let field = '';

    const sharedProps = { onChange, value };

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
        <Label align="right">{displayLabel}</Label>
        {field}
      </InputGroup>
    );
  }
}

export default Field;
