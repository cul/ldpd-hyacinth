import React, { useContext, useEffect } from 'react';
import { AppRouter } from './router';
import { AppProvider } from './provider';
import { GlobalLoadingBarContext, GlobalLoadingBarStatus } from '../components/global-loading-bar';
import { useClientLoaderStatus, ClientLoaderStatus } from '../features/users/hooks/useClientLoaderStatus';

const App = () => {
  const { status: clientLoaderStatus } = useClientLoaderStatus();
  const { dispatch } = useContext(GlobalLoadingBarContext);

  useEffect(() => {
    if (clientLoaderStatus === ClientLoaderStatus.Loading) {
      dispatch({ type: 'updateStatus', status: GlobalLoadingBarStatus.Loading });
    } else {
      dispatch({ type: 'updateStatus', status: GlobalLoadingBarStatus.Complete });
    }
  }, [clientLoaderStatus, dispatch]);

  return (
    <AppProvider>
      <AppRouter />
    </AppProvider>
  );
};

export default App;
