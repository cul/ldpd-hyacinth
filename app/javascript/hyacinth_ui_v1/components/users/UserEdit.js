import React from 'react';
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import producer from 'immer';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class UserEdit extends React.Component {
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
    }
  }

  onChangeHandler = (event) => {
    const target = event.target;
    this.setState(producer(draft => { draft.user[target.name] = target.value }))
  }

  onFlipActivationHandler = (event) => {
    event.preventDefault();

    hyacinthApi.patch('/users/' + this.props.match.params.uid, { user: { is_active: !this.state.user.isActive } })
      .then(res => {
        console.log('Changed user activation')
        this.setState(producer(draft => { draft.user.isActive = res.data.user.is_active }))
      });
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    const data = {
      user: {
        first_name: this.state.user.firstName,
        last_name: this.state.user.lastName,
        email: this.state.user.email,
        current_password: this.state.user.currentPassword,
        password: this.state.user.password,
        password_confirmation: this.state.user.passwordConfirmation,
      }
    }

    hyacinthApi.patch(`/users/${this.props.match.params.uid}`, data)
      .then(res => {
        console.log('Saved Changes')
      })
      .catch(error => {
        console.log(error);
        console.log(error.response.data);
      });
  }

  componentDidMount = () => {
    hyacinthApi.get(`/users/${this.props.match.params.uid}`)
      .then(res => {
        const user = res.data.user
        this.setState(producer(draft => {
          draft.user.uid = user.uid
          draft.user.isActive = user.is_active
          draft.user.firstName = user.first_name
          draft.user.lastName = user.last_name
          draft.user.email = user.email
        }))
      })
     .catch(error => {
       console.log(error)
     });
  }

  render() {
    return(
      <>
        <ContextualNavbar
          title={`Editing User: ${this.state.user.firstName} ${this.state.user.lastName}`}
          rightHandLinks={[{link: '/users', label: 'Cancel'}]}
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
