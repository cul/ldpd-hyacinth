import React from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import producer from 'immer';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import { Can } from '../../../util/ability_context';

class CoreDataShow extends React.Component {
  state = {
    project: {
      stringKey: '',
      displayLabel: '',
      projectUrl: '',
    },
  }

  componentDidMount = () => {
    hyacinthApi.get(`/projects/${this.props.match.params.stringKey}`)
      .then((res) => {
        const { stringKey, displayLabel, projectUrl } = res.data.project;
        this.setState(producer((draft) => {
          draft.project.stringKey = stringKey;
          draft.project.displayLabel = displayLabel;
          draft.project.projectUrl = projectUrl;
        }));
      });
  }

  render() {
    const { params: { stringKey } } = this.props.match

    return (
      <>
        <ProjectSubHeading>Core Data</ProjectSubHeading>

        <Row as="dl">
          <Col as="dt" sm={2}>String Key</Col>
          <Col as="dd" sm={10}>{this.state.project.stringKey}</Col>

          <Col as="dt" sm={2}>Display Label</Col>
          <Col as="dd" sm={10}>{this.state.project.displayLabel}</Col>

          <Col as="dt" sm={2}>Project URL</Col>
          <Col as="dd" sm={10}>{this.state.project.projectUrl}</Col>


          <Can I="edit" of={{ subjectType: 'Project', stringKey: stringKey }}>
            <Col as="dt" sm={2} />
            <Col as="dd" sm={10}>
              <LinkContainer to={`/projects/${stringKey}/core_data/edit`}>
                <Button className="pl-0 ml-0" variant="link">Edit</Button>
              </LinkContainer>
            </Col>
          </Can>
        </Row>
      </>
    );
  }
}

export default withErrorHandler(CoreDataShow, hyacinthApi);
