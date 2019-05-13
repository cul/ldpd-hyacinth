import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import producer from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';

export default class Users extends React.Component {
  state = {
    users: [],
  }

  componentDidMount() {
    hyacinthApi.get('/users/')
      .then((res) => {
        this.setState(producer((draft) => { draft.users = res.data.users; }));
      });
  }

  render() {
    const rows = this.state.users.map(user => (
      <tr key={user.uid}>
        <td><Link to={`/users/${user.uid}/edit`} href="#">{`${user.firstName} ${user.lastName}`}</Link></td>
        <td>{user.email}</td>
        <td>{(user.isActive) ? 'true' : 'false'}</td>
      </tr>
    ));

    return (
      <div>
        <ContextualNavbar
          title="Users"
          rightHandLinks={[{ link: '/users/new', label: 'New User' }]}
        />

        <Table striped>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Active?</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </Table>
      </div>
    );
  }
}
