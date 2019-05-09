import React from 'react';
import { Link } from 'react-router-dom';
import { Form, Button } from 'react-bootstrap';
import producer from 'immer';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class GroupNew extends React.Component {
  state = {
    group: {
      stringKey: '',
    },
  }

  submitHandler = (event) => {
    const data = { string_key: this.state.group.stringKey };

    hyacinthApi.post('/groups', data)
      .then((res) => {
        console.log('Created New Group');
      });
  }

  onChangeHandler = (event) => {
    const { target } = event;
    this.setState(producer((draft) => { draft.group[target.name] = target.value; }));
  }

  render() {
    return (
      <div>
        <ContextualNavbar
          title="Create New Group"
          rightHandLinks={[{ link: '/groups', label: 'Cancel' }]}
        />

        <p>Enter a unique string key for this group.</p>
        <Form onSubmit={this.submitHandler}>
          <Form.Group>
            <Form.Label>String Key</Form.Label>
            <Form.Control
              type="text"
              value={this.state.stringKey}
              name="stringKey"
              onChange={this.onChangeHandler}
            />
            <Form.Text className="text-muted">
              String keys must start with a lowercase letter and can only contain dashes and lowercase alphanumeric characters.
            </Form.Text>
          </Form.Group>

          <Button
            variant="primary"
            type="submit"
            onClick={this.submitHandler}
          >
Create
          </Button>
        </Form>
      </div>
    );
  }
}
