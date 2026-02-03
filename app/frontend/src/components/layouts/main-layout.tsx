import React from 'react';
import { Outlet } from 'react-router';
import Container from 'react-bootstrap/Container';
import TopNavbar from '@/components/top-navbar';

const MainLayout = () => {
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

export default MainLayout;