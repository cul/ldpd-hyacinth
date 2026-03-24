import { Toast } from "react-bootstrap";

const VARIANT_MAP = {
  success: 'success',
  error: 'danger',
  warning: 'warning',
  info: 'info',
} as const;

export type NotificationProps = {
  notification: {
    id: string;
    type: 'success' | 'error' | 'warning' | 'info';
    title: string;
    message?: string;
  };
  onDismiss: (id: string) => void;
};

export const Notification = ({
  notification: { id, type, title, message },
  onDismiss
}: NotificationProps) => {
  return (
    <Toast
      key={id}
      onClose={() => onDismiss(id)}
      // TODO: Improve styling
      bg={VARIANT_MAP[type]}
      // autohide
      // delay={5000}
    >
      <Toast.Header>
        <strong className="me-auto">{title}</strong>
      </Toast.Header>
      {message && <Toast.Body>{message}</Toast.Body>}
    </Toast>
  );
}

