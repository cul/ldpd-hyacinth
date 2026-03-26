import { create } from 'zustand';

export type Notification = {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  title: string;
  message?: string;
};

type NotificationsStore = {
  notifications: Notification[];
  addNotification: (notification: Omit<Notification, 'id'>) => void;
  dismissNotification: (id: string) => void;
};

/**
 * Use this hook to manage global notifications across the app. Generally, we prefer to use alerts closer 
 * to the source of the event (e.g. within a form or component), but this store is useful for triggering notifications 
 * from non-component code (e.g. utility functions, API clients) or for displaying messages when the form or component is unmounted 
 * (e.g. successful deletion of a resource that triggers a redirect).
 */
export const useNotifications = create<NotificationsStore>((set) => ({
  notifications: [],
  addNotification: (notification) =>
    set((state) => ({
      notifications: [...state.notifications, { ...notification, id: crypto.randomUUID() }],
    })),
  dismissNotification: (id) =>
    set((state) => ({
      notifications: state.notifications.filter((n) => n.id !== id),
    })),
}));