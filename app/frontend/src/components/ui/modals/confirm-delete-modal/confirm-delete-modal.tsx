import { Button, Modal, Alert } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faTriangleExclamation } from '@fortawesome/free-solid-svg-icons';

export type ConfirmDeleteModalProps = {
  show: boolean;
  onHide: () => void;
  onConfirm: () => void;
  title: string;
  resourceName: string;
  isPending?: boolean;
  errorMessage?: string | null;
  confirmLabel?: string;
};

// Presentational confirmation dialog for deleting a single resource.
// All data fetching and mutation logic is handled by the caller.
export const ConfirmDeleteModal = ({
  show,
  onHide,
  onConfirm,
  title,
  resourceName,
  isPending = false,
  errorMessage,
  confirmLabel = 'Delete',
}: ConfirmDeleteModalProps) => {
  const handleHide = () => {
    if (isPending) return;
    onHide();
  };

  return (
    <Modal show={show} onHide={handleHide}>
      <Modal.Header closeButton className="bg-danger-subtle border-danger border-opacity-25">
        <Modal.Title className="text-danger-emphasis d-flex align-items-center gap-2 fs-5">
          <FontAwesomeIcon icon={faTriangleExclamation} />
          {title}
        </Modal.Title>
      </Modal.Header>

      <Modal.Body>
        <p className="mb-0">
          Are you sure you want to delete <strong>{resourceName}</strong>? This action cannot be
          undone.
        </p>

        {errorMessage && (
          <Alert variant="danger" className="mb-0 mt-3 py-2">
            <strong>Could not delete:</strong> {errorMessage}
          </Alert>
        )}
      </Modal.Body>

      <Modal.Footer>
        <Button variant="outline-secondary" onClick={handleHide} disabled={isPending}>
          Cancel
        </Button>
        <Button variant="danger" onClick={onConfirm} disabled={isPending}>
          {isPending ? 'Deleting…' : confirmLabel}
        </Button>
      </Modal.Footer>
    </Modal>
  );
};
