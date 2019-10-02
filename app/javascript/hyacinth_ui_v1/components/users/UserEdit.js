import React, { useState } from 'react';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { gql } from 'apollo-boost';
import { useQuery, useMutation } from '@apollo/react-hooks';

import ContextualNavbar from '../layout/ContextualNavbar';
import ability from '../../util/ability';
import SubmitButton from '../layout/forms/SubmitButton';
import SystemWidePermissionsForm from './SystemWidePermissionsForm'

// class UserEdit extends React.Component {
//   state = {
//     loaded: false,
//     changePasswordOpen: false,
//     user: {
//       uid: '',
//       isActive: '',
//       firstName: '',
//       lastName: '',
//       email: '',
//       currentPassword: '',
//       password: '',
//       passwordConfirmation: '',
//     },
//   }
//
//   componentDidMount = () => {
//     const { match: { params: { uid } } } = this.props;
//
//     hyacinthApi.get(`/users/${uid}`)
//       .then((res) => {
//         const { user } = res.data;
//
//         this.setState(produce((draft) => {
//           draft.user = user;
//           draft.user.currentPassword = '';
//           draft.user.password = '';
//           draft.user.passwordConfirmation = '';
//           draft.loaded = true;
//         }));
//       });
//   }
//
//   onChangeHandler = ({ target: { name, value } }) => {
//     this.setState(produce((draft) => { draft.user[name] = value; }));
//   }
//
//   onFlipActivationHandler = (event) => {
//     event.preventDefault();
//
//     const { user: { uid, isActive } } = this.state;
//
//     hyacinthApi.patch(`/users/${uid}`, { user: { is_active: !isActive } })
//       .then((res) => {
//         this.setState(produce((draft) => { draft.user.isActive = res.data.user.is_active; }));
//       });
//   }
//
//   onSubmitHandler = (event) => {
//     event.preventDefault();
//
//     const { user, user: { uid } } = this.state;
//     const { history: { push } } = this.props;
//
//     hyacinthApi.patch(`/users/${uid}`, { user })
//       .then(() => push(`/users/${uid}/edit`));
//   }
//
//   render() {
//     let rightHandLinks = [];
//
//     if (ability.can('index', 'Users')) {
//       rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
//     }
//
//     const {
//       loaded,
//       changePasswordOpen,
//       user,
//       user: {
//         uid, firstName, lastName, email, isActive,
//         password, currentPassword, passwordConfirmation,
//       },
//     } = this.state;
//
//     return (

const GET_USER = gql`
  query User($id: ID!){
    user(id: $id) {
      id
      firstName
      lastName
      email
      isActive
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

function UserEdit(props) {
  const { match: { params: { uid: id } } } = props;

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

  const [updateUser] = useMutation(UPDATE_USER);

  let rightHandLinks = [];

  if (ability.can('index', 'Users')) {
    rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
  }

  // return loading message if loading
  // return errors message if error

  const onSubmitHandler = (e) => {
    e.preventDefault();
    updateUser({
      variables: {
        input: {
          id,
          firstName,
          lastName,
          email,
          currentPassword,
          password,
          passwordConfirmation,
        },
      },
    }).then((res) => {
      props.history.push(`/users/${res.data.updateUser.user.id}/edit`);
    });
  };

  if (!data) return (<></>);

  return (
    <>
      <ContextualNavbar
        title={`Editing User: ${firstName} ${lastName}`}
        rightHandLinks={rightHandLinks}
      />

      <Form as={Col} onSubmit={onSubmitHandler}>
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

        {/* <Form.Group as={Row}>
          <Form.Label column sm={2}>Is Active?</Form.Label>

          <Col sm={3}>
            <Form.Control plaintext readOnly value={isActive ? 'Yes' : 'No'} />
          </Col>

          <Col sm={3}>
            <Button variant="outline-danger" type="submit" onClick={this.onFlipActivationHandler}>{(isActive) ? 'Deactivate' : 'Activate'}</Button>
          </Col>
        </Form.Group> */}

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

        <Form.Row>
          <Col sm="auto" className="ml-auto">
            <SubmitButton formType="edit" onClick={onSubmitHandler} />
          </Col>
        </Form.Row>
      </Form>

      <hr />
      {/* { loaded && <SystemWidePermissionsForm user={user} /> } */}

      <hr />
      <h5>Project Permissions</h5>
    </>
  );
}




export default UserEdit;
