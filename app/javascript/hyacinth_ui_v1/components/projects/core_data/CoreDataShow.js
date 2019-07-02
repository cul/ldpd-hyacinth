import React from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import produce from 'immer';

import TabHeading from '../../ui/tabs/TabHeading';
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

  componentDidMount() {
    const { match: { params: { stringKey } } } = this.props;

    hyacinthApi.get(`/projects/${stringKey}`)
      .then((res) => {
        const { project } = res.data;

        this.setState(produce((draft) => {
          draft.project = project;
        }));
      });
  }

  render() {
    const { project: { stringKey, displayLabel, projectUrl } } = this.state;

    return (
      <>
        <TabHeading>Core Data</TabHeading>

        <Row as="dl">
          <Col as="dt" sm={2}>String Key</Col>
          <Col as="dd" sm={10}>{stringKey}</Col>

          <Col as="dt" sm={2}>Display Label</Col>
          <Col as="dd" sm={10}>{displayLabel}</Col>

          <Col as="dt" sm={2}>Project URL</Col>
          <Col as="dd" sm={10}>{projectUrl}</Col>


          <Can I="edit" of={{ subjectType: 'Project', stringKey }}>
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
