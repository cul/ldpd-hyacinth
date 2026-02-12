import React from 'react';
import { createRoot } from 'react-dom/client';
import App from '../src/app/app.tsx';
import { GlobalLoadingBarContainer } from '../src/components/global-loading-bar.tsx';

const domNode = document.getElementById('root');
if (!domNode) throw new Error('Root element not found');

const root = createRoot(domNode);

root.render(
  <GlobalLoadingBarContainer>
    <App />
  </GlobalLoadingBarContainer>
);
