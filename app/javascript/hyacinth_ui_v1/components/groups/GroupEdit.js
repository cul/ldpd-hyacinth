import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api'

export default class GroupEdit extends React.Component {

  state = {
    group: {
      stringKey: '',
      isAdmin: false,
      userUids: [],
      permissions: {
        administrator: false,
        manageVocabularies: false,
        manageUsers: false,
        manageGroups: false
      }
    }
  }

  addUserHandler = (event) => {
    this.setState({
      group: {
        ...this.state.group,
        user_uids: [
          ...this.state.group.user_uids
        ],
        permissions: {
          ...this.state.group.permissions
        }
      }
    })
    console.log("addUserHandler")
  }

  componentDidMount = (event) => {
    hyacinthApi.get("/groups/" + this.props.match.params.string_key)
      .then( res => {
        console.log(res.data);
        this.setState({
          group: {
            ...this.state.group,
            stringKey: res.data.string_key
          }
        })
      })
  }

  render() {
    let permissions = this.state.user_

    return(
      <div>
        <ContextualNavbar
          title={"Editing Group: " + this.state.group.stringKey}
          rightHandLinks={[{link: '/groups', label: 'Cancel'}]} />

        <Form>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>String Key</Form.Label>
            <Col sm={10}>
              <Form.Control type="text" type="text" defaultValue={this.state.group.stringKey} plaintext readOnly />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Users</Form.Label>
            <Col sm={10}>
              <ul className="list-unstyled">

                <li>User 1 <button type="button" className="btn btn-outline-danger btn-sm">Remove</button></li>
                <li><Button size="sm" variant="light" onClick={this.addUserHandler}><FontAwesomeIcon icon="plus" /> Add User</Button></li>
              </ul>
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>System Wide Permissions</Form.Label>
            <Col sm={10}>
              <ul id="user-list" className="list-unstyled">
                <li>Permission 1</li>
              </ul>
            </Col>
          </Form.Group>

          <Form.Group>
            <Form.Label>Project Permissions</Form.Label>
          </Form.Group>

          <Button variant="danger" type="">Delete</Button>
          <Button variant="primary" type="submit">Save</Button>
        </Form>
      </div>
    )
  }
}
