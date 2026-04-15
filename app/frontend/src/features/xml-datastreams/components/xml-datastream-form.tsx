import { Suspense, useState } from 'react';
import { Button, Col, Form, Row } from 'react-bootstrap';
import { useNavigate } from 'react-router';
import { Input } from '@/components/ui/form';
import { MutationErrorAlert, MutationSuccessAlert } from '@/components/ui/mutation-alerts';
import { useCreateXmlDatastream } from '../api/create-xml-datastream';
// import { useUpdateXmlDatastream } from '../api/update-xml-datastream';
import { XmlDatastream } from '@/types/api';
import { useNotifications } from '@/stores/notifications-store';
import { Editor } from './editor'

type XmlDatastreamFormProps = {
  xmlDatastream?: XmlDatastream;
};

export const XmlDatastreamForm = ({ xmlDatastream }: XmlDatastreamFormProps) => {
  const navigate = useNavigate();
  const addNotification = useNotifications(state => state.addNotification);

  const testVal = "{\n  \"render_if\": {\n    \"present\": [\n      \"restriction_on_access\"\n    ]\n  },\n  \"element\": \"xacml:Policy\",\n  \"attrs\": {\n    \"xmlns:xacml\": \"urn:oasis:names:tc:xacml:3.0:core:schema:wd-17\",\n    \"xmlns:xsi\": \"http://www.w3.org/2001/XMLSchema-instance\",\n    \"PolicyId\": \"policy:{{$uuid}}\",\n    \"RuleCombiningAlgId\": \"urn:oasis:names:tc:xacml:3.0:rule-combining-algorithm:deny-unless-permit\"\n  },\n  \"content\": [\n    {\n      \"element\": \"xacml:Target\",\n      \"content\": [\n        {\n          \"element\": \"xacml:AnyOf\",\n          \"content\": [\n            {\n              \"element\": \"xacml:AllOf\",\n              \"content\": [\n                {\n                  \"element\": \"xacml:Match\",\n                  \"attrs\": {\n                    \"MatchId\": \"urn:oasis:names:tc:xacml:1.0:function:string-equal\"\n                  },\n                  \"content\": [\n                    {\n                      \"element\": \"xacml:AttributeValue\",\n                      \"attrs\": {\n                        \"DataType\": \"http://www.w3.org/2001/XMLSchema#string\"\n                      },\n                      \"content\": {\n                        \"val\": \"GET\"\n                      }\n                    },\n                    {\n                      \"element\": \"xacml:AttributeDesignator\",\n                      \"attrs\": {\n                        \"MustBePresent\": \"false\",\n                        \"Category\": \"urn:oasis:names:tc:xacml:3.0:attribute-category:action\",\n                        \"AttributeId\": \"urn:oasis:names:tc:xacml:1.0:action:action-id\",\n                        \"DataType\": \"http://www.w3.org/2001/XMLSchema#string\"\n                      }\n                    }\n                  ]\n                }\n              ]\n            }\n          ]\n        }\n      ]\n    },\n    {\n      \"yield\": \"restriction_on_access\"\n    }\n  ]\n}"


  const [formData, setFormData] = useState({
    stringKey: xmlDatastream?.stringKey || '',
    displayLabel: xmlDatastream?.displayLabel || '',
    xmlTranslation: xmlDatastream?.xmlTranslation || '',
  });

  // const updateXmlDatastreamMutation = useUpdateXmlDatastream();
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
  // const mutation = xmlDatastream ? updateXmlDatastreamMutation : createXmlDatastreamMutation;
  const mutation = createXmlDatastreamMutation;
  const fieldErrors = mutation.error?.response?.errors || {};

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      ...formData,
    };

    // if (xmlDatastream) {
    //   updateXmlDatastreamMutation.mutate({ xmlDatastreamStringKey: xmlDatastream.stringKey, data: payload });
    // } else {
    createXmlDatastreamMutation.mutate({ data: payload });
    // }
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
          {!xmlDatastream && (
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
        {/* WIP, change to a controlled input */}
        <Editor
          value={formData.xmlTranslation || testVal}
        />
      </Form>
    </>
  );
}
