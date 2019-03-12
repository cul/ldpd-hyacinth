import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'

export default class UserNew extends React.Component {

  state = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    passwordConfirmation: ''
  }

  // From: http://stackoverflow.com/questions/10726909/random-alpha-numeric-string-in-javascript
  getRandomPassword(length) {
    const chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let result = '';
    for (let i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];

    return result;
  };

  generatePasswordHandler = () => {
    const newPassword = this.getRandomPassword(14);
    this.setState({ password: newPassword, passwordConfirmation: newPassword});
  }

  onChangeHandler = (event) => {
    this.setState({ [event.target.name]: event.target.value })
  }

  render() {
    return(
      <div>
        <ContextualNavbar
          title="Create New User"
          rightHandLinks={[{link: '/users', label: 'Cancel'}]} />

        <Form>
          <Form.Row>
            <Form.Group as={Col} sm={6}>
              <Form.Label>First Name</Form.Label>
              <Form.Control
                type="text"
                name="firstName"
                value={this.state.firstName}
                onChange={this.onChangeHandler}/>
            </Form.Group>

            <Form.Group as={Col} sm={6}>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={this.state.lastName}
                onChange={this.onChangeHandler} />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={this.state.email}
                onChange={this.onChangeHandler} />
              <Form.Text className="text-muted">
                For Columbia sign-in, please use columbia email: uni@columbia.edu
              </Form.Text>
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col} sm={6}>
              <Form.Label>Password</Form.Label>
              <Form.Control type="text" name="password" value={this.state.password} onChange={this.onChangeHandler} />
            </Form.Group>

            <Form.Group as={Col} sm={6}>
              <Form.Label>Password Confirmation</Form.Label>
              <Form.Control
                type="text"
                name="passwordConfirmation"
                value={this.state.passwordConfirmation}
                onChange={this.onChangeHandler} />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col} sm={{ span: 6, offset: 6 }}>
              <Button variant="outline-dark" onClick={this.generatePasswordHandler}>Generate Random Password</Button>
              <Form.Text>Must generate password for Columbia sign-ins.</Form.Text>
            </Form.Group>
          </Form.Row>

          <Button variant="primary" type="submit">Create</Button>
        </Form>
      </div>
    )
  }
}
