import { Outlet } from 'react-router';
import Container from 'react-bootstrap/Container';
import TopNavbar from '@/components/TopNavbar';

export default function MainLayout() {
  return (
    <>
      <TopNavbar />
      <main className="grid flex-1">
        <Container>
          <Outlet />
        </Container>
      </main>
    </>
  );
}