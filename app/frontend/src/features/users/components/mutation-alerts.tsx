import React from 'react';
import { Alert } from 'react-bootstrap';
import { UseMutationResult } from '@tanstack/react-query';

interface MutationAlertsProps {
  mutation: UseMutationResult;
  successMessage?: string;
  errorMessage?: string;
}

// ? Move to a common components folder if used in multiple places
export const MutationAlerts = ({
  mutation,
  successMessage = 'Operation completed successfully!',
  errorMessage = 'An error occurred',
}: MutationAlertsProps) => {
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