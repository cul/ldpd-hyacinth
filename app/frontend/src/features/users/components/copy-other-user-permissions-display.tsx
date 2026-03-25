import { Button, Row, Col } from 'react-bootstrap';
import { User } from '@/types/api';
import { AutocompleteSingleSelect } from '@/components/ui/autocomplete-select';

interface CopyOtherPermissionsDisplayProps {
  onSelectUser: (uid: string) => void;
  selectedUserUid: string;
  usersList: User[];
  mergeUserPermissions: () => void;
}

// ? Better name for this component?
export const CopyOtherPermissionsDisplay = ({
  onSelectUser,
  selectedUserUid,
  usersList,
  mergeUserPermissions
}: CopyOtherPermissionsDisplayProps) => {
  return (
    <div className="mb-4" style={{ borderBottom: '1px solid #dee2e6', paddingBottom: '1.5rem' }}>
      <p>You can copy project permissions from another user to this one by selecting the other user&apos;s name from the dropdown list below.
      </p>
      <Row className="g-2 align-items-center">
        <Col md={4}>
          <AutocompleteSingleSelect
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