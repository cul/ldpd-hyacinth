import React from 'react';
import Alert from 'react-bootstrap/Alert';
import { useRouteError, isRouteErrorResponse } from 'react-router';
import { isAuthorizationError } from '@/lib/loader-authorization';

const ErrorDisplay = ({ title, message }: { title: string; message: string }) => (
  <div className="py-5">
    <Alert variant="danger">
      <Alert.Heading>{title}</Alert.Heading>
      <p>{message}</p>
    </Alert>
  </div>
);

export const AuthorizationErrorBoundary: React.FC = () => {
  const error = useRouteError();

  // Check if it's an authorization error
  if (isAuthorizationError(error)) {
    return (
      <ErrorDisplay
        title="Access Denied"
        message="You do not have permission to access this page. Please contact an administrator if you believe this is an error."
      />
    );
  }

  // Handle other route errors
  if (isRouteErrorResponse(error)) {
    return (
      <ErrorDisplay
        title={`Error ${error.status}`}
        message={error.statusText}
      />
    );
  }

  // Generic error fallback
  return (
    <ErrorDisplay
      title="An unexpected error occurred"
      message={error instanceof Error ? error.message : 'Unknown error'}
    />
  );
};
