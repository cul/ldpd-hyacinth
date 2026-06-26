import { Button, ButtonGroup } from 'react-bootstrap';

interface StatusFilterProps {
  active: string | null;
  options: string[];
  onChange: (status: string | null) => void;
}

export const StatusFilter = ({ active, options, onChange }: StatusFilterProps) => {
  return (
    <ButtonGroup className="mb-3" size="sm">
      <Button
        variant={active === null ? 'secondary' : 'outline-secondary'}
        onClick={() => onChange(null)}
      >
        All
      </Button>
      {options.map((status) => (
        <Button
          key={status}
          variant={active === status ? 'secondary' : 'outline-secondary'}
          onClick={() => onChange(status)}
          className="text-capitalize"
        >
          {status}
        </Button>
      ))}
    </ButtonGroup>
  );
};
