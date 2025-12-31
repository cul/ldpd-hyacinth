import Container from 'react-bootstrap/Container';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import { useUser } from '../api/get-user';

// TODO: Implement form submission handling, validation, and state management
export const UserForm = ({ userUid }: { userUid?: string }) => {
  const userQuery = useUser({
    userUid: userUid!,
    queryConfig: {
      enabled: !!userUid, // Only fetch if userUid is provided
    },
  });

  if (userQuery.isLoading) {
    return (
      <div>
        Loading...
      </div>
    );
  }

  // Use existing user data for edit mode or default empty values for create mode
  const user = userQuery?.data?.user || {
    uid: '',
    first_name: '',
    last_name: '',
    email: '',
    is_admin: false,
    can_manage_all_controlled_vocabularies: false,
    account_type: 0,
    is_active: true,
  };

  return (
    <Container> {/* Move to its own layout? */}
      <Row>
        <Col md={{ span: 7 }}>
          <Form>

            <p className="text-muted fw-bold text-uppercase">
              <small>User information</small>
            </p>
            <Row className="mb-3">
              <Form.Group as={Col} md={6} controlId="formGridUID">
                <Form.Label>UID</Form.Label>
                <Form.Control 
                  type="text" 
                  placeholder="UID" 
                  value={user.uid} 
                  readOnly={!!userUid} 
                  disabled={!!userUid} 
                />
              </Form.Group>
            </Row>
            <Row className="mb-3">
              <Form.Group as={Col} controlId="formGridFirstName">
                <Form.Label>First Name</Form.Label>
                <Form.Control type="text" value={user.first_name} placeholder="Enter first name" />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridLastName">
                <Form.Label>Last Name</Form.Label>
                <Form.Control type="text" value={user.last_name} placeholder="Enter last name" />
              </Form.Group>
            </Row>

            <Form.Group className="mb-3" controlId="formGridEmail">
              <Form.Label>Email</Form.Label>
              <Form.Control type="email" value={user.email} placeholder="Email" />
            </Form.Group>

            <Row className="mb-3">
              <p className="text-muted fw-bold text-uppercase">
                <small>Permissions</small>
              </p>
              <Form.Group controlId="formGridIsAdmin">
                <Form.Check type="checkbox" label="Is admin?" checked={user.is_admin} />
              </Form.Group>
              <Form.Group controlId="formGridCanManageControlledVocabularies">
                <Form.Check
                  type="checkbox"
                  label="Can Manage Controlled Vocabularies?"
                  checked={user.can_manage_all_controlled_vocabularies} />
              </Form.Group>
            </Row>

            <Form.Group as={Col} className="mb-3" controlId="formGridAccountType">
              <Form.Label>Account Type</Form.Label>
              <Form.Select aria-label="Account Type" className="mb-3" defaultValue={user.account_type.toString()}>
                <option>Choose account type</option>
                <option value="1">Service</option>
                <option value="2">Standard</option>
              </Form.Select>
            </Form.Group>

            <Button variant="primary" type="submit">
              Save
            </Button>
          </Form>
        </Col>
        <Col md={{ span: 4, offset: 1 }}>
          Request API key
        </Col>
      </Row>
    </Container>
  )
}
