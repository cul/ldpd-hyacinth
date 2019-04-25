import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import producer from "immer";

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading'
import CancelButton from 'hyacinth_ui_v1/components/layout/CancelButton';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler'

class CoreDataEdit extends React.Component {
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
        this.props.history.push("/projects/" + this.props.match.params.string_key + "/core_data");
      });
  }

  onDeleteHandler = (event) => {
    event.preventDefault()

    hyacinthApi.delete("/projects/" + this.props.match.params.string_key)
      .then(res => {
        this.props.history.push('/projects/');
      })
      .catch(error => {
        console.log(error)
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
      <>
        <ProjectSubHeading>Editing Core Data</ProjectSubHeading>

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
            <Col sm={'auto'} className="mr-auto">
              <Button variant="outline-danger" type="submit" onClick={this.onDeleteHandler}>Delete Project</Button>
            </Col>

            <Col sm={'auto'} className="ml-auto">
              <CancelButton to={'/projects/' + this.props.match.params.string_key + '/core_data' } />
            </Col>

            <Col sm={'auto'}>
              <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>Save</Button>
            </Col>
          </Form.Row>
        </Form>
      </>
    )
  }
}

export default withErrorHandler(CoreDataEdit, hyacinthApi);
