import { useState, useEffect } from 'react';
import Container from 'react-bootstrap/Container';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import { useUser } from '../api/get-user';
import { useCreateUser } from '../api/create-user';
import { useUpdateUser } from '../api/update-user';

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
  const initialUser = userQuery?.data?.user || {
    uid: '',
    firstName: '',
    lastName: '',
    email: '',
    isAdmin: false,
    canManageAllControlledVocabularies: false,
    accountType: '',
    isActive: true,
  };

  const [formData, setFormData] = useState(initialUser);

  // Update form data when user data is loaded
  useEffect(() => {
    if (userQuery?.data?.user) {
      setFormData(userQuery.data.user);
    }
  }, [userQuery?.data?.user]);

  const createUserMutation = useCreateUser({
    mutationConfig: {
      onSuccess: () => {
        alert('User created successfully!');
      },
      onError: (error: any) => {
        alert(`Error creating user: ${error.message || 'Unknown error'}`);
      },
    },
  });

  const updateUserMutation = useUpdateUser({
    mutationConfig: {
      onSuccess: () => {
        alert('User updated successfully!');
      },
      onError: (error: any) => {
        alert(`Error updating user: ${error.message || 'Unknown error'}`);
      },
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (userUid) {
      updateUserMutation.mutate({ userUid, data: formData });
    } else {
      createUserMutation.mutate({ data: formData });
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  // const api_key_display = initialUser.api_key_digest ? (
  //   <div className="alert alert-info">
  //     An API key is currently set for this user.
  //   </div>
  // ) : (
  //   <div className="alert alert-info">
  //     An API key is not currently set for this user.
  //   </div>
  // );

  return (
    <Container> {/* Move to its own layout? */}
      <Row>
        <Col md={{ span: 7 }}>
          <Form onSubmit={handleSubmit}>
            <p className="text-muted fw-bold text-uppercase">
              <small>User information</small>
            </p>
            <Row className="mb-3">
              <Form.Group as={Col} md={6} controlId="formGridUID">
                <Form.Label>UID</Form.Label>
                <Form.Control
                  type="text"
                  name="uid"
                  placeholder="UID"
                  value={formData.uid}
                  onChange={handleInputChange}
                  readOnly={!!userUid}
                  disabled={!!userUid}
                />
              </Form.Group>
            </Row>
            <Row className="mb-3">
              <Form.Group controlId="formGridIsActive">
                <Form.Check
                  type="checkbox"
                  name="isActive"
                  label="Is active?"
                  checked={formData.isActive}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Row>
            <Row className="mb-3">
              <Form.Group as={Col} controlId="formGridFirstName">
                <Form.Label>First Name</Form.Label>
                <Form.Control
                  type="text"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleInputChange}
                  placeholder="Enter first name"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridLastName">
                <Form.Label>Last Name</Form.Label>
                <Form.Control
                  type="text"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleInputChange}
                  placeholder="Enter last name"
                />
              </Form.Group>
            </Row>

            <Form.Group className="mb-3" controlId="formGridEmail">
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                placeholder="Email"
              />
            </Form.Group>

            <Row className="mb-3">
              <p className="text-muted fw-bold text-uppercase">
                <small>Permissions</small>
              </p>
              <Form.Group controlId="formGridIsAdmin">
                <Form.Check
                  type="checkbox"
                  name="isAdmin"
                  label="Is admin?"
                  checked={formData.isAdmin}
                  onChange={handleInputChange}
                />
              </Form.Group>
              <Form.Group controlId="formGridCanManageControlledVocabularies">
                <Form.Check
                  type="checkbox"
                  name="canManageAllControlledVocabularies"
                  label="Can Manage Controlled Vocabularies?"
                  checked={formData.canManageAllControlledVocabularies}
                  onChange={handleInputChange}
                />
              </Form.Group>
            </Row>

            <Form.Group as={Col} className="mb-3" controlId="formGridAccountType">
              <Form.Label>Account Type</Form.Label>
              <Form.Select
                aria-label="Account Type"
                className="mb-3"
                name="accountType"
                value={formData.accountType}
                onChange={handleSelectChange}
              >
                {!userUid && <option value="">Choose account type</option>}
                <option value="standard">Standard</option>
                <option value="service">Service</option>
              </Form.Select>
            </Form.Group>
            <Button
              variant="primary"
              type="submit"
              disabled={createUserMutation.isPending || updateUserMutation.isPending}
            >
              {createUserMutation.isPending || updateUserMutation.isPending ? 'Saving...' : 'Save'}
            </Button>
          </Form>
        </Col>
        {/* TODO: Extract API key request component + create a new mutation */}
        {/* {userUid && (
          <Col md={{ span: 4, offset: 1 }} style={{ borderLeft: '1px solid #ddd', paddingLeft: '20px' }}>
            <p className="text-muted fw-bold text-uppercase">
              <small>Request API key</small>
            </p>
            <p>Describe how this API key might be used. Do you need to regenerate a new one every x hours?</p>
            {api_key_display}
            <Button variant="secondary">Request API Key</Button>
          </Col>
        )} */}
      </Row>
    </Container>
  )
}
