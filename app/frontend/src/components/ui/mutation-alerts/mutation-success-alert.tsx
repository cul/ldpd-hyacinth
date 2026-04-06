import { Alert } from 'react-bootstrap';

interface MutationSuccessAlertProps {
  mutation: {
    isSuccess: boolean;
    reset: () => void;
  };
  message?: string;
}

export const MutationSuccessAlert = ({
  mutation,
  message = 'Operation completed successfully!',
}: MutationSuccessAlertProps) => {
  if (!mutation.isSuccess) return null;

  return (
    <Alert variant="success" dismissible onClose={() => mutation.reset()}>
      {message}
    </Alert>
  );
};
