import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class UserEdit extends React.Component {

  state = {
    changePasswordOpen: false,
    user: {
      uid: '',
      firstName: '',
      lastName: '',
      email: '',
      currentPassword: '',
      password: '',
      passwordConfirmation: ''
    }
  }

  onChangeHandler = (event) => {
    this.setState({
      user: {
        ...this.state.user,
        [event.target.name]: event.target.value
      }
    })
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    let data = {
      first_name: this.state.user.firstName,
      last_name: this.state.user.lastName,
      email: this.state.user.email,
      current_password: this.state.user.currentPassword,
      password: this.state.user.password,
      password_confirmation: this.state.user.passwordConfirmation
    }

    hyacinthApi.patch("/users/" + this.props.match.params.uid, data)
      .then(res => {
        console.log('Saved Changes')
      })
      .catch(error => {
        console.log(error)
      });
  }

  componentDidMount = () => {
    hyacinthApi.get("/users/" + this.props.match.params.uid)
      .then(res => {
        this.setState({
          user: {
            ...this.state.user,
            uid: res.data.uid,
            firstName: res.data.first_name,
            lastName: res.data.last_name,
            email: res.data.email
          }
        })
      })
     .catch(error => {
       console.log(error)
     });
  }

  render() {
    return(
      <div>
        <ContextualNavbar
          title={"Editing User: " + this.state.user.firstName + " " + this.state.user.lastName}
          rightHandLinks={[{link: '/users', label: 'Cancel'}]} />

        <Form onSubmit={this.onSubmitHandler}>
          {/* Add UUID field as ready only */}
            <Form.Group as={Row}>
              <Form.Label column sm={2}>UID</Form.Label>
              <Col sm={10}>
                <Form.Control
                  plaintext
                  readOnly
                  value={this.state.user.uid} />
                </Col>
            </Form.Group>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>First Name</Form.Label>
              <Form.Control
                type="text"
                name="firstName"
                value={this.state.user.firstName}
                onChange={this.onChangeHandler}/>
            </Form.Group>

            <Form.Group as={Col}>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={this.state.user.lastName}
                onChange={this.onChangeHandler} />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={this.state.user.email}
                onChange={this.onChangeHandler} />
              <Form.Text className="text-muted">
                For Columbia sign-in, please use columbia email: uni@columbia.edu
              </Form.Text>
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Col>
              <Button
                variant="link"
                className="pl-0"
                onClick={() => this.setState({ changePasswordOpen: !this.state.changePasswordOpen })}
                aria-controls="collapse-form"
                aria-expanded={this.state.changePasswordOpen} >
                Change Password <FontAwesomeIcon icon={this.state.changePasswordOpen ? "angle-double-up" : "angle-double-down"} />
              </Button>
            </Col>
          </Form.Row>

          <Collapse in={this.state.changePasswordOpen}>
            <div id="collapse-form">
              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Current Password</Form.Label>
                <Col sm={6}>
                  <Form.Control type="text" name="password" value={this.state.currentPassword} onChange={this.onChangeHandler} />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Password</Form.Label>
                <Col sm={6}>
                  <Form.Control type="text" name="password" value={this.state.password} onChange={this.onChangeHandler} />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Password Confirmation</Form.Label>
                <Col sm={6}>
                  <Form.Control
                    type="text"
                    name="passwordConfirmation"
                    value={this.state.passwordConfirmation}
                    onChange={this.onChangeHandler}
                  />
                </Col>
              </Form.Group>
            </div>
          </Collapse>

          <Form.Row>
            <Col sm={2} className="d-flex justify-content-start">
              <Button variant="danger" className="m-1" type="submit">Delete</Button>
            </Col>
            <Col sm={{span: 2, offset: 6}} className="d-flex justify-content-end">
              <Button variant="primary" className="m-1" type="submit" onClick={this.onSubmitHandler}>Save</Button>
            </Col>
          </Form.Row>
        </Form>
      </div>
    )
  }
}
