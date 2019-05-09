import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import producer from 'immer';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class Users extends React.Component {
  state = {
    users: [],
  }

  componentDidMount() {
    hyacinthApi.get('/users/')
      .then(res => {
        this.setState(producer(draft => { draft.users = res.data.users }))
      });
  }

  render() {
    const rows = this.state.users.map(user => {
      return (
        <tr key={user.uid}>
          <td><Link to={`/users/${user.uid}/edit`} className="nav-link" href="#">{`${user.first_name} ${user.last_name}`}</Link></td>
          <td>{user.email}</td>
          <td>{user.groups}</td>
          <td>{(user.is_active) ? 'true' : 'false'}</td>
        </tr>
      )
    })

    return(
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
              <th>Groups</th>
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
