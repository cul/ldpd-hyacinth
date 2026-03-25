import { ToastContainer } from "react-bootstrap";
import { useNotifications } from "@/stores/notifications-store";
import { Notification } from "./notification";

export const Notifications = () => {
  const { notifications, dismissNotification } = useNotifications();

  return (
    <ToastContainer position="top-end" className="p-3">
      {notifications.map((notification) => (
        <Notification
          key={notification.id}
          notification={notification}
          onDismiss={dismissNotification}
        />
      ))}
    </ToastContainer>
  );
}