import React, { useState } from 'react';
import { Col, Form, Button } from 'react-bootstrap';
import { useMutation } from '@apollo/react-hooks';
import { useHistory } from 'react-router-dom';

import ContextualNavbar from '../layout/ContextualNavbar';
import GraphQLErrors from '../ui/GraphQLErrors';
import { createUserMutation } from '../../graphql/users';

function UserNew() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');

  const [createUser, { error }] = useMutation(createUserMutation);
  const history = useHistory();

  // From: http://stackoverflow.com/questions/10726909/random-alpha-numeric-string-in-javascript
  const getRandomPassword = (length) => {
    const chars = '01234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let result = '';
    for (let i = length; i > 0; i -= 1) {
      result += chars[Math.round(Math.random() * (chars.length - 1))];
    }
    return result;
  };

  const generatePasswordHandler = () => {
    const newPassword = getRandomPassword(14);

    setPassword(newPassword);
    setPasswordConfirmation(newPassword);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    createUser({
      variables: {
        input: {
          firstName,
          lastName,
          email,
          password,
          passwordConfirmation,
        },
      },
    }).then((res) => {
      history.push(`/users/${res.data.createUser.user.id}/edit`);
    });
  };

  return (
    <>
      <ContextualNavbar
        title="Create New User"
        rightHandLinks={[{ link: '/users', label: 'Cancel' }]}
      />

      <GraphQLErrors errors={error} />

      <Form onSubmit={e => handleSubmit(e)}>
        <Form.Row>
          <Form.Group as={Col} sm={6}>
            <Form.Label>First Name</Form.Label>
            <Form.Control
              type="text"
              name="firstName"
              value={firstName}
              onChange={e => setFirstName(e.target.value)}
            />
          </Form.Group>

          <Form.Group as={Col} sm={6}>
            <Form.Label>Last Name</Form.Label>
            <Form.Control
              type="text"
              name="lastName"
              value={lastName}
              onChange={e => setLastName(e.target.value)}
            />
          </Form.Group>
        </Form.Row>

        <Form.Row>
          <Form.Group as={Col}>
            <Form.Label>Email</Form.Label>
            <Form.Control
              type="email"
              name="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
            />
            <Form.Text className="text-muted">
              For Columbia sign-in, please use columbia email: uni@columbia.edu
            </Form.Text>
          </Form.Group>
        </Form.Row>

        <Form.Row>
          <Form.Group as={Col} sm={6}>
            <Form.Label>Password</Form.Label>
            <Form.Control type="text" name="password" value={password} onChange={e => setPassword(e.target.value)} />
          </Form.Group>

          <Form.Group as={Col} sm={6}>
            <Form.Label>Password Confirmation</Form.Label>
            <Form.Control
              type="text"
              name="passwordConfirmation"
              value={passwordConfirmation}
              onChange={e => setPasswordConfirmation(e.target.value)}
            />
          </Form.Group>
        </Form.Row>

        <Form.Row>
          <Form.Group as={Col} sm={{ span: 6, offset: 6 }}>
            <Button
              variant="outline-dark"
              onClick={generatePasswordHandler}
            >
              Generate Random Password
            </Button>
            <Form.Text>Must generate password for Columbia sign-ins.</Form.Text>
          </Form.Group>
        </Form.Row>

        <Button variant="primary" type="submit">Create</Button>
      </Form>
    </>
  );
}


export default UserNew;
