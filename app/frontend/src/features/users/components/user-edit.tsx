import { Row, Col, Container } from 'react-bootstrap';
import { useUser } from '../api/get-user';
import { UserForm } from './user-form';
import { UserAPIKeyGenerationForm } from './user-api-key-generation-form';

export const UserEdit = ({ userUid }: { userUid: string }) => {
  const userQuery = useUser({
    userUid,
  });

  if (userQuery.isLoading) {
    return (
      <div>
        Loading...
      </div>
    );
  }

  const user = userQuery?.data?.user;

  if (!user) return null;

  return (
    <Container>
      <Row>
        <Col md={7}>
          <UserForm user={user} />
        </Col>
        <Col md={{ span: 4, offset: 1 }} style={{ borderLeft: '1px solid #ddd', paddingLeft: '20px' }}>
          <UserAPIKeyGenerationForm userUid={user.uid} apiKeyDigest={user.apiKeyDigest} />
        </Col>
      </Row>
    </Container>
  );
};
