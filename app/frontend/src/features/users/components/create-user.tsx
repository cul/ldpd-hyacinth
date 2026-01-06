import { UserForm } from '@/features/users/components/user-form';
import { Col, Container, Row } from 'react-bootstrap';

export const CreateUser = () => {
  return (
    <Container>
      <Row>
        <Col md={8}>
          <UserForm />
        </Col>
      </Row>
    </Container>
  );
}