import React, { useState } from 'react';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { useParams, useHistory } from 'react-router-dom';

import ContextualNavbar from '../shared/ContextualNavbar';
import ability from '../../util/ability';
import GraphQLErrors from '../shared/GraphQLErrors';
import InputGroup from '../shared/forms/InputGroup';
import Label from '../shared/forms/Label';
import FormButtons from '../shared/forms/FormButtons';
import { Can } from '../../util/ability_context';
import { getUserQuery, updateUserMutation } from '../../graphql/users';
import Checkbox from '../shared/forms/inputs/Checkbox';

import BooleanRadioButtons from '../shared/forms/inputs/BooleanRadioButtons';

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
  const [isAdmin, setIsAdmin] = useState(false);
  const [manageVocabularies, setManageVocabularies] = useState(false);
  const [manageUsers, setManageUsers] = useState(false);
  const [readAllDigitalObjects, setReadAllDigitalObjects] = useState(false);
  const [manageAllDigitalObjects, setManageAllDigitalObjects] = useState(false);

  const canActivateUser = () => {
    let activatable = ability.can('manage', 'all');
    if (!activatable) {
      activatable = (ability.can('manage', 'User') && !isAdmin);
    }
    return activatable;
  };

  const gqlResponse = useQuery(
    getUserQuery,
    {
      variables: { id },
      onCompleted: (userData) => {
        setFirstName(userData.user.firstName);
        setLastName(userData.user.lastName);
        setEmail(userData.user.email);
        setIsActive(userData.user.isActive);
        setIsAdmin(userData.user.isAdmin);
        setManageVocabularies(userData.user.permissions.includes('manage_vocabularies'));
        setManageUsers(userData.user.permissions.includes('manage_users'));
        setReadAllDigitalObjects(userData.user.permissions.includes('read_all_digital_objects'));
        setManageAllDigitalObjects(userData.user.permissions.includes('manage_all_digital_objects'));
      },
    },
  );

  const [updateUser, { error: mutationErrors }] = useMutation(updateUserMutation);

  let rightHandLinks = [];

  if (ability.can('read', 'User')) {
    rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
  }

  const onSave = () => {
    const permissions = [];

    if (manageUsers) permissions.push('manage_users');
    if (manageVocabularies) permissions.push('manage_vocabularies');
    if (readAllDigitalObjects) permissions.push('read_all_digital_objects');
    if (manageAllDigitalObjects) permissions.push('manage_all_digital_objects');
    const userData = {
      input: {
        id,
        firstName,
        lastName,
        email,
        currentPassword,
        password,
        passwordConfirmation,
      },
    };
    if (ability.can('manage', 'User')) {
      if (!isAdmin) userData.input.isActive = isActive;
    }
    if (ability.can('manage', 'all')) {
      userData.input.permissions = permissions;
      userData.input.isAdmin = isAdmin;
      userData.input.isActive = isActive;
    }
    return updateUser({
      variables: userData,
    }).then((res) => {
      history.push(`/users/${res.data.updateUser.user.id}/edit`);
    });
  };
  if (gqlResponse.loading) return (<></>);
  if (gqlResponse.error) return (<GraphQLErrors errors={gqlResponse.error} />);

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
            disabled={(!canActivateUser())}
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

        {
          isActive && (
            <>
              <h5>System Wide Permissions</h5>

              <InputGroup>
                <Can I="manage" a="all">
                  <Checkbox
                    sm={12}
                    value={isAdmin}
                    label="Administrator"
                    onChange={v => setIsAdmin(v)}
                    helpText="has ability to perform all actions"
                  />
                </Can>
                <Checkbox
                  sm={12}
                  md={6}
                  value={manageVocabularies}
                  label="Manage Vocabularies"
                  disabled={!ability.can('manage', 'all')}
                  onChange={v => setManageVocabularies(v)}
                  helpText="has ability to create/edit/delete vocabularies, and create/edit/delete terms"
                />
                <Checkbox
                  md={6}
                  sm={12}
                  value={manageUsers}
                  label="Manage Users"
                  disabled={!ability.can('manage', 'all')}
                  onChange={v => setManageUsers(v)}
                  helpText="has ability to add new users, deactivate users, and add all system-wide permissions except administrator"
                />
                <Checkbox
                  md={6}
                  sm={12}
                  value={readAllDigitalObjects}
                  label="Read All Digital Objects"
                  disabled={!ability.can('manage', 'all')}
                  onChange={v => setReadAllDigitalObjects(v)}
                  helpText="has ability to view all projects and all digital objects"
                />
                <Checkbox
                  md={6}
                  sn={12}
                  value={manageAllDigitalObjects}
                  disabled={!ability.can('manage', 'all')}
                  onChange={v => setManageAllDigitalObjects(v)}
                  label="Manage All Digital Objects"
                  helpText="has ability to read/create/edit/delete all digital objects and view all projects"
                />
              </InputGroup>
            </>
          )
        }

        <FormButtons onSave={onSave} />
      </Form>
    </>
  );
}

export default UserEdit;
