import { FC, PropsWithChildren, ReactNode, Suspense, useEffect, useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import Spinner from 'react-bootstrap/Spinner';
import { ErrorBoundary } from 'react-error-boundary';

import { MainErrorFallback } from '@/components/errors/main';
import { queryConfig } from '@/lib/react-query';
import { useCurrentUser } from '@/lib/auth';

function AuthLoader({ children }: { children: ReactNode }) {
  const { data: user, isLoading } = useCurrentUser();

  // Side effects like modifying window.location should be done in useEffect
  useEffect(() => {
    if (!isLoading && !user) {
      window.location.href = '/users/sign_in';
    }
  }, [user, isLoading]);

  if (isLoading) {
    return <div>Loading user...</div>;
  }

  if (!user) {
    return null;
  }

  return <>{children}</>;
}

export const AppProvider: FC<PropsWithChildren<unknown>> = ({ children }) => {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: queryConfig,
      }),
  );

  return (
    <Suspense
      fallback={
        <div className="flex h-screen w-screen items-center justify-center">
          <Spinner />
        </div>
      }
    >
      <ErrorBoundary FallbackComponent={MainErrorFallback}>
        <QueryClientProvider client={queryClient}>
          {import.meta.env.DEV && <ReactQueryDevtools />}
          <AuthLoader>{children}</AuthLoader>
        </QueryClientProvider>
      </ErrorBoundary>
    </Suspense>
  );
}
