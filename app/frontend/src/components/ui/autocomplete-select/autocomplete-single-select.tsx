import Select, { SingleValue } from 'react-select';
import { sharedStyles } from './shared-styles';
import { SelectOption } from './types';

type AutocompleteSelectProps = {
  options: SelectOption[];
  value?: string | null;
  onChange?: (value: string | null) => void;
  placeholder?: string;
}

export const AutocompleteSingleSelect = ({
  options,
  value,
  onChange,
  placeholder = 'Select...'
}: AutocompleteSelectProps) => {
  const selectedOption = value ? options.find(option => option.value === value) : null;

  const handleChange = (newValue: SingleValue<SelectOption>) => {
    onChange?.(newValue?.value ?? null);
  };

  return (
    <Select<SelectOption>
      value={selectedOption}
      onChange={handleChange}
      options={options}
      placeholder={placeholder}
      isClearable
      classNamePrefix="react-select"
      // Ensure the dropdown menu appears above other content, 
      // especially when used in tables
      menuPortalTarget={document.body}
      menuPosition="fixed"
      styles={sharedStyles}
    />
  );
}