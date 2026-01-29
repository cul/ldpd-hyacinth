import AppRouter from './AppRouter';
import AppProvider from './AppProvider';

export default function App() {
  return (
    <AppProvider>
      <AppRouter />
    </AppProvider>
  );
}