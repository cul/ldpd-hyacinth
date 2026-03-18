import { Row, Col, Container } from 'react-bootstrap';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { QueryClient } from '@tanstack/react-query';
import { getPublishTargetsQueryOptions } from '@/features/publish-targets/api/get-publish-targets';
import PublishTargetsList from '@/features/publish-targets/components/publish-targets-list';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const query = getPublishTargetsQueryOptions();

  return (
    queryClient.getQueryData(query.queryKey) ??
    (await queryClient.fetchQuery(query))
  );
};

const PublishTargetsIndexRoute = () => {
  return (
    <Container>
      <Row>
        <h3 className="mb-4">Publish Targets</h3>
        <PublishTargetsList />
      </Row>
    </Container>
  );
};

export default PublishTargetsIndexRoute;