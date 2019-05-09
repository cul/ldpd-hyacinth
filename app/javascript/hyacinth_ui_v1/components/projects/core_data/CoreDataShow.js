import React from 'react';
import { Link } from 'react-router-dom';
import { Row, Col, Form, Button, Collapse } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { LinkContainer } from "react-router-bootstrap";
import producer from "immer";

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading'
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler'

class CoreDataShow extends React.Component {

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
      });
  }

  render() {
    return(
      <>
        <ProjectSubHeading>Core Data</ProjectSubHeading>

        <Row as="dl">
          <Col as="dt" sm={2}>String Key</Col>
          <Col as="dd" sm={10}>{this.state.project.stringKey}</Col>

          <Col as="dt" sm={2}>Display Label</Col>
          <Col as="dd" sm={10}>{this.state.project.displayLabel}</Col>

          <Col as="dt" sm={2}>Project URL</Col>
          <Col as="dd" sm={10}>{this.state.project.projectUrl}</Col>

          <Col as="dt" sm={2}></Col>
          <Col as="dd" sm={10}>
            <LinkContainer to={"/projects/" + this.props.match.params.string_key + '/core_data/edit'}>
              <Button className="pl-0 ml-0" variant="link">Edit</Button>
            </LinkContainer>
          </Col>
        </Row>
      </>
    )
  }
}

export default withErrorHandler(CoreDataShow, hyacinthApi)
