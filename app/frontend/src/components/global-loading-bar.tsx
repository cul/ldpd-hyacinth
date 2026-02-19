import React, { createContext, Dispatch, useContext, useEffect, useReducer, useState } from 'react';
import { useClientLoaderStatus, ClientLoaderStatus } from '../features/users/hooks/useClientLoaderStatus';

/* Enums */

export enum GlobalLoadingBarStatus {
  Idle,
  Loading,
  Complete
}
/* GlobalLoadingBar Context */

export const GlobalLoadingBarContext = createContext<{ state: { status: GlobalLoadingBarStatus }, dispatch: Dispatch<unknown> }>({
  state: { status: GlobalLoadingBarStatus.Idle },
  dispatch: () => null // Placeholder for the dispatch function
});

/* Reducer function */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function reducer(state: any, action: any) {
  console.log('reducer was called with action: ', action);
  switch (action.type) {
    case 'updateStatus':
      return {
        ...state,
        status: action.status
      };
    default:
      throw Error('Unknown action: ' + action.type);
  }
}

/* GlobalLoadingBar component */

export const GlobalLoadingBar = () => {
  const { state: { status: globalLoadingBarStatus }, dispatch } = useContext(GlobalLoadingBarContext);

  useEffect(() => {
    if (globalLoadingBarStatus == GlobalLoadingBarStatus.Complete) {
      setTimeout(() => { dispatch({ type: 'updateStatus', status: GlobalLoadingBarStatus.Idle }); }, 500);
    }
  }, [globalLoadingBarStatus, dispatch]);

  return (
    <div className={`global-loading-bar ${GlobalLoadingBarStatus[globalLoadingBarStatus]}`}>
      <div className="outer-bar">
        <div className="inner-bar">
        </div>
      </div>
    </div >
  );
};

/* GlobalLoadingBarProvider component */

interface GlobalLoadingBarProviderProps {
  children: React.ReactNode;
}

export const GlobalLoadingBarContainer = ({ children }: GlobalLoadingBarProviderProps) => {
  const [state, dispatch] = useReducer(reducer, { status: GlobalLoadingBarStatus.Idle });

  return (
    <>
      <GlobalLoadingBarContext.Provider value={{ state, dispatch }}>
        <GlobalLoadingBar />
        {children}
      </GlobalLoadingBarContext.Provider>
    </>
  );
};
