import React from 'react';
import { Col, Form, Button } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';

export default class UserNew extends React.Component {
  state = {
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    passwordConfirmation: '',
  }

  // From: http://stackoverflow.com/questions/10726909/random-alpha-numeric-string-in-javascript
  getRandomPassword(length) {
    const chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let result = '';
    for (let i = length; i > 0; --i) result += chars[Math.round(Math.random() * (chars.length - 1))];

    return result;
  }

  generatePasswordHandler = () => {
    const newPassword = this.getRandomPassword(14);
    this.setState(produce((draft) => { draft.password = newPassword, draft.passwordConfirmation = newPassword; }));
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const data = {
      user: {
        first_name: this.state.firstName,
        last_name: this.state.lastName,
        email: this.state.email,
        password: this.state.password,
        password_confirmation: this.state.passwordConfirmation,
      },
    };

    hyacinthApi.post('/users', data)
      .then((res) => {
        this.props.history.push(`/users/${res.data.user.uid}/edit`);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(produce((draft) => { draft[target.name] = target.value; }));
  }

  render() {
    return (
      <div>
        <ContextualNavbar
          title="Create New User"
          rightHandLinks={[{ link: '/users', label: 'Cancel' }]}
        />

        <Form onSubmit={this.onSubmitHandler}>
          <Form.Row>
            <Form.Group as={Col} sm={6}>
              <Form.Label>First Name</Form.Label>
              <Form.Control
                type="text"
                name="firstName"
                value={this.state.firstName}
                onChange={this.onChangeHandler}
              />
            </Form.Group>

            <Form.Group as={Col} sm={6}>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={this.state.lastName}
                onChange={this.onChangeHandler}
              />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={this.state.email}
                onChange={this.onChangeHandler}
              />
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
                onChange={this.onChangeHandler}
              />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col} sm={{ span: 6, offset: 6 }}>
              <Button variant="outline-dark" onClick={this.generatePasswordHandler}>Generate Random Password</Button>
              <Form.Text>Must generate password for Columbia sign-ins.</Form.Text>
            </Form.Group>
          </Form.Row>

          <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>Create</Button>
        </Form>
      </div>
    );
  }
}
