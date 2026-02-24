import React from 'react';
import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { mockApiV2 } from '@/testing/test-utils';
import { buildUser } from '@/testing/data-generators';
import { useCurrentUser } from '@/lib/auth';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: Infinity } },
  });

  const Wrapper = ({ children }: { children: React.ReactNode }) =>
    React.createElement(QueryClientProvider, { client: queryClient }, children);
  Wrapper.displayName = 'QueryClientWrapper';
  return Wrapper;
};

// Since getCurrentUser is not exported, we test it through the hook.
describe('useCurrentUser', () => {
  it('should return the user when the API responds successfully', async () => {
    const user = buildUser({ uid: 'testuser', firstName: 'Test' });

    mockApiV2('get', '/users/_self', { user });

    const { result } = renderHook(() => useCurrentUser(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));

    expect(result.current.data?.uid).toBe('testuser');
    expect(result.current.data?.firstName).toBe('Test');
  });

  it('should return null instead of throwing when the API fails', async () => {
    mockApiV2('get', '/users/_self', { error: 'Unauthorized' }, 401);

    const { result } = renderHook(() => useCurrentUser(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isFetching).toBe(false));

    expect(result.current.data).toBeNull();
    expect(result.current.isError).toBe(false);
  });
});