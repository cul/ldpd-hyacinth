import React from 'react';
import { NavLink, Outlet, useParams, useLocation } from 'react-router';
import Nav from 'react-bootstrap/Nav';

const UserLayout = () => {
  const params = useParams();
  const location = useLocation();
  const userUid = params.userUid as string;

  return (
    <>
      <Nav variant="tabs" className="mb-4" activeKey={location.pathname}>
        <Nav.Item>
          <Nav.Link 
            as={NavLink} 
            to={`/users/${userUid}/edit`}
            eventKey={`/ui/v2/users/${userUid}/edit`}
            end
          >
            User Information and API Key
          </Nav.Link>
        </Nav.Item>
        <Nav.Item>
          <Nav.Link 
            as={NavLink} 
            to={`/users/${userUid}/project-permissions/edit`}
            eventKey={`/ui/v2/users/${userUid}/project-permissions/edit`}
          >
            Project Permissions
          </Nav.Link>
        </Nav.Item>
      </Nav>
      <Outlet />
    </>
  );
}

export default UserLayout;