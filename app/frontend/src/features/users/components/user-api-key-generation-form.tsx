import React from 'react';
import { Alert, Button } from 'react-bootstrap';
import { useGenerateUserApiKey } from '../api/generate-user-api-key';

type UserAPIKeyGenerationFormProps = {
  userUid: string;
  apiKeyDigest?: string | null;
};

export const UserAPIKeyGenerationForm: React.FC<UserAPIKeyGenerationFormProps> = ({ userUid, apiKeyDigest }) => {
  const hasApiKey = !!apiKeyDigest;
  const generateApiKeyMutation = useGenerateUserApiKey({
    mutationConfig: {
      onSuccess: (data) => {
        setNewApiKey(data.apiKey);
      },
      onError: (error: any) => {
        alert(`Error generating API key: ${error.message || 'Unknown error'}`);
      },
    },
  });

  const [newApiKey, setNewApiKey] = React.useState<string | null>(null);

  const alertDisplay = () => {
    if (newApiKey) {
      return (
        <Alert variant="success" className="mt-3">
          <strong>New API Key:</strong> <br />
          <code>{newApiKey}</code> <br />
          <small className="text-muted">Please copy this API key now. It will not be shown again.</small>
        </Alert>
      )
    }

    if (hasApiKey) {
      return (
        <Alert variant="warning">
          An API key is currently set for this user.
        </Alert>
      );
    }

    return (
      <Alert variant="info">
        An API key has not been generated for this user.
      </Alert>
    )
  };

  return (
    <div>
      <p className="text-muted fw-bold text-uppercase">
        <small>API Key Generation</small>
      </p>
      {alertDisplay()}
      <div className="mt-3">
        <p className="text-muted small">
          {hasApiKey
            ? 'Generate a new API key to replace the existing one. The old key will be invalidated.'
            : 'Generate an API key for this user to enable API access.'}
        </p>
        <Button
          variant="secondary"
          onClick={() => generateApiKeyMutation.mutate({ userUid: userUid })}
          disabled={generateApiKeyMutation.isPending}
        >
          {hasApiKey ? 'Regenerate API Key' : 'Generate API Key'}
        </Button>
      </div>
    </div>
  );
};