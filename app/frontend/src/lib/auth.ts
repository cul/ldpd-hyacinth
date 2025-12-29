import { useQuery, useQueryClient } from '@tanstack/react-query';
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

// async function logout(): Promise<void> {
//   await api.delete<{ success: boolean, redirect_url: string }>('/users/session');
//   // After logout, redirect to the Rails login page
//   window.location.href = '/users/sign_in';
// }

export function useUser() {
  return useQuery({
    queryKey: AUTH_QUERY_KEY,
    queryFn: getCurrentUser,
    staleTime: 0, // Always check auth state freshness
    retry: false,
  });
}

// export function useLogout() {
//   const queryClient = useQueryClient();
  
//   return async () => {
//     await logout();
//     queryClient.setQueryData(AUTH_QUERY_KEY, null);
//   };
// }
