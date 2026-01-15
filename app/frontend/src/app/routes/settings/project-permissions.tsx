import { Row, Col, Container } from 'react-bootstrap';
import { QueryClient } from '@tanstack/react-query';
import { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/TableBuilder/table-builder';
import { useCurrentUser } from '@/lib/auth';
import { ProjectPermission } from '@/types/api';
import { getUserProjectsQueryOptions } from '@/features/users/api/get-user-projects';
import { readOnlyColumnDefs } from '@/features/users/components/project-permissions-column-defs';
import { useUserProjects } from '@/features/users/api/get-user-projects';
import { requireAuthorization } from '@/lib/loader-authorization';

export const clientLoader = (queryClient: QueryClient) => async () => {
  const currentUser = await requireAuthorization(queryClient);

  // Prefetch user's project permissions
  await queryClient.ensureQueryData(getUserProjectsQueryOptions(currentUser.uid));

  return { userUid: currentUser.uid };
};

const SettingsProjectPermissionsRoute = () => {
  const { data: currentUser } = useCurrentUser();
  const { data: projectPermissions, isLoading } = useUserProjects({
    userUid: currentUser!.uid
  });

  if (isLoading || !projectPermissions) {
    return <div>Loading permissions...</div>;
  }

  return (
    <Container>
      <Row>
        <Col>
          <h3 className="mb-4">My Project Permissions</h3>

          {/* Read-only display of permissions */}
          <TableBuilder data={projectPermissions} columns={readOnlyColumnDefs as ColumnDef<ProjectPermission>[]} />
        </Col>
      </Row>
    </Container>
  );
};

export default SettingsProjectPermissionsRoute;