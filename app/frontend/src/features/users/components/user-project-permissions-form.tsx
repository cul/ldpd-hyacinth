import React from 'react';
import { Alert, Spinner } from 'react-bootstrap';
import { useUserProjects } from '../api/get-user-projects';

export const UserProjectPermissionsForm: React.FC<any> = ({ userUid }) => {
  const userPermissionsQuery = useUserProjects({ userUid });

  if (userPermissionsQuery.isLoading) {
    return <Spinner />
  }

  const projects = userPermissionsQuery.data;
  console.log('User Projects:', projects);
  if (!projects) return null;

  return (
    <div>
      {projects.map((project: any) => (
        <div key={project.project_pid}>
          <strong>Project ID:</strong> {project.project_string_key} <br />
          <strong>Read:</strong> {project.can_read.toString()} <br />
          <strong>Write:</strong>: {project.can_update.toString()} <br />
          <strong>Create:</strong>: {project.can_create.toString()} <br />
          <strong>Publish:</strong>: {project.can_publish.toString()} <br />
          <strong>Is Admin:</strong>: {project.is_project_admin.toString()}
        </div>
      ))}
    </div>
  );
};