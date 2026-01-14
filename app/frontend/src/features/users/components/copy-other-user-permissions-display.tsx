import React from 'react';
import { Form, Button, Row, Col } from 'react-bootstrap';
import { User } from '@/types/api';
import { AutocompleteSelect } from '@/components/ui/autocomplete-select';

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
      <Row className="g-2 align-items-center">
        <Col md={4}>
          <AutocompleteSelect
            options={usersList.map((user) => ({
              value: user.uid,
              label: `${user.firstName} ${user.lastName} (${user.email})`,
            }))}
            placeholder='Select a user'
            value={selectedUserUid || null}
            onChange={(value) => onSelectUser(value || '')}
          />
        </Col>
        <Col md="auto">
          <Button
            size="sm"
            variant="secondary"
            className="ms-2"
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