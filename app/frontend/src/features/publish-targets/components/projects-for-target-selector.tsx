import { useState, useMemo } from 'react';
import { Button, Table as BTable } from 'react-bootstrap';
import { useReactTable, getCoreRowModel, getSortedRowModel, SortingState } from '@tanstack/react-table';
import { useProjectsSuspenseQuery } from '@/features/projects/api/get-projects';
import { columnDefs } from '../utils/target-projects-column-defs';
import AddItemTableRow from '@/components/ui/table-builder/add-item-table-row';
import TableHeader from '@/components/ui/table-builder/table-header';
import TableRow from '@/components/ui/table-builder/table-row';

type ProjectsForTargetSelectorProps = {
  selectedProjectIds: number[];
  onChange: (ids: number[]) => void;
};

export const ProjectsForTargetSelector = ({ selectedProjectIds, onChange }: ProjectsForTargetSelectorProps) => {
  const { data } = useProjectsSuspenseQuery();
  const [sorting, setSorting] = useState<SortingState>([]);

  const selectedProjects = useMemo(() => {
    return data.projects.filter(p => selectedProjectIds.includes(p.id));
  }, [data.projects, selectedProjectIds]);

  const unassignedProjects = useMemo(() => {
    const assignedIds = new Set(selectedProjectIds);
    return data.projects.filter(p => !assignedIds.has(p.id));
  }, [data.projects, selectedProjectIds]);

  const handleAddProject = (selectedValue: string) => {
    const projectId = Number(selectedValue);
    onChange([...selectedProjectIds, projectId]);
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
        <colgroup>
          <col style={{ width: '50%' }} />
          <col />
          <col style={{ width: '100px' }} />
        </colgroup>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableHeader key={headerGroup.id} headerGroup={headerGroup} />
        ))}
        <tbody>
          <AddItemTableRow
            options={unassignedProjects.map(p => ({
              value: p.id.toString(),
              label: p.displayLabel,
            }))}
            onAdd={handleAddProject}
            placeholder="Search projects to add..."
            buttonLabel="Add Project"
            remainingColSpan={2}
          />

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