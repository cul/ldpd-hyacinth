import Select, { MultiValue } from 'react-select';
import { SelectOption } from './autocomplete-select';

interface AutocompleteMultiSelectProps {
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
      styles={{
        control: (base, state) => ({
          ...base,
          borderColor: state.isFocused ? '#d19edf' : '#dee2e6',
          boxShadow: state.isFocused ? '0 0 0 0.25rem rgba(209, 158, 223, 0.25)' : 'none',

          '&:hover': {
            borderColor: 'none',
          },
          "&--is-focused": {
            borderColor: 'none',
            boxShadow: '0 0 0 0.25rem rgba(163, 61, 191, 0.25)',
          },
        }),
        menuPortal: (base) => ({ ...base, zIndex: 9999 }),
      }}
    />
  );
};