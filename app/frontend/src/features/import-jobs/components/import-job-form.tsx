import { useState } from 'react';
import { Button, Col, Form, Row } from 'react-bootstrap';
import { Input, Select } from '@/components/ui/form';
import { useCreateImportJob } from '@/features/import-jobs/api/create-import-job';
import { useNotifications } from '@/stores/notifications-store';
import { useNavigate } from 'react-router';

export const ImportJobForm = () => {
  const navigate = useNavigate();
  const { addNotification } = useNotifications();
  const [formData, setFormData] = useState<{
    file: File | null;
    priority: string;
  }>({
    file: null,
    priority: 'low',
  });

  const createJobImportMutation = useCreateImportJob({
    mutationConfig: {
      onSuccess: (data) => {
        addNotification({
          type: 'success',
          title: 'Import job created',
        });
        navigate(`/import-jobs/${data.importJob.id}`);
      },
    },
  });

  // const fieldErrors: Record<string, string> = {};

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    console.log('Submitting values', formData);
    if (formData.file) {
      createJobImportMutation.mutate({
        data: { file: formData.file, priority: formData.priority },
      });
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0] ?? null;
    setFormData((prev) => ({ ...prev, file }));
  };

  const handleSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // TODO: Display validation errors
  return (
    <Form onSubmit={handleSubmit} className="mb-8">
      <Row className="mb-3">
        {/* ? Add limits to what file types can be uploaded */}

        <Input
          label="File"
          type="file"
          onChange={handleFileChange}
          // error={fieldErrors.file}
          name="file"
          md={7}
          required
        />
      </Row>
      <Row className="mb-3">
        <Select
          label="Priority"
          name="priority"
          value={formData.priority}
          onChange={handleSelectChange}
          md={7}
          // error={fieldErrors.priority}
        >
          <option value="low">Low</option>
          <option value="medium">Medium</option>
          <option value="high">High</option>
        </Select>
      </Row>

      {/* TODO: Ability to validate job import without uploading */}
      <Row className="mb-4 mt-2">
        <Col md={7}>
          <Button
            variant="primary"
            type="submit"
            disabled={createJobImportMutation.isPending}
            className="px-3"
          >
            {createJobImportMutation.isPending ? 'Saving...' : 'Create a New Import Job'}
          </Button>
        </Col>
      </Row>
    </Form>
  );
};
