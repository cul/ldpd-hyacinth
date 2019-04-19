import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import producer from "immer";

import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class CoreDataEdit extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: ''
    }
  }

  onChangeHandler = (event) => {
    let target = event.target;
    this.setState(producer(draft => { draft.project[target.name] = target.value }))
  }

  onSubmitHandler = (event) => {
    event.preventDefault();

    let data = {
      project: {
        display_label: this.state.project.displayLabel,
        project_url: this.state.project.projectUrl
      }
    }

    hyacinthApi.patch("/projects/" + this.props.match.params.string_key, data)
      .then(res => {
        console.log('Saved Changes')
      })
      .catch(error => {
        console.log(error);
        console.log(error.response.data);
      });
  }

  componentDidMount = () => {
    hyacinthApi.get("/projects/" + this.props.match.params.string_key)
      .then(res => {
        let project = res.data.project
        this.setState(producer(draft => {
          draft.project.stringKey = project.string_key
          draft.project.displayLabel = project.display_label
          draft.project.projectUrl = project.project_url
        }))
      })
     .catch(error => {
       console.log(error)
     });
  }

  render() {
    return(
      <Form as={Col} onSubmit={this.onSubmitHandler}>
        <Form.Group as={Row}>
          <Form.Label column sm={2}>String Key</Form.Label>
          <Col sm={10}>
            <Form.Control plaintext readOnly value={this.state.project.stringKey} />
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Display Label</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="displayLabel"
              value={this.state.project.displayLabel}
              onChange={this.onChangeHandler}/>
          </Col>
        </Form.Group>

        <Form.Group as={Row}>
          <Form.Label column sm={2}>Project URL</Form.Label>
          <Col sm={10}>
            <Form.Control
              type="text"
              name="projectUrl"
              value={this.state.project.projectUrl}
              onChange={this.onChangeHandler} />
          </Col>
        </Form.Group>


        <Form.Row>
          <Col sm={12}>
            <Button variant="primary" className="m-1" type="submit" onClick={this.onSubmitHandler}>Save</Button>
          </Col>
        </Form.Row>
      </Form>
    )
  }
}
