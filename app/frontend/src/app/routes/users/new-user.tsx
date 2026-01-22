import { QueryClient } from '@tanstack/react-query';
import { Col, Container, Row } from 'react-bootstrap';
import { UserForm } from '@/features/users/components/user-form';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);
  return null;
};

const NewUserRoute = () => {
  return (
    <Container>
      <Row>
        <Col md={8}>
          <UserForm />
        </Col>
      </Row>
    </Container>
  )
};

export default NewUserRoute;