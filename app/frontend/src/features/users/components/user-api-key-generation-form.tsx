import React from 'react';
import { Alert, Button } from 'react-bootstrap';

type UserAPIKeyGenerationFormProps = {
  apiKeyDigest?: string | null;
};

export const UserAPIKeyGenerationForm: React.FC<UserAPIKeyGenerationFormProps> = ({ apiKeyDigest }) => {
  const hasApiKey = !!apiKeyDigest;

  return (
    <div>
      <p className="text-muted fw-bold text-uppercase">
        <small>API Key Generation</small>
      </p>
      
      {hasApiKey ? (
        <Alert variant="info">
          An API key is currently set for this user.
        </Alert>
      ) : (
        <Alert variant="warning">
          An API key has not been generated for this user.
        </Alert>
      )}

      <div className="mt-3">
        <p className="text-muted small">
          {hasApiKey 
            ? 'Generate a new API key to replace the existing one. The old key will be invalidated.'
            : 'Generate an API key for this user to enable API access.'}
        </p>
        <Button variant="secondary" disabled>
          {hasApiKey ? 'Regenerate API Key' : 'Generate API Key'}
        </Button>
      </div>
    </div>
  );
};