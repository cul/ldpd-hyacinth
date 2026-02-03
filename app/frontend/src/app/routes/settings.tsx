import { QueryClient } from '@tanstack/react-query';
import { Row, Col, Container } from 'react-bootstrap';
import { getUserQueryOptions } from '@/features/users/api/get-user';
import { useCurrentUser, AUTH_QUERY_KEY } from '@/lib/auth';
import { UserAPIKeyGenerationForm } from '@/features/users/components/user-api-key-generation-form';
import { UserForm } from '@/features/users/components/user-form';

// Prefetch the current user's full data
export const clientLoader = (queryClient: QueryClient) => async () => {
  // Get the current user UID from the auth query cache
  const authUser = queryClient.getQueryData(AUTH_QUERY_KEY) as any;

  if (!authUser?.uid) {
    return null;
  }

  const userQuery = getUserQueryOptions(authUser.uid);
  return (
    queryClient.getQueryData(userQuery.queryKey) ??
    (await queryClient.fetchQuery(userQuery))
  );
};

const SettingsRoute = () => {
  const user = useCurrentUser();

  if (!user.data) return null;

  return (
    <Container>
      <Row>
        <h3 className="mb-4">My Settings</h3>
        <Col md={7}>
          <UserForm user={user.data} />
        </Col>
        <Col md={{ span: 4, offset: 1 }} style={{ borderLeft: '1px solid #ddd', paddingLeft: '20px' }}>
          <UserAPIKeyGenerationForm userUid={user.data.uid} apiKeyDigest={user.data.apiKeyDigest} />
        </Col>
      </Row>
    </Container>
  );
};

export default SettingsRoute;