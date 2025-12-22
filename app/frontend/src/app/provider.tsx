import * as React from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import Spinner from 'react-bootstrap/Spinner';
import { ErrorBoundary } from 'react-error-boundary';
import { MainErrorFallback } from '../components/errors/main';
import { queryConfig } from '../lib/react-query';

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
          {<ReactQueryDevtools />}
          {children}
        </QueryClientProvider>
      </ErrorBoundary>
    </React.Suspense>
  );
}