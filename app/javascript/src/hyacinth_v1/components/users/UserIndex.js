import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import { getUsersQuery } from '../../graphql/users';
import ContextualNavbar from '../shared/ContextualNavbar';

function UserIndex() {
  const { loading, error, data } = useQuery(getUsersQuery);

  return (
    <>
      <ContextualNavbar
        title="Users"
        rightHandLinks={[{ link: '/users/new', label: 'New User' }]}
      />

      <Table striped responsive>
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Active?</th>
          </tr>
        </thead>
        <tbody>
          {
            data && data.users.map(user => (
              <tr key={user.id}>
                <td><Link to={`/users/${user.id}/edit`}>{`${user.firstName} ${user.lastName}`}</Link></td>
                <td>{user.email}</td>
                <td>{(user.isActive) ? 'true' : 'false'}</td>
              </tr>
            ))
          }
        </tbody>
      </Table>
    </>
  );
}

export default UserIndex;
