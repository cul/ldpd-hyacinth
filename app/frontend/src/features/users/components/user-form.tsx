import { useState, useEffect } from 'react';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import Row from 'react-bootstrap/Row';
import { useCreateUser } from '../api/create-user';
import { useUpdateUser } from '../api/update-user';

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
};

export const UserForm = ({ user }: UserFormProps) => {
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

  // Update form data when user data is loaded
  useEffect(() => {
    if (user) {
      setFormData(user);
    }
  }, [user]);

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

    if (user) {
      updateUserMutation.mutate({ userUid: user.uid, data: formData });
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

  return (
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
            readOnly={!!user}
            disabled={!!user}
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

      <Form.Group className="mb-3" controlId="formGridAccountType">
        <Form.Label>Account Type</Form.Label>
        <Form.Select
          aria-label="Account Type"
          name="accountType"
          value={formData.accountType}
          onChange={handleSelectChange}
        >
          {!user && <option value="">Choose account type</option>}
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
  );
}
