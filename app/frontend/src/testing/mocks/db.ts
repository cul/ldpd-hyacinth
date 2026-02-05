import { User } from '@/types/api';

// Simple in-memory mock database, use it for mocking data operations in tests
const createMockCollection = <T extends { uid: string }>() => {
  let items: T[] = [];

  return {
    getAll: () => [...items],

    findFirst: (predicate: (item: T) => boolean): T | undefined => {
      return items.find(predicate);
    },

    findMany: (predicate: (item: T) => boolean): T[] => {
      return items.filter(predicate);
    },

    create: (item: T): T => {
      items.push(item);
      return item;
    },

    update: (uid: string, updates: Partial<T>): T | undefined => {
      const index = items.findIndex((item) => item.uid === uid);
      if (index === -1) return undefined;
      items[index] = { ...items[index], ...updates };
      return items[index];
    },

    delete: (uid: string): boolean => {
      const index = items.findIndex((item) => item.uid === uid);
      if (index === -1) return false;
      items.splice(index, 1);
      return true;
    },

    clear: () => {
      items = [];
    },

    count: () => items.length,
  };
};

export const db = {
  user: createMockCollection<User>(),
};