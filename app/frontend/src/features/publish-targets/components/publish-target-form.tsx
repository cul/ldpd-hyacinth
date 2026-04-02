import { Suspense, useState } from 'react';
import { Button, Col, Form, Row } from 'react-bootstrap';
import { useNavigate } from 'react-router';
import { Input } from '@/components/ui/form';
import { MutationErrorAlert, MutationSuccessAlert } from '@/components/ui/mutation-alerts';
import { useCreatePublishTarget } from '../api/create-publish-target';
import { useUpdatePublishTarget } from '../api/update-publish-target';
import { PublishTarget } from '@/types/api';
import { ProjectsForTargetSelector } from './projects-for-target-selector';
import { DeletePublishTargetModal } from './delete-publish-target-modal';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTrash } from '@fortawesome/pro-regular-svg-icons';
import { useNotifications } from '@/stores/notifications-store';

type PublishTargetFormProps = {
  publishTarget?: PublishTarget;
};

export const PublishTargetForm = ({ publishTarget }: PublishTargetFormProps) => {
  const navigate = useNavigate();
  const addNotification = useNotifications(state => state.addNotification);

  const [formData, setFormData] = useState({
    stringKey: publishTarget?.stringKey || '',
    displayLabel: publishTarget?.displayLabel || '',
    publishUrl: publishTarget?.publishUrl || '',
    apiKey: publishTarget?.apiKey || '',
    projectIds: publishTarget?.projects?.map(p => p.id) || [],
  });
  const [selectedProjectIds, setSelectedProjectIds] = useState<number[]>(publishTarget?.projects?.map(p => p.id) || []);
  const [showDeleteModal, setShowDeleteModal] = useState(false);

  const updatePublishTargetMutation = useUpdatePublishTarget();
  const createPublishTargetMutation = useCreatePublishTarget({
    mutationConfig: {
      onSuccess: (data) => {
        addNotification({
          type: 'success',
          title: 'Publish target created',
          message: `"${data.publishTarget.displayLabel}" was successfully created.`,
        });
        navigate(`/publish-targets/${data.publishTarget.stringKey}/edit`);
      },
    },
  });

  // Get the appropriate mutation and field errors based on mode
  const mutation = publishTarget ? updatePublishTargetMutation : createPublishTargetMutation;
  const fieldErrors = mutation.error?.response?.errors || {};

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
      projectIds: selectedProjectIds,
    };

    if (publishTarget) {
      updatePublishTargetMutation.mutate({ publishTargetStringKey: publishTarget.stringKey, data: payload });
    } else {
      createPublishTargetMutation.mutate({ data: payload });
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;

    // Clear all errors when user starts editing
    if (mutation.isError) {
      mutation.reset();
    }

    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  return (
    <>
      <MutationErrorAlert
        mutation={mutation}
        message={publishTarget ? "Error updating publish target" : "Error creating publish target"}
      />
      {publishTarget && (
        <MutationSuccessAlert
          mutation={updatePublishTargetMutation}
          message="Publish target updated successfully!"
        />
      )}
      <Form onSubmit={handleSubmit} className="mb-8">
        <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-3">
          <small>Publish Target information</small>
        </p>
        <Row className="mb-3">
          <Input
            label="String Key"
            type="text"
            value={formData.stringKey}
            onChange={handleInputChange}
            error={fieldErrors.stringKey}
            name="stringKey"
            md={7}
            disabled={!!publishTarget}
            required
          />
          {!publishTarget && (
            <div className="text-muted">
              <small>
                Can only contain lowercase letters, numbers, and underscores.
              </small>
            </div>
          )}
        </Row>
        <Row className="mb-3">
          <Input
            label="Display Label"
            type="text"
            value={formData.displayLabel}
            onChange={handleInputChange}
            error={fieldErrors.displayLabel}
            name="displayLabel"
            md={7}
            required
          />
        </Row>
        <Row className="mb-3">
          <Input
            label="Publish URL"
            type="text"
            name="publishUrl"
            value={formData.publishUrl}
            onChange={handleInputChange}
            error={fieldErrors.publishUrl}
            md={7}
            required
          />
        </Row>
        <Row className="mb-3">
          <Input
            label="API Key"
            type="text"
            name="apiKey"
            value={formData.apiKey}
            onChange={handleInputChange}
            error={fieldErrors.apiKey}
            md={7}
            required
          />
        </Row>

        <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-2 pt-2">
          <small>Associated Projects</small>
        </p>
        <Suspense fallback={<p className="text-muted">Loading projects...</p>}>
          <ProjectsForTargetSelector
            selectedProjectIds={selectedProjectIds}
            onChange={setSelectedProjectIds}
          />
        </Suspense>

        <Row className="mb-4 mt-2">
          <Col md={7}>
            <Button
              variant="primary"
              type="submit"
              disabled={mutation.isPending}
              className="px-3"
            >
              {mutation.isPending ? 'Saving...' : publishTarget ? 'Save' : 'Create a New Publish Target'}
            </Button>
          </Col>
        </Row>
      </Form>

      {publishTarget && (
        <>
          <hr className="my-4" />
          <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-1">
            <small>Danger Zone</small>
          </p>
          <p className="text-muted mb-3">
            <small>Deleting this publish target is permanent and cannot be undone.</small>
          </p>
          <Button
            variant="outline-danger"
            onClick={() => setShowDeleteModal(true)}
          >
            <FontAwesomeIcon icon={faTrash} className="me-2" />
            Delete {publishTarget.displayLabel}
          </Button>

          <DeletePublishTargetModal
            show={showDeleteModal}
            onHide={() => setShowDeleteModal(false)}
            publishTargetStringKey={publishTarget.stringKey}
            publishTargetDisplayLabel={publishTarget.displayLabel}
          />
        </>
      )}
    </>
  );
}
