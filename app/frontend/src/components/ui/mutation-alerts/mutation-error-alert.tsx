import { Alert } from 'react-bootstrap';

interface MutationErrorAlertProps {
  mutation: {
    isError: boolean;
    error: Error | null;
    reset: () => void;
  };
  message?: string;
}

export const MutationErrorAlert = ({
  mutation,
  message = 'An error occurred',
}: MutationErrorAlertProps) => {
  if (!mutation.isError) return null;

  return (
    <Alert variant="danger" dismissible onClose={() => mutation.reset()}>
      {message}: {mutation.error?.message}
    </Alert>
  );
};