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

    const { params: { uid } } = this.props.match

    const data = {
      user: {
        first_name: this.state.user.firstName,
        last_name: this.state.user.lastName,
        email: this.state.user.email,
        current_password: this.state.user.currentPassword,
        password: this.state.user.password,
        password_confirmation: this.state.user.passwordConfirmation,
      },
    };

    hyacinthApi.patch(`/users/${uid}`, data)
      .then((res) => {
        console.log('Saved Changes');
      })
      .catch((error) => {
        console.log(error);
        console.log(error.response.data);
      });
  }

  componentDidMount = () => {
    hyacinthApi.get(`/users/${this.props.match.params.uid}`)
      .then((res) => {
        const { user } = res.data;
        this.setState(producer((draft) => {
          draft.user.uid = user.uid;
          draft.user.isActive = user.isActive;
          draft.user.firstName = user.firstName;
          draft.user.lastName = user.lastName;
          draft.user.email = user.email;
        }));
      })
      .catch((error) => {
        console.log(error);
      });
  }

  render() {
    let rightHandLinks = [];

    if (ability.can('index', 'Users')) {
      rightHandLinks = [{ link: '/users', label: 'Cancel' }]
    }

    return (
      <>
        <ContextualNavbar
          title={`Editing User: ${this.state.user.firstName} ${this.state.user.lastName}`}
          rightHandLinks={rightHandLinks}
        />

        <Form as={Col} onSubmit={this.onSubmitHandler}>
          <Form.Group as={Row}>
            <Form.Label column sm={2}>UID</Form.Label>
            <Col sm={10}>
              <Form.Control plaintext readOnly value={this.state.user.uid} />
            </Col>
          </Form.Group>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>First Name</Form.Label>
              <Form.Control
                type="text"
                name="firstName"
                value={this.state.user.firstName}
                onChange={this.onChangeHandler}
              />
            </Form.Group>

            <Form.Group as={Col}>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={this.state.user.lastName}
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
                value={this.state.user.email}
                onChange={this.onChangeHandler}
              />
              <Form.Text className="text-muted">
                For Columbia sign-in, please use Columbia email: uni@columbia.edu
              </Form.Text>
            </Form.Group>
          </Form.Row>

          <Form.Group as={Row}>
            <Form.Label column sm={2}>Is Active?</Form.Label>

            <Col sm={3}>
              <Form.Control plaintext readOnly value={this.state.user.isActive ? 'Yes' : 'No'} />
            </Col>

            <Col sm={3}>
              <Button variant="outline-danger" type="submit" onClick={this.onFlipActivationHandler}>{(this.state.user.isActive) ? 'Deactivate' : 'Activate'}</Button>
            </Col>
          </Form.Group>

          <Form.Row>
            <Col>
              <Button
                variant="link"
                className="pl-0"
                onClick={() => this.setState({ changePasswordOpen: !this.state.changePasswordOpen })}
                aria-controls="collapse-form"
                aria-expanded={this.state.changePasswordOpen}
              >
                Change Password
                {' '}
                <FontAwesomeIcon icon={this.state.changePasswordOpen ? 'angle-double-up' : 'angle-double-down'} />
              </Button>
            </Col>
          </Form.Row>

          <Collapse in={this.state.changePasswordOpen}>
            <div id="collapse-form">
              <Form.Group as={Row}>
                <Form.Label column sm={{ span: 4, offset: 1 }}>Current Password</Form.Label>
                <Col sm={6}>
                  <Form.Control type="text" name="currentPassword" value={this.state.currentPassword} onChange={this.onChangeHandler} />
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
            <Col sm={10}>
              <Button variant="primary" className="m-1" type="submit" onClick={this.onSubmitHandler}>Save</Button>
            </Col>
          </Form.Row>
        </Form>
      </>
    );
  }
}

export default withErrorHandler(UserEdit, hyacinthApi)
