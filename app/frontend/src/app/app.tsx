import React from 'react';
import { AppRouter } from './router';
import { AppProvider } from './provider';

// The app component will be wrapped with providers (like React Query) later.
const App = () => {
  return (
    <AppProvider>
      <AppRouter />
    </AppProvider>
  );
};

export default App;