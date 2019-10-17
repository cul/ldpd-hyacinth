import React, { useState } from 'react';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { gql } from 'apollo-boost';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useParams, useHistory } from 'react-router-dom';

import ContextualNavbar from '../layout/ContextualNavbar';
import ability from '../../util/ability';
import SystemWidePermissionsForm from './SystemWidePermissionsForm';
import GraphQLErrors from '../ui/GraphQLErrors';
import InputGroup from '../ui/forms/InputGroup';
import Label from '../ui/forms/Label';
import FormButtons from '../ui/forms/FormButtons';

import BooleanRadioButtons from '../ui/forms/inputs/BooleanRadioButtons';

const GET_USER = gql`
  query User($id: ID!){
    user(id: $id) {
      id
      firstName
      lastName
      email
      isActive
      isAdmin
      permissions
    }
  }
`;

const UPDATE_USER = gql`
  mutation UpdateUser($input: UpdateUserInput!){
    updateUser(input: $input){
      user {
        id
      }
    }
  }
`;

function UserEdit() {
  const { uid: id } = useParams();
  const history = useHistory();

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [password, setPassword] = useState('');
  const [currentPassword, setCurrentPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [changePasswordOpen, setChangePasswordOpen] = useState(false);

  const { loading, error, data } = useQuery(
    GET_USER,
    {
      variables: { id },
      onCompleted: (userData) => {
        const {
          user: { firstName, lastName, email, isActive },
        } = userData;

        setFirstName(firstName);
        setLastName(lastName);
        setEmail(email);
        setIsActive(isActive);
      },
    },
  );

  const [updateUser, { error: mutationErrors }] = useMutation(UPDATE_USER);

  let rightHandLinks = [];

  if (ability.can('index', 'Users')) {
    rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
  }

  const onSave = () => {
    return updateUser({
      variables: {
        input: {
          id,
          firstName,
          lastName,
          email,
          isActive,
          currentPassword,
          password,
          passwordConfirmation,
        },
      },
    }).then((res) => {
      history.push(`/users/${res.data.updateUser.user.id}/edit`);
    });
  };

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar
        title={`Editing User: ${firstName} ${lastName}`}
        rightHandLinks={rightHandLinks}
      />

      <GraphQLErrors errors={mutationErrors} />

      <Form as={Col}>
        <Form.Group as={Row}>
          <Form.Label column sm={2}>UID</Form.Label>
          <Col sm={10}>
            <Form.Control plaintext readOnly value={id} />
          </Col>
        </Form.Group>

        <Form.Row>
          <Form.Group as={Col}>
            <Form.Label>First Name</Form.Label>
            <Form.Control type="text" name="firstName" value={firstName} onChange={e => setFirstName(e.target.value)} />
          </Form.Group>

          <Form.Group as={Col}>
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
            <Form.Control type="email" name="email" value={email} onChange={e => setEmail(e.target.value)} />
            <Form.Text className="text-muted">
              For Columbia sign-in, please use Columbia email: uni@columbia.edu
            </Form.Text>
          </Form.Group>
        </Form.Row>

        <InputGroup>
          <Label sm={2}>Is Active?</Label>
          <BooleanRadioButtons
            sm={4}
            value={isActive}
            onChange={v => setIsActive(v)}
          />
          <Col sm={6}>
            <Form.Text className="text-muted">
              Deactivated users are not allowed to login to the system.
            </Form.Text>
          </Col>
        </InputGroup>

        <Form.Row>
          <Col>
            <Button
              variant="link"
              className="pl-0"
              onClick={() => setChangePasswordOpen(!changePasswordOpen)}
              aria-controls="collapse-form"
              aria-expanded={changePasswordOpen}
            >
              Change Password
              {' '}
              <FontAwesomeIcon icon={changePasswordOpen ? 'angle-double-up' : 'angle-double-down'} />
            </Button>
          </Col>
        </Form.Row>

        <Collapse in={changePasswordOpen}>
          <div id="collapse-form">
            <Form.Group as={Row}>
              <Form.Label column sm={{ span: 4, offset: 1 }}>Current Password</Form.Label>
              <Col sm={6}>
                <Form.Control type="text" name="currentPassword" value={currentPassword} onChange={e => setCurrentPassword(e.target.value)} />
              </Col>
            </Form.Group>

            <Form.Group as={Row}>
              <Form.Label column sm={{ span: 4, offset: 1 }}>Password</Form.Label>
              <Col sm={6}>
                <Form.Control type="text" name="password" value={password} onChange={e => setPassword(e.target.value)} />
              </Col>
            </Form.Group>

            <Form.Group as={Row}>
              <Form.Label column sm={{ span: 4, offset: 1 }}>Password Confirmation</Form.Label>
              <Col sm={6}>
                <Form.Control
                  type="text"
                  name="passwordConfirmation"
                  value={passwordConfirmation}
                  onChange={e => setPasswordConfirmation(e.target.value)}
                />
              </Col>
            </Form.Group>
          </div>
        </Collapse>

        <FormButtons onSave={onSave} />
      </Form>

      {
        isActive && (
          <>
            <hr />

            <SystemWidePermissionsForm
              id={data.user.id}
              isAdmin={data.user.isAdmin}
              systemWidePermissions={data.user.permissions}
            />

            <hr />
            <h5>Project Permissions</h5>
          </>
        )
      }
    </>
  );
}

export default UserEdit;
