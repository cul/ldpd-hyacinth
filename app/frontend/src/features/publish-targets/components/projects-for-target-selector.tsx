import { AutocompleteMultiSelect } from '@/components/ui/autocomplete-select';
import { useProjectsSuspenseQuery } from '@/features/projects/api/get-projects';

type ProjectsMultiSelectProps = {
  selectedProjectIds: number[];
  onChange: (ids: number[]) => void;
};

export const ProjectsForTargetSelector = ({ selectedProjectIds, onChange }: ProjectsMultiSelectProps) => {
  const { data } = useProjectsSuspenseQuery();

  const options = data.projects.map(project => ({
    value: project.id.toString(),
    label: project.displayLabel,
  }));

  return (
    <AutocompleteMultiSelect
      options={options}
      value={selectedProjectIds.map(String)}
      onChange={(values) => onChange(values.map(Number))}
      placeholder="Search projects..."
    />
  );
};