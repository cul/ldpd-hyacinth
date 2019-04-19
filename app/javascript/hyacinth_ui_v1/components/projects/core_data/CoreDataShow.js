import React from 'react'
import { Link } from "react-router-dom";
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from "react-router-bootstrap";
import producer from "immer";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class CoreDataShow extends React.Component {

  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: ''
    }
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
        <Row as="dl">
          <Col as="dt" sm={2}>String Key</Col>
          <Col as="dd" sm={10}>{this.state.project.stringKey}</Col>

          <Col as="dt" sm={2}>Display Label</Col>
          <Col as="dd" sm={10}>{this.state.project.displayLabel}</Col>

          <Col as="dt" sm={2}>Project URL</Col>
          <Col as="dd" sm={10}>{this.state.project.project_url}</Col>
        </Row>

        <Row>
          <Col sm={12}>
            <LinkContainer to={this.props.match.url + '/edit'}>
              <Button variant="link">Edit</Button>
            </LinkContainer>
          </Col>
        </Row>
      </>
    )
  }
}
