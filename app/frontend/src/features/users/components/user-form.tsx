import { useState, useEffect } from 'react';
import { Button, Col, Form, Row } from 'react-bootstrap';
import { useCreateUser } from '../api/create-user';
import { useUpdateUser } from '../api/update-user';
import { MutationAlerts } from './mutation-alerts';

type UserFormProps = {
  user?: {
    uid: string;
    firstName: string;
    lastName: string;
    email: string;
    isAdmin: boolean;
    canManageAllControlledVocabularies: boolean;
    accountType: string;
    isActive: boolean;
  };
  isEditingSelf?: boolean;
};

export const UserForm = ({ user, isEditingSelf }: UserFormProps) => {
  // Use existing user data for edit mode or default empty values for create mode
  const initialUser = user || {
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
  const createUserMutation = useCreateUser();
  const updateUserMutation = useUpdateUser();

  // Get the appropriate mutation and field errors based on mode
  const mutation = user ? updateUserMutation : createUserMutation;
  const fieldErrors = (mutation.error as any)?.response?.errors || {};

  // Update form data when user data is loaded
  useEffect(() => {
    if (user) {
      setFormData(user);
    }
  }, [user]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (user) {
      updateUserMutation.mutate({ userUid: user.uid, data: formData });
    } else {
      // ? Redirect to user list or detail page)
      createUserMutation.mutate({ data: formData });
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;

    // Clear all errors when user starts editing
    if (mutation.isError) {
      mutation.reset();
    }

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

  return (
    <>
      <MutationAlerts
        mutation={user ? updateUserMutation : createUserMutation}
        successMessage={user ? "User updated successfully!" : "User created successfully!"}
        errorMessage={user ? "Error updating user" : "Error creating user"}
      />
      <Form onSubmit={handleSubmit}>
        <div className="mb-3">
          <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-3">
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
                readOnly={!!user}
                disabled={!!user}
                isInvalid={!!fieldErrors.uid}
              />
              <Form.Control.Feedback type="invalid">
                {fieldErrors.uid?.join(', ')}
              </Form.Control.Feedback>
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
                disabled={isEditingSelf}
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
                isInvalid={!!fieldErrors.firstName}
              />
              <Form.Control.Feedback type="invalid">
                {fieldErrors.firstName?.join(', ')}
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group as={Col} controlId="formGridLastName">
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={formData.lastName}
                onChange={handleInputChange}
                placeholder="Enter last name"
                isInvalid={!!fieldErrors.lastName}
              />
              <Form.Control.Feedback type="invalid">
                {fieldErrors.lastName?.join(', ')}
              </Form.Control.Feedback>
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
              isInvalid={!!fieldErrors.email}
            />
            <Form.Control.Feedback type="invalid">
              {fieldErrors.email?.join(', ')}
            </Form.Control.Feedback>
          </Form.Group>
          <Form.Group className="mb-3" controlId="formGridAccountType">
            <Form.Label>Account Type</Form.Label>
            <Form.Select
              aria-label="Account Type"
              name="accountType"
              value={formData.accountType}
              onChange={handleSelectChange}
              isInvalid={!!fieldErrors.accountType}
            >
              {!user && <option value="">Choose account type</option>}
              <option value="standard">Standard</option>
              <option value="service">Service</option>
            </Form.Select>
            <Form.Control.Feedback type="invalid">
              {fieldErrors.accountType?.join(', ')}
            </Form.Control.Feedback>
          </Form.Group>
        </div>

        <Row className="mb-4">
          <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-2 mt-2">
            <small>Permissions</small>
          </p>
          <Form.Group controlId="formGridIsAdmin">
            <Form.Check
              type="checkbox"
              name="isAdmin"
              label="Is admin?"
              checked={formData.isAdmin}
              onChange={handleInputChange}
              disabled={isEditingSelf}
            />
            {(isEditingSelf && formData.isAdmin) && (
              <div className="text-muted mb-2">
                <Form.Text>
                  You cannot remove your own admin status.
                </Form.Text>
              </div>
            )}
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

        <Button
          variant="primary"
          type="submit"
          disabled={mutation.isPending}
        >
          {mutation.isPending ? 'Saving...' : 'Save'}
        </Button>
      </Form>
    </>
  );
}
