import React from 'react';
import { Form, Button, Row, Col } from 'react-bootstrap';
import { User } from '@/types/api';

interface CopyOtherPermissionsDisplayProps {
  onSelectUser: (uid: string) => void;
  selectedUserUid: string;
  usersList: User[];
  userUid: string;
  mergeUserPermissions: () => void;
}

// ? Better name for this component?
export const CopyOtherPermissionsDisplay = ({
  onSelectUser,
  selectedUserUid,
  usersList,
  userUid,
  mergeUserPermissions
}: CopyOtherPermissionsDisplayProps) => {
  return (
    <div className="mb-4">
      <p>You can copy another user's project permissions by selecting their name from a dropdown. The permissions will be merged with any existing permissions.
        <br />
        Don't worry, you can still make individual adjustments before saving.
      </p>
      <Row>
        <Col md={6}>
          <Form.Select
            size="sm"
            className="mt-2"
            value={selectedUserUid}
            onChange={(e) => onSelectUser(e.target.value)}
          >
            <option value="">- Select a user -</option>
            {usersList.map((user) => {
              if (user.uid === userUid) return null;
              return (
                <option key={user.uid} value={user.uid}>
                  {user.firstName} {user.lastName} ({user.email})
                </option>
              );
            })}
          </Form.Select>
        </Col>
        <Col md={2}>
          <Button
            size="sm"
            variant="secondary"
            className="mt-2"
            onClick={mergeUserPermissions}
            disabled={!selectedUserUid}
          >
            Copy Permissions
          </Button>
        </Col>
      </Row>
    </div>
  );
};