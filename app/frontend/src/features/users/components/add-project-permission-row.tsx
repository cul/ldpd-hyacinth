import AddItemTableRow from '@/components/ui/table-builder/add-item-table-row';
import { Project, ProjectPermission } from '@/types/api';

type AddProjectPermissionRowProps = {
  onAddProject: (newPermission: ProjectPermission) => void;
  unassignedProjects: Project[];
};

export const AddProjectPermissionRow = ({ unassignedProjects, onAddProject }: AddProjectPermissionRowProps) => {
  const handleAddProject = (selectedProjectId: string) => {
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
    }
  };

  return (
    <AddItemTableRow
      options={unassignedProjects.map((project) => ({
        value: project.id.toString(),
        label: project.displayLabel,
      }))}
      onAdd={handleAddProject}
      placeholder="Select a project"
      buttonLabel="Add Project"
      remainingColSpan={7}
    />
  );
}