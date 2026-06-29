import { useState } from 'react';
import { Alert, Button, Col, Form, Row } from 'react-bootstrap';
import { useNavigate } from 'react-router';

import { Input, Select } from '@/components/ui/form';
import { useCreateImportJob } from '@/features/import-jobs/api/create-import-job';
import { useValidateImportJob } from '@/features/import-jobs/api/validate-import-job';
import { ImportErrorAlert } from '@/features/import-jobs/components/import-error-alert';
import { useNotifications } from '@/stores/notifications-store';

type Priority = 'low' | 'medium' | 'high';

interface ImportJobFormData {
  file: File | null;
  priority: Priority;
  restoreArchivedS3ObjectsForNewAssets: boolean;
}

export const ImportJobForm = () => {
  const navigate = useNavigate();
  const { addNotification } = useNotifications();

  const [formData, setFormData] = useState<ImportJobFormData>({
    file: null,
    priority: 'low',
    restoreArchivedS3ObjectsForNewAssets: false,
  });

  // Errors from a create OR validate request, grouped by their field key
  const [apiErrors, setApiErrors] = useState<Record<string, string[]> | undefined>(undefined);
  // Inline success banner shown after a passing "Validate Only" run
  const [validationPassed, setValidationPassed] = useState(false);

  const resetFeedback = () => {
    setApiErrors(undefined);
    setValidationPassed(false);
  };

  const createImportJobMutation = useCreateImportJob({
    mutationConfig: {
      onSuccess: (data) => {
        resetFeedback();
        addNotification({ type: 'success', title: 'Import job created' });
        navigate(`/import-jobs/${data.importJob.id}`);
      },
      onError: (error) => {
        setValidationPassed(false);
        setApiErrors(error.response?.errors ?? {});
      },
    },
  });

  const validateImportJobMutation = useValidateImportJob({
    mutationConfig: {
      onSuccess: () => {
        setApiErrors(undefined);
        setValidationPassed(true);
        addNotification({
          type: 'success',
          title: 'The submitted CSV file appears to be valid.',
        });
      },
      onError: (error) => {
        setValidationPassed(false);
        setApiErrors(error.response?.errors ?? {});
      },
    },
  });

  const isSubmitting = createImportJobMutation.isPending || validateImportJobMutation.isPending;

  const handleCreate = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.file) return;

    resetFeedback();
    createImportJobMutation.mutate({
      data: {
        file: formData.file,
        priority: formData.priority,
        restoreArchivedS3ObjectsForNewAssets: formData.restoreArchivedS3ObjectsForNewAssets,
      },
    });
  };

  const handleValidate = () => {
    if (!formData.file) return;

    resetFeedback();
    validateImportJobMutation.mutate({
      data: { file: formData.file, priority: formData.priority },
    });
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] ?? null;
    resetFeedback();
    setFormData((prev) => ({ ...prev, file }));
  };

  const handlePriorityChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setFormData((prev) => ({ ...prev, priority: e.target.value as Priority }));
  };

  return (
    <>
      {validationPassed && (
        <Alert
          variant="success"
          className="mb-4"
          dismissible
          onClose={() => setValidationPassed(false)}
        >
          The submitted CSV file appears to be valid.
        </Alert>
      )}

      <ImportErrorAlert errors={apiErrors} />

      <Form onSubmit={handleCreate} className="mb-4" noValidate>
        <Row className="mb-3">
          {/* ? Add limits to what file types can be uploaded */}
          <Input label="File" type="file" onChange={handleFileChange} name="file" md={7} required />
        </Row>
        <Row className="mb-3">
          <Select
            label="Priority"
            name="priority"
            value={formData.priority}
            onChange={handlePriorityChange}
            md={7}
          >
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </Select>
        </Row>
        <Row className="mb-3">
          <Col md={7}>
            <Form.Check
              type="checkbox"
              id="restoreArchivedS3ObjectsForNewAssets"
              label="Restore archived S3 objects for new assets"
              name="restoreArchivedS3ObjectsForNewAssets"
              checked={formData.restoreArchivedS3ObjectsForNewAssets}
              onChange={(e) =>
                setFormData((prev) => ({
                  ...prev,
                  restoreArchivedS3ObjectsForNewAssets: e.target.checked,
                }))
              }
            />
          </Col>
        </Row>

        <Row className="mb-4 mt-2">
          <Col md={7} className="d-flex gap-2">
            <Button
              variant="primary"
              type="submit"
              disabled={isSubmitting || !formData.file}
              className="px-3"
            >
              {createImportJobMutation.isPending ? 'Saving…' : 'Create a New Import Job'}
            </Button>

            <Button
              variant="outline-secondary"
              type="button"
              onClick={handleValidate}
              disabled={isSubmitting || !formData.file}
              className="px-3"
            >
              {validateImportJobMutation.isPending ? 'Validating…' : 'Validate Only'}
            </Button>
          </Col>
        </Row>
      </Form>
    </>
  );
};
