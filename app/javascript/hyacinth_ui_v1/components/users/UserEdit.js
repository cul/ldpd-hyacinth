import React from 'react';
import {
  Row, Col, Form, Button, Collapse,
} from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import producer from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import hyacinthApi from '../../util/hyacinth_api';
import ability from '../../util/ability';
import SubmitButton from '../layout/forms/SubmitButton';

class UserEdit extends React.Component {
  state = {
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

        this.setState(producer((draft) => {
          draft.user = user;
          draft.user.currentPassword = '';
          draft.user.password = '';
          draft.user.passwordConfirmation = '';
        }));
      });
  }

  onChangeHandler = ({ target: { name, value } }) => {
    this.setState(producer((draft) => { draft.user[name] = value; }));
  }

  onFlipActivationHandler = (event) => {
    event.preventDefault();

    hyacinthApi.patch(`/users/${this.props.match.params.uid}`, { user: { is_active: !this.state.user.isActive } })
      .then((res) => {
        this.setState(producer((draft) => { draft.user.isActive = res.data.user.is_active; }));
      });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const { match: { params: { uid } } } = this.props;
    const { user } = this.state;

    hyacinthApi.patch(`/users/${uid}`, { user: user })
      .then((res) => {
        const { user: { uid } } = res.data;

        this.props.history.push(`/users/${uid}/edit`);
      });
  }

  render() {
    let rightHandLinks = [];

    if (ability.can('index', 'Users')) {
      rightHandLinks = [{ link: '/users', label: 'Back to All Users' }];
    }

    const {
      changePasswordOpen,
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
      </>
    );
  }
}

export default withErrorHandler(UserEdit, hyacinthApi);
