import { Button, Modal, Alert } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTriangleExclamation } from '@fortawesome/free-solid-svg-icons';
import { useNotifications } from '@/stores/notifications-store';
import { useDeleteImportJob } from '../api/delete-import-job';

type DeleteImportJobModalProps = {
  show: boolean;
  onHide: () => void;
  importJobId: string;
  importJobName: string;
};

// TODO: This component is very similar to DeletePublishTargetModal
// When we refactor the delete modals to be more generic, we can combine them into a single component.
export const DeleteImportJobModal = ({
  show,
  onHide,
  importJobId,
  importJobName,
}: DeleteImportJobModalProps) => {
  const addNotification = useNotifications((state) => state.addNotification);

  const deleteImportJobMutation = useDeleteImportJob({
    mutationConfig: {
      onSuccess: () => {
        addNotification({
          type: 'success',
          title: 'Import job deleted',
          message: `"${importJobName}" was successfully deleted.`,
        });
        onHide();
      },
    },
  });

  const apiError = deleteImportJobMutation.error?.response?.errors?.base?.[0];

  const handleHide = () => {
    if (deleteImportJobMutation.isPending) return;
    deleteImportJobMutation.reset();
    onHide();
  };

  const handleConfirm = () => {
    deleteImportJobMutation.mutate({ importJobId: importJobId });
  };

  return (
    <Modal show={show} onHide={handleHide}>
      <Modal.Header closeButton className="bg-danger-subtle border-danger border-opacity-25">
        <Modal.Title className="text-danger-emphasis d-flex align-items-center gap-2 fs-5">
          <FontAwesomeIcon icon={faTriangleExclamation} />
          Delete Import Job
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p className="mb-0">
          Are you sure you want to delete <strong>{importJobName}</strong>? This action cannot be
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
          disabled={deleteImportJobMutation.isPending}
        >
          Cancel
        </Button>
        <Button
          variant="danger"
          onClick={handleConfirm}
          disabled={deleteImportJobMutation.isPending}
        >
          {deleteImportJobMutation.isPending ? 'Deleting…' : 'Delete'}
        </Button>
      </Modal.Footer>
    </Modal>
  );
};
