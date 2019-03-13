import React from 'react';
import { Link } from "react-router-dom";
import { Table } from "react-bootstrap";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';


export default class GroupIndex extends React.Component {
  state = {
    groups: []
  }

  componentDidMount() {
    hyacinthApi.get('/groups/')
      .then(res => {
        console.log(res.data)
        this.setState({ groups: res.data.groups })
      })
      .catch(error => {
        console.log(error)
      });
  }

  render() {
    let rows = this.state.groups.map(group => {
      return (
        <tr key={group.string_key}>
          <td><Link to={"/groups/" + group.string_key + "/edit"} className="nav-link" href="#">{group.string_key}</Link></td>
          <td></td>
          <td></td>
        </tr>
      )
    })

    return (
      <div>
        <ContextualNavbar
          title="Groups"
          rightHandLinks={[{link: "/groups/new", label: "New Group"}]} />

        <Table striped>
          <thead>
            <tr>
              <th>String Key</th>
              <th>Admin</th>
              <th>Number of Members</th>
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
