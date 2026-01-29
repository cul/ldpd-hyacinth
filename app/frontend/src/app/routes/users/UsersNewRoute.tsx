import { QueryClient } from '@tanstack/react-query';
import { Col, Container, Row } from 'react-bootstrap';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import UserForm from '@/features/users/components/UserForm';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);
  return null;
};

export const UsersNewRoute = () => {
  return (
    <Container>
      <Row>
        <Col md={8} className="px-0">
          <UserForm />
        </Col>
      </Row>
    </Container>);
};

export default UsersNewRoute;