import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { User } from '@/types/api';

export const AUTH_QUERY_KEY = ['authenticated-user'];

async function getCurrentUser(): Promise<User | null> {
  try {
    const response = await api.get<{ user: User | null }>('/users/_self');
    return response.user;
  } catch (error) {
    return null; // Not authenticated
  }
}

export function useCurrentUser() {
  return useQuery({
    queryKey: AUTH_QUERY_KEY,
    queryFn: getCurrentUser,
    staleTime: 1000 * 60 * 5, // 5 minutes
    gcTime: 1000 * 60 * 30, // 30 minutes cache garbage collection
    retry: false,
  });
}