import React from 'react';
import { AppRouter } from './router';
import { AppProvider } from './provider';

const App = () => {
  return (
    <AppProvider>
      <AppRouter />
    </AppProvider>
  );
};

export default App;