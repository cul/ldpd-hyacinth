import { useState, useCallback } from 'react';
import { Button, Col, Form, Row } from 'react-bootstrap';
import { useNavigate } from 'react-router';
import { Input } from '@/components/ui/form';
import { MutationErrorAlert, MutationSuccessAlert } from '@/components/ui/mutation-alerts';
import { useCreateXmlDatastream } from '../api/create-xml-datastream';
import { useUpdateXmlDatastream } from '../api/update-xml-datastream';
import { XmlDatastream } from '@/types/api';
import { useNotifications } from '@/stores/notifications-store';
import { JSONEditor } from '@/components/ui/json-editor/json-editor'
import type { editor } from 'monaco-editor';

type XmlDatastreamFormProps = {
  xmlDatastream?: XmlDatastream;
};

export const XmlDatastreamForm = ({ xmlDatastream }: XmlDatastreamFormProps) => {
  const navigate = useNavigate();
  const addNotification = useNotifications(state => state.addNotification);

  const updateXmlDatastreamMutation = useUpdateXmlDatastream();
  const createXmlDatastreamMutation = useCreateXmlDatastream({
    mutationConfig: {
      onSuccess: (data) => {
        addNotification({
          type: 'success',
          title: 'XML datastream created',
          message: `"${data.xmlDatastream.displayLabel}" was successfully created.`,
        });
        navigate(`/xml-datastreams/${data.xmlDatastream.stringKey}/edit`);
      },
    },
  });

  // Get the appropriate mutation and field errors based on mode
  const mutation = xmlDatastream ? updateXmlDatastreamMutation : createXmlDatastreamMutation;
  const fieldErrors = mutation.error?.response?.errors || {};

  const [formData, setFormData] = useState({
    stringKey: xmlDatastream?.stringKey || '',
    displayLabel: xmlDatastream?.displayLabel || '',
    xmlTranslation: xmlDatastream?.xmlTranslation || '',
  });

  const [jsonMarkers, setJsonMarkers] = useState<editor.IMarker[]>([]);
  console.log(jsonMarkers)

  // JSON is considered valid when the field is empty or when Monaco reports no markers
  const isJsonValid = formData.xmlTranslation === '' || jsonMarkers.length === 0;

  const handleEditorChange = useCallback((value: string) => {
    if (mutation.isError) mutation.reset();

    setFormData(prev => ({ ...prev, xmlTranslation: value }));
  }, [mutation]);


  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
    };

    if (xmlDatastream) {
      updateXmlDatastreamMutation.mutate({ xmlDatastreamStringKey: xmlDatastream.stringKey, data: payload });
    } else {
      createXmlDatastreamMutation.mutate({ data: payload });
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
        message={xmlDatastream ? "Error updating XML datastream" : "Error creating XML datastream"}
      />
      {xmlDatastream && (
        <MutationSuccessAlert
          mutation={mutation}
          message="XML datastream updated successfully!"
        />
      )}
      <Form onSubmit={handleSubmit} className="mb-8">
        <p className="text-muted fw-bold text-uppercase letter-spacing-wide mb-3">
          <small>XML Datastream information</small>
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
            disabled={!!xmlDatastream}
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
            md={7}
            required
          />
        </Row>
        <Row className="mb-3">
          <Form.Label>XML Translation</Form.Label>
          <JSONEditor
            value={formData.xmlTranslation}
            onChange={handleEditorChange}
            onValidate={setJsonMarkers}
            className={!isJsonValid ? 'border-danger' : ''}
          />
          {!isJsonValid && (
            <div className="text-danger mt-1">
              <small>XML Translation must be valid JSON.</small>
            </div>
          )}
        </Row>
        <Row className="mb-4 mt-2">
          <Col md={7}>
            <Button
              variant="primary"
              type="submit"
              disabled={mutation.isPending || !isJsonValid}
              className="px-3"
            >
              {mutation.isPending ? 'Saving...' : xmlDatastream ? 'Save' : 'Create a New XML Datastream'}
            </Button>
          </Col>
        </Row>
      </Form>
    </>
  );
}
