import React from 'react';

import Label from '@hyacinth_v1/components/shared/forms/Label';
import InputGroup from '@hyacinth_v1/components/shared/forms/InputGroup';
import TextInput from '@hyacinth_v1/components/shared/forms/inputs/TextInput';
import TextAreaInput from '@hyacinth_v1/components/shared/forms/inputs/TextAreaInput';
import SelectInput from '@hyacinth_v1/components/shared/forms/inputs/SelectInput';
import TermSelect from '@hyacinth_v1/components/shared/forms/inputs/TermSelect';
import DateInput from '@hyacinth_v1/components/shared/forms/inputs/DateInput';
import NumberInput from '@hyacinth_v1/components/shared/forms/inputs/NumberInput';
import Checkbox from '@hyacinth_v1/components/shared/forms/inputs/Checkbox';

/* This is a copy of the class for the metadata form, these can be merged later when the use the same strategy to update state */

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
