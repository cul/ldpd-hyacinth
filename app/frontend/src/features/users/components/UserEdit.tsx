import { Row, Col, Container, Spinner } from 'react-bootstrap';
import { useUser } from '../api/get-user';
import UserForm from './UserForm';
import UserAPIKeyGenerationForm from './UserApiKeyGenerationForm';

export default function UserEdit({ userUid }: { userUid: string }) {
  const userQuery = useUser({
    userUid,
  });

  if (userQuery.isLoading) {
    return <Spinner />;
  }

  const user = userQuery?.data?.user;

  if (!user) return null;

  return (
    <Container>
      <Row>
        <Col md={7}>
          <UserForm user={user} />
        </Col>
        <Col md={{ span: 4, offset: 1 }} className="border-start ps-4">
          <UserAPIKeyGenerationForm userUid={user.uid} apiKeyDigest={user.apiKeyDigest} />
        </Col>
      </Row>
    </Container>
  );
};
