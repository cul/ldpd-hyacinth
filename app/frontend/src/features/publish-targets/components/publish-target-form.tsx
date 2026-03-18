import { useState } from 'react';
import { Button, Form, Row } from 'react-bootstrap';
// import { MutationAlerts } from './mutation-alerts';
import { Input } from '@/components/ui/form';
import { useCreatePublishTarget } from '../api/create-publish-target';

// TODO
// type PublishTargetFormProps = {
//   publishTarget?: {
//   }
// };

// WIP - currently only supports create mode
export const PublishTargetForm = ({ publishTarget }: any) => {
  // Use existing publish target data for edit mode or default empty values for create mode
  const initialPublishTarget = publishTarget || {
    stringKey: '',
    displayLabel: '',
    publishUrl: '',
    apiKey: '',
    projects: [],
  };

  const [formData, setFormData] = useState(initialPublishTarget);
  const createPublishTargetMutation = useCreatePublishTarget();
  // const updatePublishTargetMutation = useUpdatePublishTarget();

  // Get the appropriate mutation and field errors based on mode
  // const mutation = publishTarget ? updatePublishTargetMutation : createPublishTargetMutation;
  const mutation = createPublishTargetMutation;
  const fieldErrors = mutation.error?.response?.errors || {};

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (publishTarget) {
      // TODO
    } else {
      // ? Redirect to publish target list or detail page)
      createPublishTargetMutation.mutate({ data: formData });
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
      {/* <MutationAlerts
        mutation={publishTarget ? updatePublishTargetMutation : createPublishTargetMutation}
        successMessage={publishTarget ? "Publish target updated successfully!" : "Publish target created successfully!"}
        errorMessage={publishTarget ? "Error updating publish target" : "Error creating publish target"}
      /> */}
      <Form onSubmit={handleSubmit}>
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
            md={6}
            disabled={!!publishTarget}
            required
          />
        </Row>
        <Row className="mb-3">
          <Input
            label="Display Label"
            type="text"
            value={formData.displayLabel}
            onChange={handleInputChange}
            error={fieldErrors.displayLabel}
            name="displayLabel"
            md={6}
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
            required
          />
        </Row>


        <div className="mb-3">
          <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-3">
            <small>Associated Projects</small>
          </p>
          {/* TODO: Projects will go here */}
        </div>

        <Button
          variant="primary"
          type="submit"
          disabled={mutation.isPending}
        >
          {mutation.isPending ? 'Saving...' : 'Save'}
        </Button>
      </Form>
    </>
  );
}
