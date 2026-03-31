import { QueryClient } from '@tanstack/react-query';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { getProjectsQueryOptions } from '@/features/projects/api/get-projects';
import { PublishTargetForm } from '@/features/publish-targets/components/publish-target-form';
import { Container, Row, Col } from 'react-bootstrap';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  // No need to wait on this data as it's only needed for the projects dropdown
  queryClient.prefetchQuery(getProjectsQueryOptions());
};

const PublishTargetsNewRoute = () => {
  return (
    <Container>
      <Row>
        <Col md={8} className='g-0'>
          <PublishTargetForm />
        </Col>
      </Row>
    </Container>
  );
};

export default PublishTargetsNewRoute;