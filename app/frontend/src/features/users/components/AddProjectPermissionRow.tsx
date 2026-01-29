import { useState } from 'react'
import { Button } from 'react-bootstrap';
import AutocompleteSelect from '@/components/ui/AutocompleteSelect';
import { Project, ProjectPermission } from '@/types/api';

type AddProjectPermissionRowProps = {
  onAddProject: (newPermission: ProjectPermission) => void;
  unassignedProjects: Project[];
};

export default function AddProjectPermissionRow({ unassignedProjects, onAddProject }: AddProjectPermissionRowProps) {
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');

  const handleAddProject = () => {
    if (!selectedProjectId) return;

    const project = unassignedProjects.find((project) => project.id === parseInt(selectedProjectId));

    if (project) {
      const newPermission: ProjectPermission = {
        projectId: project.id,
        projectStringKey: project.stringKey,
        projectDisplayLabel: project.displayLabel,
        canRead: true,
        canCreate: false,
        canUpdate: false,
        canDelete: false,
        canPublish: false,
        isProjectAdmin: false,
      };

      onAddProject(newPermission);
      setSelectedProjectId('');
    }
  };

  if (unassignedProjects.length === 0) return null;

  return (
    <tr>
      <td className="border-end-0 px-2 py-3 align-middle">
        <AutocompleteSelect
          options={unassignedProjects.map((project) => ({
            value: project.id.toString(),
            label: project.displayLabel,
          }))}
          value={selectedProjectId || null}
          onChange={(value) => setSelectedProjectId(value || '')}
          placeholder='Select a project'
        />
      </td>
      <td colSpan={7} className="align-middle border-start-0">
        <Button
          size="sm"
          variant="secondary"
          onClick={handleAddProject}
          disabled={!selectedProjectId}
        >
          Add Project
        </Button>
      </td>
    </tr>
  );
}