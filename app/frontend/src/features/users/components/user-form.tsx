import { useState } from 'react';
import { Button, Form, Row } from 'react-bootstrap';
import { useCreateUser } from '../api/create-user';
import { useUpdateUser } from '../api/update-user';
import { MutationAlerts } from './mutation-alerts';
import { Input, Select } from '@/components/ui/form';

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
  const fieldErrors = mutation.error?.response?.errors || {};

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
            <Input
              label="UID"
              type="text"
              value={formData.uid}
              onChange={handleInputChange}
              error={fieldErrors.uid}
              name="uid"
              md={6}
              disabled={!!user}
              required
            />
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
            <Input 
              label="First Name"
              type="text"
              value={formData.firstName}
              onChange={handleInputChange}
              error={fieldErrors.firstName}
              name="firstName"
              md={6}
              required
            />
            <Input
              label="Last Name"
              type="text"
              name="lastName"
              value={formData.lastName}
              onChange={handleInputChange}
              error={fieldErrors.lastName}
              md={6}
              required
            />
          </Row>

          <Row className="mb-3">
            <Input
              label="Email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              error={fieldErrors.email}
              disabled={isEditingSelf && !initialUser.isAdmin}
              required
            />
          </Row>

          <Select
            label="Account Type"
            name="accountType"
            value={formData.accountType}
            onChange={handleSelectChange}
            error={fieldErrors.accountType}
            disabled={isEditingSelf && !initialUser.isAdmin}
          >
            {!user && <option value="">Choose account type</option>}
            <option value="standard">Standard</option>
            <option value="service">Service</option>
          </Select>
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
              disabled={isEditingSelf}
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
