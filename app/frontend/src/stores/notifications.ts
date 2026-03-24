import { create } from 'zustand';

export type Notification = {
  id: string;
  type: 'success' | 'error' | 'info';
  title: string;
  message?: string;
};

type NotificationsStore = {
  notifications: Notification[];
  addNotification: (notification: Omit<Notification, 'id'>) => void;
  dismissNotification: (id: string) => void;
};

export const useNotifications = create<NotificationsStore>((set) => ({
  notifications: [{
    id: crypto.randomUUID(),
    type: 'success',
    title: 'Welcome to Hyacinth!',
    message: 'This is a sample notification. Click the X to dismiss it.',
  },
  {
    id: crypto.randomUUID(),
    type: 'error',
    title: 'Error notification',
    message: 'This is an error notification.',
  }

],
  addNotification: (notification) =>
    set((state) => ({
      notifications: [...state.notifications, { ...notification, id: crypto.randomUUID() }],
    })),
  dismissNotification: (id) =>
    set((state) => ({
      notifications: state.notifications.filter((n) => n.id !== id),
    })),
}));