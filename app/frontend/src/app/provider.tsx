import * as React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import Spinner from 'react-bootstrap/Spinner';
import { ErrorBoundary } from 'react-error-boundary';

import { MainErrorFallback } from '@/components/errors/main';
import { queryConfig } from '@/lib/react-query';
import { useCurrentUser } from '@/lib/auth';

function AuthLoader({ children }: { children: React.ReactNode }) {
  const { data: user, isLoading } = useCurrentUser();

  // Side effects like modifying window.location should be done in useEffect
  React.useEffect(() => {
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

export const AppProvider: React.FC<React.PropsWithChildren<unknown>> = ({ children }) => {
  const [queryClient] = React.useState(
    () =>
      new QueryClient({
        defaultOptions: queryConfig,
      }),
  );

  return (
    <React.Suspense
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
    </React.Suspense>
  );
}