import { useEffect, useState } from 'react';

export enum ClientLoaderStatus {
  Idle,
  Loading
}

export const useClientLoaderStatus = () => {
  const [status, setStatus] = useState<ClientLoaderStatus>(ClientLoaderStatus.Idle);

  useEffect(() => {
    const clientLoaderStartHandler = () => {
      setStatus(ClientLoaderStatus.Loading);
    };
    const clientLoaderCompleteHandler = () => {
      setStatus(ClientLoaderStatus.Idle);
    };

    window.addEventListener('clientLoaderStart', clientLoaderStartHandler);
    window.addEventListener('clientLoaderComplete', clientLoaderCompleteHandler);

    return () => {
      window.removeEventListener('clientLoaderStart', clientLoaderStartHandler);
      window.removeEventListener('clientLoaderStart', clientLoaderCompleteHandler);
    }
  }, []);

  return { status };
}
