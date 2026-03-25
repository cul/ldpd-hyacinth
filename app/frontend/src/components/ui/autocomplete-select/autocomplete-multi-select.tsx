import Select, { MultiValue } from 'react-select';
import { sharedStyles } from './shared-styles';
import { SelectOption } from './types';

type AutocompleteMultiSelectProps = {
  options: SelectOption[];
  value: string[];
  onChange: (values: string[]) => void;
  placeholder?: string;
}

export const AutocompleteMultiSelect = ({
  options,
  value,
  onChange,
  placeholder = 'Select...',
}: AutocompleteMultiSelectProps) => {
  const selectedOptions = options.filter(option => value.includes(option.value));

  const handleChange = (newValue: MultiValue<SelectOption>) => {
    onChange(newValue.map(option => option.value));
  };

  return (
    <Select<SelectOption, true>
      isMulti
      value={selectedOptions}
      onChange={handleChange}
      options={options}
      placeholder={placeholder}
      classNamePrefix="react-select"
      // Ensure the dropdown menu appears above other content, 
      // especially when used in tables
      menuPortalTarget={document.body}
      menuPosition="fixed"
      styles={sharedStyles}
    />
  );
};