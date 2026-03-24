import { Toast } from "react-bootstrap";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faCircleCheck,
  faOctagonXmark,
  faTriangleExclamation,
  faCircleInfo,
} from "@fortawesome/pro-regular-svg-icons";
import type { IconDefinition } from "@fortawesome/fontawesome-svg-core";

type NotificationType = "success" | "error" | "warning" | "info";

const VARIANT_MAP: Record<NotificationType, string> = {
  success: "success",
  error: "danger",
  warning: "warning",
  info: "info",
};

const ICON_MAP: Record<NotificationType, IconDefinition> = {
  success: faCircleCheck,
  error: faOctagonXmark,
  warning: faTriangleExclamation,
  info: faCircleInfo,
};

export type NotificationProps = {
  notification: {
    id: string;
    type: NotificationType;
    title: string;
    message?: string;
  };
  onDismiss: (id: string) => void;
};

export const Notification = ({
  notification: { id, type, title, message },
  onDismiss,
}: NotificationProps) => {
  const variant = VARIANT_MAP[type];

  return (
    <Toast
      key={id}
      onClose={() => onDismiss(id)}
      className={`bg-${variant}-subtle border-${variant}`}
    >
      <Toast.Header
        className={`bg-transparent border-${variant} border-opacity-25`}
      >
        <FontAwesomeIcon
          icon={ICON_MAP[type]}
          className={`me-2 text-${variant}-emphasis`}
        />
        <strong className={`me-auto text-${variant}-emphasis`}>{title}</strong>
      </Toast.Header>
      {message && (
        <Toast.Body className="text-body-secondary">{message}</Toast.Body>
      )}
    </Toast>
  );
};