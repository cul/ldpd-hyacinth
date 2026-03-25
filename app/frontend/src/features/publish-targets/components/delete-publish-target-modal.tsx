import { Button, Modal, Alert } from 'react-bootstrap';
import { useNavigate } from 'react-router';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTriangleExclamation } from '@fortawesome/pro-regular-svg-icons';
import { useNotifications } from '@/stores/notifications-store';
import { useDeletePublishTarget } from '../api/delete-publish-target';

type DeletePublishTargetModalProps = {
  show: boolean;
  onHide: () => void;
  publishTargetStringKey: string;
  publishTargetDisplayLabel: string;
};

export const DeletePublishTargetModal = ({
  show,
  onHide,
  publishTargetStringKey,
  publishTargetDisplayLabel,
}: DeletePublishTargetModalProps) => {
  const navigate = useNavigate();
  const addNotification = useNotifications(state => state.addNotification);

  const deletePublishTargetMutation = useDeletePublishTarget({
    mutationConfig: {
      onSuccess: () => {
        addNotification({
          type: 'success',
          title: 'Publish target deleted',
          message: `"${publishTargetDisplayLabel}" was successfully deleted.`,
        });
        navigate('/publish-targets');
      },
    },
  });

  const apiError = deletePublishTargetMutation.error?.response?.errors?.base?.[0];

  const handleHide = () => {
    if (deletePublishTargetMutation.isPending) return;
    deletePublishTargetMutation.reset();
    onHide();
  };

  const handleConfirm = () => {
    deletePublishTargetMutation.mutate({ publishTargetStringKey });
  };

  return (
    <Modal show={show} onHide={handleHide} >
      <Modal.Header
        closeButton
        className="bg-danger-subtle border-danger border-opacity-25"
      >
        <Modal.Title className="text-danger-emphasis d-flex align-items-center gap-2 fs-5">
          <FontAwesomeIcon icon={faTriangleExclamation} />
          Delete Publish Target
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p className="mb-0">
          Are you sure you want to delete{' '}
          <strong>{publishTargetDisplayLabel}</strong>? This action cannot be
          undone.
        </p>

        {apiError && (
          <Alert variant="danger" className="mb-0 mt-3 py-2">
            <strong>Could not delete:</strong> {apiError}
          </Alert>
        )}
      </Modal.Body>

      <Modal.Footer>
        <Button
          variant="outline-secondary"
          onClick={handleHide}
          disabled={deletePublishTargetMutation.isPending}
        >
          Cancel
        </Button>
        <Button
          variant="danger"
          onClick={handleConfirm}
          disabled={deletePublishTargetMutation.isPending}
        >
          {deletePublishTargetMutation.isPending ? 'Deleting…' : 'Delete'}
        </Button>
      </Modal.Footer>
    </Modal>
  );
};