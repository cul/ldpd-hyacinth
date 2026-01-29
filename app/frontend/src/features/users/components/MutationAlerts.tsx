import React from 'react';
import { Alert } from 'react-bootstrap';

interface MutationAlertsProps {
  mutation: {
    isError: boolean;
    isSuccess: boolean;
    error: Error | null;
    reset: () => void;
  };
  successMessage?: string;
  errorMessage?: string;
}

// ? Move to a common components folder if used in multiple places
export default function MutationAlerts({
  mutation,
  successMessage = 'Operation completed successfully!',
  errorMessage = 'An error occurred',
}: MutationAlertsProps) {
  if (!mutation.isError && !mutation.isSuccess) return null;

  return (
    <>
      {mutation.isError && (
        <Alert variant="danger" dismissible onClose={() => mutation.reset()}>
          {errorMessage}: {mutation.error?.message}
        </Alert>
      )}

      {mutation.isSuccess && (
        <Alert variant="success" dismissible onClose={() => mutation.reset()}>
          {successMessage}
        </Alert>
      )}
    </>
  );
};