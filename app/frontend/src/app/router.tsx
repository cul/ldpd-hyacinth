// import { QueryClient, useQueryClient } from '@tanstack/react-query';
import React from 'react';
import { useMemo } from 'react';
import { createBrowserRouter, Outlet } from 'react-router';
import { RouterProvider } from 'react-router/dom';
import NotFoundRoute from './routes/not-found.tsx';

import Test from '../components/test.tsx';
import MainLayout from '../components/layouts/main-layout.tsx';
// import { paths } from '../config/paths';

// import {
//   default as AppRoot,
//   ErrorBoundary as AppRootErrorBoundary,
// } from './routes/app/root';
function Root() {
  return (
    <div>
      <h1>Hello world</h1>
    </div>
  );
}

export const createAppRouter = () =>
  createBrowserRouter([
    {
      Component: MainLayout,
      children: [
        {
          index: true,
          Component: Root,
        },
        {
          path: 'test',
          Component: Test,
        },

      ],
    },
    // {
    //   path: paths.app.root.path,
    //   element: (
    //     <ProtectedRoute>
    //       <AppRoot />
    //     </ProtectedRoute>
    //   ),
    // },
    {
      path: '*',
      element: <NotFoundRoute />,
    },
  ], {
    basename: '/ui/v2',
  });

export const AppRouter = () => {
  const router = useMemo(() => createAppRouter(), []);

  return <RouterProvider router={router} />;
};