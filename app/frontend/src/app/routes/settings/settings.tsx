import { Row, Col, Container } from 'react-bootstrap';
import { useCurrentUser } from '@/lib/auth';
import { UserAPIKeyGenerationForm } from '@/features/users/components/user-api-key-generation-form';
import { UserForm } from '@/features/users/components/user-form';

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