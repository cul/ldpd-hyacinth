import React from 'react';

import Label from '../form/Label';
import InputGroup from '../form/InputGroup';
import TextInput from '../form/inputs/TextInput';
import TextAreaInput from '../form/inputs/TextAreaInput';
import SelectInput from '../form/inputs/SelectInput';
import ControlledVocabularySelect from '../form/inputs/ControlledVocabularySelect';
import DateInput from '../form/inputs/DateInput';
import NumberInput from '../form/inputs/NumberInput';
import Checkbox from '../form/inputs/Checkbox';

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
          <ControlledVocabularySelect
            vocabulary={dynamicField.controlledVocabulary.stringKey}
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
        field = <Checkbox checked{...sharedProps} />;
        break;
      default:
        break;
    }

    return (
      <InputGroup>
        <Label sm={2}>{displayLabel}</Label>
        {field}
      </InputGroup>
    );
  }
}

export default Field;
