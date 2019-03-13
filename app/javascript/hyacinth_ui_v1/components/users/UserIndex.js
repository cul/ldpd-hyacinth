import React from 'react';
import { Link } from "react-router-dom";
import { Table } from "react-bootstrap";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class Users extends React.Component {
  state = {
    users: []
  }

  componentDidMount() {
    hyacinthApi.get('/users/')
      .then(res => {
        this.setState({ users: res.data })
      }); // TODO: catch error
  }

  render() {

    let rows = this.state.users.map(user => {
      return (
        <tr key={user.uid}>
          <td><Link to={"/users/" + user.uid + "/edit"} className="nav-link" href="#">{user.first_name}</Link></td>
          <td>{user.first_name}</td>
          <td>{user.groups}</td>
        </tr>
      )
    })

    return(
      <div>
        <ContextualNavbar
          title="Users"
          rightHandLinks={[{link: '/users/new', label: 'New User'}]} />

        <Table striped>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Groups</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </Table>
      </div>
    )
  }
}
