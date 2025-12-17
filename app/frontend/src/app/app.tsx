import React from 'react';
import { AppRouter } from './router';

// The app component will be wrapped with providers (like React Query) later.
const App = () => {
  return (
    <AppRouter />
  );
};

export default App;