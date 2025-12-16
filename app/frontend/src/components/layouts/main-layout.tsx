import React from 'react';
import TopNavbar from '../topnavbar';
import { Outlet } from 'react-router';

const MainLayout = () => {
  return (
    <div className="flex min-h-screen w-full flex-col bg-muted/40">
      <TopNavbar />
      <main className="grid flex-1 items-start gap-4 p-4 sm:px-6 sm:py-0 md:gap-8">
        <Outlet />
      </main>
    </div>
  );
}

export default MainLayout;