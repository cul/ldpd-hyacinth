import { useState, useMemo } from 'react';
import { Button,Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel, getSortedRowModel, SortingState } from '@tanstack/react-table';
import { AutocompleteSingleSelect } from '@/components/ui/autocomplete-select';
import { useProjectsSuspenseQuery } from '@/features/projects/api/get-projects';
import { columnDefs } from '../utils/target-projects-column-defs';
import TableHeader from '@/components/ui/table-builder/table-header';
import TableRow from '@/components/ui/table-builder/table-row';

type ProjectsForTargetSelectorProps = {
  selectedProjectIds: number[];
  onChange: (ids: number[]) => void;
};

export const ProjectsForTargetSelector = ({ selectedProjectIds, onChange }: ProjectsForTargetSelectorProps) => {
  const { data } = useProjectsSuspenseQuery();
  const [selectedProjectToAdd, setSelectedProjectToAdd] = useState<string>('');
  const [sorting, setSorting] = useState<SortingState>([]);

  const selectedProjects = useMemo(() => {
    return data.projects.filter(p => selectedProjectIds.includes(p.id));
  }, [data.projects, selectedProjectIds]);

  const unassignedProjects = useMemo(() => {
    const assignedIds = new Set(selectedProjectIds);
    return data.projects.filter(p => !assignedIds.has(p.id));
  }, [data.projects, selectedProjectIds]);

  const handleAddProject = () => {
    if (!selectedProjectToAdd) return;

    const projectId = Number(selectedProjectToAdd);
    onChange([...selectedProjectIds, projectId]);
    setSelectedProjectToAdd('');
  };

  const handleRemoveProject = (rowIndex: number) => {
    const project = selectedProjects[rowIndex];
    if (project) {
      onChange(selectedProjectIds.filter(id => id !== project.id));
    }
  };

  const handleClearAll = () => {
    onChange([]);
  };

  const table = useReactTable({
    data: selectedProjects,
    columns: columnDefs,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    meta: {
      removeRow: handleRemoveProject,
    },
    state: { sorting },
    onSortingChange: setSorting,
  });

  return (
    <>
      <div className="d-flex justify-content-between align-items-center mb-2">
        <small className="text-muted">
          {selectedProjects.length} {selectedProjects.length === 1 ? 'project' : 'projects'} selected
        </small>
        {selectedProjects.length > 0 && (
          <Button
            variant="link"
            size="sm"
            className="text-muted p-0"
            onClick={handleClearAll}
          >
            Clear All
          </Button>
        )}
      </div>

      <BTable striped bordered hover responsive size="sm">
        {table.getHeaderGroups().map((headerGroup) => (
          <TableHeader key={headerGroup.id} headerGroup={headerGroup} />
        ))}
        <tbody>
          {unassignedProjects.length > 0 && (
            <tr>
              <td className="border-end-0 px-2 py-3 align-middle w-50">
                <AutocompleteSingleSelect
                  options={unassignedProjects.map(p => ({
                    value: p.id.toString(),
                    label: p.displayLabel,
                  }))}
                  value={selectedProjectToAdd || null}
                  onChange={(value) => setSelectedProjectToAdd(value || '')}
                  placeholder="Search projects to add..."
                />
              </td>

              <td colSpan={7} className="align-middle border-start-0">
                <Button
                  size="sm"
                  variant="secondary"
                  onClick={handleAddProject}
                  disabled={!selectedProjectToAdd}
                >
                  Add Project
                </Button>
              </td>
            </tr>
          )}

          {selectedProjects.length === 0 && (
            <tr>
              <td colSpan={3} className="text-center text-muted py-3">
                No projects associated with this publish target.
              </td>
            </tr>
          )}
          {table.getRowModel().rows.map((row) => (
            <TableRow row={row} key={row.id} />
          ))}
        </tbody>
      </BTable>
    </>
  );
};