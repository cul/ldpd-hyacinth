import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button } from 'react-bootstrap';
import produce from "immer";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api'
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler'
import { Can } from 'hyacinth_ui_v1/util/ability_context';

class ProjectNew extends React.Component {

  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: ''
    }
  }

  onSubmitHandler = (event) => {
    event.preventDefault()

    let data = {
      project: {
        string_key: this.state.project.stringKey,
        display_label: this.state.project.displayLabel,
        project_url: this.state.project.projectUrl,
      }
    }

    hyacinthApi.post('/projects', data)
      .then(res => {
        // console.log('Project created')
        // console.log(res)
        this.props.history.push('/projects/' + res.data.project.string_key + '/core_data/edit');
      })
  }

  onChangeHandler = (event) => {
    let target = event.target
    this.setState(produce(draft => { draft.project[target.name] = target.value }))
  }

  render() {
    return(
      <Can I="create" a="Project">
        <ContextualNavbar
          title="Create New Project"
          rightHandLinks={[{link: '/projects', label: 'Cancel'}]} />

        <Form onSubmit={this.onSubmitHandler}>
          <Form.Row>
            <Form.Group as={Col} sm={6}>
              <Form.Label>String Key</Form.Label>
              <Form.Control
                type="text"
                name="stringKey"
                value={this.state.project.stringKey}
                onChange={this.onChangeHandler}/>
            </Form.Group>

            <Form.Group as={Col} sm={6}>
              <Form.Label>Display Label</Form.Label>
              <Form.Control
                type="text"
                name="displayLabel"
                value={this.state.displayLabel}
                onChange={this.onChangeHandler} />
            </Form.Group>
          </Form.Row>

          <Form.Row>
            <Form.Group as={Col}>
              <Form.Label>Project URL</Form.Label>
              <Form.Control
                type="text"
                name="projectUrl"
                value={this.state.projectUrl}
                onChange={this.onChangeHandler} />
            </Form.Group>
          </Form.Row>

          <Button variant="primary" type="submit" onClick={this.onSubmitHandler}>Create</Button>
        </Form>
      </Can>
    )
  }
}

export default withErrorHandler(ProjectNew, hyacinthApi);