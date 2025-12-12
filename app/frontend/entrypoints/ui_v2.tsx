import React from 'react';
import { createRoot } from 'react-dom/client';
import App from '../src/app/app';

const domNode = document.getElementById('root');
const root = createRoot(domNode);

root.render(<App />);