import React from 'react';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import hyacinthApi from '../../util/hyacinth_api';
import ability from '../../util/ability';
import SubmitButton from '../layout/forms/SubmitButton';
import SystemWidePermissionsForm from './SystemWidePermissionsForm'

class UserEdit extends React.Component {
  state = {
    loaded: false,
    changePasswordOpen: false,
    user: {
      uid: '',
      isActive: '',
      firstName: '',
      lastName: '',
      email: '',
      currentPassword: '',
      password: '',
      passwordConfirmation: '',
    },
  }

  componentDidMount = () => {
    const { match: { params: { uid } } } = this.props;

    hyacinthApi.get(`/users/${uid}`)
      .then((res) => {
        const { user } = res.data;

        this.setState(produce((draft) => {
          draft.user = user;
          draft.user.currentPassword = '';
          draft.user.password = '';
          draft.user.passwordConfirmation = '';
          draft.loaded = true;
        }));
      });
  }

  onChangeHandler = ({ target: { name, value } }) => {
    this.setState(produce((draft) => { draft.user[name] = value; }));
  }

  onFlipActivationHandler = (event) => {
    event.preventDefault();

    const { user: { uid, isActive } } = this.state;

    hyacinthApi.patch(`/users/${uid}`, { user: { is_active: !isActive } })
      .then((res) => {
        this.setState(produce((draft) => { draft.user.isActive = res.data.user.is_active; }));
      });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { user, user: { uid } } = this.state;
    const { history: { push } } = this.props;

    hyacinthApi.patch(`/users/${uid}`, { user })
      .then(() => push(`/users/${uid}/edit`));
  }

  render() {
    let rightHandLinks = [];

    if (ability.can('index', 'Users')) {
      rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
    }

    const {
      loaded,
      changePasswordOpen,
      user,
      user: {
        uid, firstName, lastName, email, isActive,
        password, currentPassword, passwordConfirmation,
      },
    } = this.state;

    return (
      <>
        <ContextualNavbar
          title={`Editing User: ${firstName} ${lastName}`}
          rightHandLinks={rightHandLinks}
        />

        <Form as={Col} onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>UID</Form.Label>
            <Col sm={10}>
              <Form.Control plaintext readOnly value={uid} />
            </Col>
          </Form.Group>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>First Name</Form.Label>
              <Form.Control type="text" name="firstName" value={firstName} onChange={this.onChangeHandler} />
            </Form.Group>

            <Form.Group as={Col}>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={lastName}
                onChange={this.onChangeHandler}
              />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Email</Form.Label>
              <Form.Control type="email" name="email" value={email} onChange={this.onChangeHandler} />
              <Form.Text className="text-muted">
                For Columbia sign-in, please use Columbia email: uni@columbia.edu
              </Form.Text>
            </Form.Group>
          </Form.Row>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Is Active?</Form.Label>

            <Col sm={3}>
              <Form.Control plaintext readOnly value={isActive ? 'Yes' : 'No'} />
            </Col>

            <Col sm={3}>
              <Button variant="outline-danger" type="submit" onClick={this.onFlipActivationHandler}>{(isActive) ? 'Deactivate' : 'Activate'}</Button>
            </Col>
          </Form.Group>

          <Form.Row>
            <Col>
              <Button
                variant="link"
                className="pl-0"
                onClick={() => this.setState({ changePasswordOpen: !changePasswordOpen })}
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
                  <Form.Control type="text" name="currentPassword" value={currentPassword} onChange={this.onChangeHandler} />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Password</Form.Label>
                <Col sm={6}>
                  <Form.Control type="text" name="password" value={password} onChange={this.onChangeHandler} />
                </Col>
              </Form.Group>

              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Password Confirmation</Form.Label>
                <Col sm={6}>
                  <Form.Control
                    type="text"
                    name="passwordConfirmation"
                    value={passwordConfirmation}
                    onChange={this.onChangeHandler}
                  />
                </Col>
              </Form.Group>
            </div>
          </Collapse>

          <Form.Row>
            <Col sm="auto" className="ml-auto">
              <SubmitButton formType="edit" onClick={this.onSubmitHandler} />
            </Col>
          </Form.Row>
        </Form>

        <hr />
        { loaded && <SystemWidePermissionsForm user={user} /> }

        <hr />
        <h5>Project Permissions</h5>
      </>
    );
  }
}

export default withErrorHandler(UserEdit, hyacinthApi);
