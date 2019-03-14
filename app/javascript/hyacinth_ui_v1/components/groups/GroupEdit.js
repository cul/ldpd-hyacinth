import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api'

const SYSTEM_WIDE_PERMISSIONS = [
  { label: 'Administrator', key: 'isAdmin'},
  { label: 'Manage Vocabularies', key: 'manageVocabularies'},
  { label: 'Manage Users', key: 'manageUsers'},
  { label: 'Manage Groups', key: 'manageGroups'}
]

export default class GroupEdit extends React.Component {

  state = {
    group: {
      stringKey: '',
      isAdmin: false,
      userUids: [],
      manageVocabularies: false,
      manageUsers: false,
      manageGroups: false
    }
  }

  removeUserHandler = (event) => {

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

  onChangeHandler = (event) => {
    const target = event.target
    const value = target.type === 'checkbox' ? target.checked : target.value;

    this.setState({
      group: {
        ...this.state.group,
        [target.name]: value
      }
    })
    console.log(this.state)
  }

  onSumbitHandler = (event) => {
    let data = {
      group: {
        is_admin: this.state.isAdmin,
        permissions: []
      }
    }

    if (this.state.group.manageVocabularies) {
      data.group.permissions.concat('manage_vocabularies')
    }

    if (this.state.group.manageUsers) {
      data.group.permissions.concat('manage_users')
    }

    if (this.state.group.manageGroups) {
      data.group.permissions.concat('manage_vocabularies')
    }

    hyacinthApi.patch("/groups/" + this.state.stringKey, data)
      .then(res => {
        console.log('updated group')
      })
      .catch(error => {
        console.log(error)
      })
  }

  componentDidMount = (event) => {
    hyacinthApi.get("/groups/" + this.props.match.params.string_key)
      .then( res => {
        console.log(res.data);
        this.setState({
          group: {
            ...this.state.group,
            stringKey: res.data.group.string_key
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
            <Form.Label column sm={3}>String Key</Form.Label>
            <Col sm={9}>
              <Form.Control type="text" type="text" defaultValue={this.state.group.stringKey} plaintext readOnly />
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={3}>Users</Form.Label>
            <Col sm={9}>
              <ul className="list-unstyled">

                <li>User 1 <button type="button" className="btn btn-outline-danger btn-sm">Remove</button></li>
                <li><Button size="sm" variant="light" onClick={this.addUserHandler}><FontAwesomeIcon icon="plus" /> Add User</Button></li>
              </ul>
            </Col>
          </Form.Group>

          <Form.Group as={Row}>
            <Form.Label column sm={3}>System Wide Permissions</Form.Label>
            <Col sm={9}>
              {SYSTEM_WIDE_PERMISSIONS.map(permission => (
                <Form.Check
                  type="checkbox"
                  id={permission.key}
                  name={permission.key}
                  label={permission.label}
                  checked={this.state.group[permission.key]}
                  onChange={this.onChangeHandler}/>
              ))}
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
