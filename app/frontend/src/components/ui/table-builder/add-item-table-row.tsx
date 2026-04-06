import { useState } from 'react';
import { Button } from 'react-bootstrap';
import { AutocompleteSingleSelect } from '@/components/ui/autocomplete-select';
import { SelectOption } from '@/components/ui/autocomplete-select/types';

type AddItemTableRowProps = {
  options: SelectOption[];
  onAdd: (selectedValue: string) => void;
  placeholder?: string;
  buttonLabel?: string;
  remainingColSpan?: number;
};

/**
 * A generic table row with an autocomplete select input and an "Add" button.
 * Designed to be used as the first row in editable TanStack tables.
 *
 * When no options are available, renders nothing.
 */
const AddItemTableRow = ({
  options,
  onAdd,
  placeholder = 'Select...',
  buttonLabel = 'Add',
  remainingColSpan = 1,
}: AddItemTableRowProps) => {
  const [selectedValue, setSelectedValue] = useState<string>('');

  const handleAdd = () => {
    if (!selectedValue) return;
    onAdd(selectedValue);
    setSelectedValue('');
  };

  if (options.length === 0) return null;

  return (
    <tr>
      <td className="border-end-0 px-2 py-3 align-middle">
        <AutocompleteSingleSelect
          options={options}
          value={selectedValue || null}
          onChange={(value) => setSelectedValue(value || '')}
          placeholder={placeholder}
        />
      </td>
      <td colSpan={remainingColSpan} className="align-middle border-start-0">
        <Button
          size="sm"
          variant="secondary"
          onClick={handleAdd}
          disabled={!selectedValue}
        >
          {buttonLabel}
        </Button>
      </td>
    </tr>
  );
};

export default AddItemTableRow;
